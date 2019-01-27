/*USAGE
put in path, run
phantomjs --disk-cache=no(<-optional) 
  <path_to_this_script/script_name.js> 
  <port (8888)> 
  <your_app_path(http://localhost:3000)>
WHAT IT DOES
on any request, makes request to
your_app + request.url with phantomjs
and returns you rendered page
primary usage for seo
*/

var system = require('system');
var util = require('util');

var queue = []

// var queue_busy = function(){
//     if (queue.length > 7) {
//       return true
//     } else {
//       return false
//     }
// }

if (system.args.length < 3) {
  phantom.exit();
}

var server = require('webserver').create(); 

var port = parseInt(system.args[1]);

var urlPrefix = system.args[2];

var status_code = 200;

var renderHtml = function(url, cb) {

    var page = require('webpage').create();

    page.settings.loadImages = false;

    page.settings.localToRemoteUrlAccessEnabled = true;
    

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
        var content = page.content;
        page.close();
        cb(content);
    };

    
    page.open(url);
    
};

server.listen(port, function (request, response) {

        var url = urlPrefix + request.url; 

        renderHtml(url, function(html) {
            response.statusCode = status_code;
            response.write(html);
            response.close();
        });

    
});

console.log('Listening on ' + port + '...');