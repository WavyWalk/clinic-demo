phantom.create().then(function (ph) {
    ph.createPage().then(function (page) {

        page.onInitialized = function(){
          page.evaluate(
            function(){
              Function.prototype.bind = Function.prototype.bind || function (thisp) {
                var fn = this;
                return function () {
                    return fn.apply(thisp, arguments);
                };
              }
          }, false)
        };

        page.onResourceRequested = function(requestData, request) {
            if ((/http:\/\/.+?\.css/gi).test(requestData['url']) || requestData['Content-Type'] == 'text/css') {
                request.cancel();
            }
        };

        page.evaluate(function() {
            setTimeout(function() {
                window.callPhantom();
            }, 4000);
        });

        page.onCallback = function() {
            
        };
        
        page.open(url)

    });
});