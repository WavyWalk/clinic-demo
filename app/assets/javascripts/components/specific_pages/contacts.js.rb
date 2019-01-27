module Components
  module SpecificPages
    class Contacts < RW
      expose

      def get_initial_state
        {
          page: false
        }
      end

      def component_did_mount
        Page.show(wilds: {id: 'contacts'}).then do |page|
          set_state page: page
          Services::MetaTagsController.new(page.title, '', '')
        end
        el = Element.find(ref(:map_embed).to_n)
        el.html = '<div style="width: 100%"><iframe width="100%" height="600" src="https://maps.google.com/maps?width=100%&height=600&hl=de&coord=51.20329525, 6.867969580203036&q=Forst%20Eller%2C%20forest%2C%20D%C3%BCsseldorf%2C%20Germany+(Demo)&ie=UTF8&t=&z=14&iwloc=B&output=embed" frameborder="0" scrolling="no" marginheight="0" marginwidth="0"><a href="https://www.mapsdirections.info/de/routenplaner.htm">Berechnen Sie Ihre Route</a></iframe></div><br />'
      end

      def render
        t(:div, {},
          t(:div, {className: 'row'},
            t(:div, {className: 'col-lg-3'}),
            t(:div, {className: 'col-lg-6'},
              t(:div, {className: 'row'},
                if state.page
                  t(:div, {dangerouslySetInnerHTML: {__html: state.page.body}.to_n})
                end
              ),
              t(:div, {className: 'row'},
                t(:div, {ref: "map_embed"})
              )
            ),
            t(:div, {className: 'col-lg-3'}),
          )         
        )
      end

    end
  end
end