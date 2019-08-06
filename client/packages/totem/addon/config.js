/* jshint node: true */
import ember from 'ember';
var platform_name = ember.ENV.PLATFORM_NAME;
var mod           = require(platform_name + '/config/environment');
var mod_default   = mod.default || {};
var config        = mod_default.totem || {};
var mod_prefix    = mod_default.modulePrefix || '';
if (mod_prefix !== '') {mod_prefix = mod_prefix + '/';}
export var mp  = mod_prefix;
export var env = mod_default;
export default config;
