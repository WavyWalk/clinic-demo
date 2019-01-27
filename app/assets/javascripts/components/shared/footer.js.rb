module Shared
  class Footer < RW

    expose

    def init
      @class_to_add = nil
      if props.on_home_route
        @class_to_add = 'home_footer'
      end
    end
    
    def render
      t(:footer, {className: "footer row #{@class_to_add}"}, 
        t(:div, {className: 'g_adress_bar', itemscope: '', itemtype: "http://schema.org/LocalBusiness"}, 
          t(:p, {itemprop: 'name'}, 
            'Some generic small scale clinic'
          ),
          t(:p, {itemprop: 'adress', itemscope: '', itemtype: "http://schema.org/PostalAddress"}),
          t(:p, {itemprop: 'streetAddress'}, 
            'Main str. 1'
          ),
          t(:p, {itemprop: "addressLocality"}, 
            'Dusseldorf'
          ),
          t(:p, {itemprop: "addressRegion"}, 
            'Germany'
          ),
          t(:P, {itemprop: "postalCode"}, 
            '0000001'
          ),
          t(:p, {itemprop: "telephone"}, 
            '+149 000000000'
          ),
          t(:meta, {itemprop: "latitude", content: "LATITUDE"}),
          t(:meta, {itemprop: "longtitude", content: "LATITUDE"})
        )
      )        
    end

  end
end
