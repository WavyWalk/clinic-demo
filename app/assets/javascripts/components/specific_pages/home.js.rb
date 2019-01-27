module Components
  module SpecificPages
    class Home < RW

      expose

      def render
        t(:div, {className: 'row'}, 
          t(:div, {className: 'jumbotron'}, 
            t(:div, {className: 'container text-center'}, 
              t(:div, {className: 'row'}, 
                t(:div, {className: 'col-lg-6'}, 
                  t(:h1, {}, 
                    "ABC dent"
                  ),
                  t(:h4, {}, 
                    "the small clinic demo with appointment scheduling"
                  )
                ),
                t(:div, {className: 'col-lg-6'}, 
                  t(:h5, {}, 
                    'Dusseldorf, Main street 1'
                  )
                )
              )
            )
          ),
          t(:div, {className: 'row below_jumbo', ref: 'row_below', id: 'element-waypoint'}, 
            t(Components::Layouts::EightFour, 
              {
                eight: 
                [
                  t(Components::Pages::Show, {page_id: 'about-us'})  
                ],
                four: 
                [
                  t(:div, {className: 'sidebar'},
                    t(Components::Partials::Doctors::ListGroup, {}),
                    t(Components::Blogs::GroupList, {})
                  )
                ]
              }
            )
          )
        )
      end


      def component_did_mount
        @wayp = Element.find(ref('row_below').to_n)
        @wy  = Waypoint.new(
          {
            element: @wayp,
            handler: ->(direction){ p('foo') },
            offset: '10%'
          }
        )
      end

      def component_will_unmount
        @wy.destroy
      end

    end
  end
end
