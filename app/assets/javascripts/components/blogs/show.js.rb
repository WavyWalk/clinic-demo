module Components
  module Blogs
    class Show < RW
      expose

      def init
        yields_phantom_ready
      end

      def get_initial_state
        {
          blog: false 
        }
      end

      def component_did_mount
        `
          window.scrollTo(0, 0)
        `
        blog_to_query = (x = props.blog_id) ? x : props.params.id
        begin
        Blog.show(wilds: {id: blog_to_query}, component: self).then do |blog|
          set_state blog: blog
          Services::MetaTagsController.new(blog.title, blog.m_description, blog.m_keywords)
          component_phantom_ready
        end.fail do |resp|
          raise resp
        end
        rescue Exception => e
          p e
        end
        Element.find('.blogs_show').on('click.reactive_link', 'a') do |e|
          el = e.target
          if el.has_class?('react_link')
            e.prevent
            href = e.target.attr('href')
            Components::App::Router.history.pushState(nil, href)
          end
        end
      end

      def component_did_update(prev_props, prev_state)
        if state.blog && (prev_props.params.id != props.params.id)
          component_did_mount
        end
      end

      def render
        t(:div, {className: 'row'},
          progress_bar,
          t(:div, {className: 'blogs_show col-lg-8 container'},
            
            *if state.blog
              [
                t(:div, {className: 'author_details'},
                  t(:p, {},
                    "author: #{state.blog.user.profile.name}",
                  ),
                  if state.blog.user.avatar
                    t(:p, {},
                      t(:img, {className: 'avatar', src: state.blog.user.avatar.url},

                      ),
                      state.blog.user.profile.name
                    )
                  end,
                  t(:p, {},
                    Moment.new(state.blog.published_at).format('YYYY-MM-DD')
                  )
                ),
                t(:div, {className: 'blogs_show_content'},
                  # t(:h1, {className: 'title'},
                  #   state.blog.title
                  # ),
                  t(:div, {dangerouslySetInnerHTML: {__html: state.blog.body}.to_n})
                )
              ]
            else
              t(:p, {}, "loading") 
            end
          ),
          t(:div, {className: 'col-lg-4'},
            t(Components::Blogs::GroupList, {})
          )
        )
      end

      def component_will_unmount
        Element.find('.blogs_show').off('click.reactive_link')
      end

    end
  end
end