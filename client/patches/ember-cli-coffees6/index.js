'use strict';

var checker = require('ember-cli-version-checker');
var CoffeescriptAddon = require('ember-cli-coffeescript');
var coffeescriptOptions = CoffeescriptAddon.getConfig;
var CoffeescriptPreprocessor = require('ember-cli-coffeescript/lib/coffee-preprocessor');
var CoffeescriptEs6Filter = require('./filter');

//
// Ember-CLI Preprocessor Plugin
//

function CoffeeES6Preprocessor(project, options) {
  this.project = project;
  this.options = options || {};
  this.name = 'ember-cli-coffees6';
}

CoffeeES6Preprocessor.prototype.ext = CoffeescriptEs6Filter.prototype.extensions;
CoffeeES6Preprocessor.prototype.toTree = function(tree, inputPath, outputPath) {
  var es6ified = new CoffeescriptEs6Filter(tree, this.options);
  return new CoffeescriptPreprocessor(coffeescriptOptions.call(this)).toTree(es6ified);
};


//
// Ember-CLI Addon
//

function CoffeescriptES6Addon(project) {
  this.project = project;
  this.name = 'Ember CLI Coffeescript ES6 Addon';
}

CoffeescriptES6Addon.prototype.shouldSetupRegistryInIncluded = function() {
  return !checker.isAbove(this, '0.2.0');
}

CoffeescriptES6Addon.prototype.setupPreprocessorRegistry = function(type, registry) {
  var plugin = new CoffeeES6Preprocessor(this.project, {/* config here */});
  registry.add('js', plugin);
}

CoffeescriptES6Addon.prototype.included = function(app) {
  this.app = app;
  if (this.shouldSetupRegistryInIncluded()) {
    this.setupPreprocessorRegistry('parent', app.registry);
  }
};


// Sixthedge change to register this for the app and addons.
// Registers this addon and also registers coffeescript.

// module.exports = CoffeescriptES6Addon;

var coffeescriptOptions = function() {return {};}

function CoffeeES6Preprocessor(options) {
  this.options = options || {};
  this.name    = 'ember-cli-coffees6';
  this.type    = 'js';
  this.ext     = 'coffee';
}

CoffeescriptES6Addon.prototype.included = function(app) {
  this.register_coffeescript_preprocessors('parent', app.registry);
}

CoffeescriptES6Addon.prototype.register_coffeescript_preprocessors = function(type, registry, options) {
  var options = options || {}
  var plugin  = new CoffeeES6Preprocessor(options);
  registry.add('js', plugin);
}

module.exports = CoffeescriptES6Addon;
