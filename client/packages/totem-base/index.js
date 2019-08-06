/* jshint node: true */
'use strict';

var totem_base = {
  name: 'totem-base',

  get_addon_path: function (registry, name) {
    var addon_packages = registry && registry.app && registry.app.project && registry.app.project.addonPackages;
    if(addon_packages){
      return addon_packages[name] && addon_packages[name].path;
    } else {
      throw new Error('Could not find path for module: ' + name);
    }
  },

  register_coffeescript_preprocessors: function(type, registry) {
    if (type === 'parent') {return;}
    var options = {}
    var cs6     = require(this.get_addon_path(registry, 'ember-cli-coffees6'));
    cs6.prototype.register_coffeescript_preprocessors(type, registry, options);
  }

};

global.totem_base = totem_base;
module.exports    = totem_base;
