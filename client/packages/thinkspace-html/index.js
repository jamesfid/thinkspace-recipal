/* jshint node: true */
'use strict';

module.exports = {
  name: 'thinkspace-html',
  isDevelopingAddon: function() {return true},  // see ember-cli issue #2451
  setupPreprocessorRegistry: function(type, registry) {global.totem_base.register_coffeescript_preprocessors(type, registry)}  // register coffeescript
};
