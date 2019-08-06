/* jshint node: true */
'use strict';

module.exports = {
  name: 'thinkspace-base',
  isDevelopingAddon: function() {return true},  // see ember-cli issue #2451
  setupPreprocessorRegistry: function(type, registry) {global.totem_base.register_coffeescript_preprocessors(type, registry)},  // register coffeescript
  contentFor: function(type, config, content) {
    if (type === 'head') {
      var app_id = config.totem.crisp_app_id;
      if (!app_id) {return ''}
      var add    = [];
      add.push("<script type='text/javascript'> window.$crisp=[];window.CRISP_WEBSITE_ID='" + app_id + "';(function(){ d=document;s=d.createElement('script'); s.src='https://client.crisp.chat/l.js'; s.async=1;d.getElementsByTagName('head')[0].appendChild(s);})(); </script>")
      return add.join('\n');
    }
  }

}
