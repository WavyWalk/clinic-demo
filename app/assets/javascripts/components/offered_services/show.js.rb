module Components
  module OfferedServices
    class Show < RW
      expose

      def init
        yields_phantom_ready
      end

      def get_initial_state
        {
          offered_service: false
        }
      end

      def component_did_mount
        offered_service_to_query = (x = props.offered_service_id) ? x : props.params.id
        OfferedService.show(wilds: {id: offered_service_to_query}, component: self).then do |offered_service|
          if offered_service.avatar == nil
            offered_service.avatar = Avatar.new
          end
          begin
          set_state offered_service: offered_service
          Services::MetaTagsController.new(
            offered_service.m_title,
            offered_service.m_description,
            offered_service.m_keywords
          )
          component_phantom_ready
          rescue Exception => e
            p e
          end

        end.fail do |resp|
          raise resp
        end
        Element.find('.offered_services_show').on('click.reactive_link', 'a') do |e|
          el = e.target
          if el.has_class?('react_link')
            e.prevent
            href = e.target.attr('href')
            Components::App::Router.history.pushState(nil, href)
          end
        end
      end

      def render
        t(:div, {className: 'offered_services_show container'},
          progress_bar,
          if state.offered_service
            # p state.offered_service.avatar.pure_attributes
            t(:div, {className: 'show_content'},
              t(:img, {className: "avatar", src: state.offered_service.avatar.try(:url)}),
              t(:h1, {}, state.offered_service.title),
              t(:div, {dangerouslySetInnerHTML: {__html: state.offered_service.body}.to_n}),
              if !state.offered_service.price_items.empty?
                t(:div, {className: 'prices'},
                  t(:p, {}, 'prices'),
                  *splat_each(state.offered_service.price_items) do |price_item|
                    t(:p, {}, "#{price_item.name} : #{price_item.price}")
                  end
                )
              end
            )
          else
            t(:p, {}, "loading") 
          end
        )
      end

      def component_will_unmount
        Element.find('.pages_show').off('click.reactive_link')
      end

    end
  end
end