/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');

var APP_OPTIONS = {};

APP_OPTIONS.defeatureify = {
  "features": {
  },
  "enableStripDebug": true,
  "debugStatements": [
    "logger.default.info",
    "logger.default.warn",
    "logger.default.error",
    "logger.default.debug",
    "logger.default.verbose",
    "logger.default.log",
    "logger.default.rest",
    "logger.default.trace",
    "console.log",
    "console.info",
    "console.warn",
    "console.error",
    "console.debug",
    "console.clear"
  ]
}

APP_OPTIONS.fingerprint = {
  "prepend":    process.env["APP_EMBER_FINGERPRINT_PREPEND"],
  "exclude":    ['assets/ckeditor', 'assets/pdfjs'],
  "extensions": ['js', 'css', 'png', 'jpg', 'gif', 'map', 'svg']
}

APP_OPTIONS.sourcemaps = false;

var app = new EmberApp(APP_OPTIONS);

// Use `app.import` to add additional libraries to the generated
// output files.
//
// If you need to use different assets in different
// environments, specify an object as the first parameter. That
// object's keys should be the environment name and the values
// should be the asset to use in that environment.
//
// If the library that you are including contains AMD or ES6
// modules that you would like to import into your application
// please specify an object with the list of modules as keys
// along with the exports of each module as its value.

// compile runtime templates
app.import('bower_components/ember/ember-template-compiler.js');
// jquery ui
app.import('bower_components/jquery-ui/jquery-ui.js');
// foundation.min
app.import('bower_components/foundation/js/foundation.min.js');
// fontawesome
app.import('bower_components/font-awesome/fonts/fontawesome-webfont.svg', {"destDir":"assets/fonts"});
app.import('bower_components/font-awesome/fonts/FontAwesome.otf', {"destDir":"assets/fonts"});
app.import('bower_components/font-awesome/fonts/fontawesome-webfont.ttf', {"destDir":"assets/fonts"});
app.import('bower_components/font-awesome/fonts/fontawesome-webfont.woff', {"destDir":"assets/fonts"});
app.import('bower_components/font-awesome/fonts/fontawesome-webfont.eot', {"destDir":"assets/fonts"});
app.import('bower_components/font-awesome/fonts/fontawesome-webfont.woff2', {"destDir":"assets/fonts"});
// pick a date
app.import('bower_components/pickadate/lib/picker.js');
app.import('bower_components/pickadate/lib/picker.time.js');
app.import('bower_components/pickadate/lib/picker.date.js');
// chosen
app.import('bower_components/chosen/chosen.jquery.js');
app.import('bower_components/chosen/chosen.css');
app.import('bower_components/chosen/chosen-sprite.png', {"destDir":"assets"});
app.import('bower_components/chosen/chosen-sprite@2x.png', {"destDir":"assets"});
// rangeslider css
app.import('bower_components/rangeslider.js/dist/rangeslider.css');
// rangeslider js
app.import('bower_components/rangeslider.js/dist/rangeslider.js');
// EaselJS
app.import('bower_components/EaselJS/lib/easeljs-0.8.2.min.js');
// TweenJS
app.import('bower_components/TweenJS/lib/tweenjs-0.6.1.min.js');
// PreloadJS
app.import('bower_components/PreloadJS/lib/preloadjs-0.6.1.min.js');
// SoundJS
app.import('bower_components/SoundJS/lib/soundjs-0.6.1.min.js');
app.import('bower_components/colpick/js/colpick.js');
// amcharts
app.import('bower_components/amcharts/dist/amcharts/amcharts.js');
app.import('bower_components/amcharts/dist/amcharts/pie.js');
app.import('bower_components/amcharts/dist/amcharts/xy.js');
app.import('bower_components/amcharts/dist/amcharts/serial.js');
// totem-assets
app.import('vendor/file_upload/jquery.fileupload.js');
app.import('vendor/file_upload/jquery.iframe-transport.js');
app.import('vendor/misc/jquery-autosize.js');
app.import('vendor/misc/jquery-sortable.js');
// PDF JS
app.import('vendor/pdfjs/compatibility.js');
app.import('vendor/pdfjs/pdf.js');
// Moment
app.import('bower_components/moment-timezone/builds/moment-timezone-with-data.min.js');
// Dragula
app.import('vendor/dragula/dragula.js')
// Cookies
app.import('bower_components/js-cookie/src/js.cookie.js');
// Password Strength
app.import('bower_components/zxcvbn/dist/zxcvbn.js');

// New asset trees (use when need a 'dist/destDir' directory e.g. do not include in vendor.js).
var trees = [];
var pick_files = require('broccoli-static-compiler');

// thinkspace-assets ckeditor config
trees.push(pick_files('node_modules/thinkspace-assets/vendor/ckeditor', {"srcDir":"/","files":["config.js"],"destDir":"assets/ckeditor"}));
// ckeditor
trees.push(pick_files('bower_components/ckeditor', {"srcDir":"/","files":["ckeditor.js","styles.js"],"destDir":"assets/ckeditor"}));
trees.push(pick_files('bower_components/ckeditor', {"srcDir":"adapters","files":["jquery.js"],"destDir":"assets/ckeditor/adapters"}));
trees.push(pick_files('bower_components/ckeditor', {"srcDir":"skins/moono","files":["**/*.*"],"destDir":"assets/ckeditor/skins/moono"}));
trees.push(pick_files('bower_components/ckeditor', {"srcDir":"lang","files":["*.*"],"destDir":"assets/ckeditor/lang"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"forms","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/forms"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"colorbutton","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/colorbutton"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"panelbutton","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/panelbutton"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"table","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/table"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"image","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/image"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"specialchar","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/specialchar"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"link","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/link"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"justify","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/justify"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"pastefromword","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/pastefromword"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"clipboard","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/clipboard"}));
trees.push(pick_files('bower_components/ckeditor/plugins', {"srcDir":"iframe","files":["**/*.*"],"destDir":"assets/ckeditor/plugins/iframe"}));
// thinkspace-assets fonts
trees.push(pick_files('node_modules/thinkspace-assets/fonts', {"srcDir":"icomoon","files":["**/*.*"],"destDir":"assets/fonts"}));
// thinkspace-assets images
trees.push(pick_files('node_modules/thinkspace-assets/images', {"srcDir":"/","files":["**/*.*"],"destDir":"assets/images"}));

module.exports = app.toTree(trees);
