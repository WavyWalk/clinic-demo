module Components
  module Blogs
    class New < RW
      expose

      include Plugins::Formable
      include Plugins::DependsOnCurrentUser
      set_roles_to_fetch :blogger

      def get_initial_state
        {
          form_model: Blog.new
        }        
      end

      def render
        t(:div, {},
          if state.current_user.has_role? :blogger
            t(:div, {className: 'blogs_new'}, 
              input(Forms::Input, state.form_model, :title, {type: "text", show_name: 'title'}),
              input(Forms::Input, state.form_model, :m_title, {type: "text", show_name: 'meta title'}),
              input(Forms::Input, state.form_model, :m_description, {type: "text", show_name: 'meta description'}),
              input(Forms::Input, state.form_model, :m_keywords, {type: "text", show_name: 'meta keywords'}),
              input(Forms::WysiTextarea, state.form_model, :body),
              input(Forms::Checkbox, state.form_model, :published, {show_name: 'publish'}),
              t(:button, {className: 'btn btn-primary', onClick: ->(){handle_inputs}}, "create blog")
            )
          end
        )
      end

      def handle_inputs
        collect_inputs
        unless state.form_model.has_errors?
          state.form_model.create.then do |model|
            if model.has_errors?
              set_state form_model: model
            else
              msg = Shared::Flash::Message.new(t(:div, {}, 
                                                t(:p, {}, "blog has been saved"),
                                                link_to("go to created blog", "/blogs/#{state.form_model.id}"),
                                                t(:a, {onClick: ->{start_new}}, "or create one more")
                                              ))
              Components::App::Main.instance.ref(:flash).rb.add_message(msg)
              state.form_model = model
              props.history.pushState(nil, '/users/dashboard')
              `window.scrollTo(0,0)`
            end
          end
        else
          set_state form_model: state.form_model
          `window.scrollTo(0,0)`
        end
      end

      def start_new
        state.blog_saved = false
        set_state form_model: Blog.new
      end


    end
  end
end