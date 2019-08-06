import ember from 'ember'
import {mp}  from 'totem/config'

class TotemRequireModules

  constructor: ->
    @module_names = null

  all: -> @module_names ?= Object.keys(window.require.entries)

  filter_by: (regex) -> @all().filter (mod) -> mod.match(regex)

  config_regex: (modname) -> @get_regex('_config', modname)

  factory: (container, type, path) -> container.lookupFactory("#{type}:#{path}")

  app_path: (path) -> "#{mp}#{path}"

  require_module: (path) -> 
    mod = null
    try 
      mod = require path
    catch e
    finally
      return (mod and mod.default)

  # ###
  # ### Helpers.
  # ###

  get_regex: (dir, modname) -> 
    app_name = mp.slice(0, -1)
    new RegExp "^#{app_name}\/#{dir}\/.*#{modname}$"

  is_string: (obj)  -> obj and typeof(obj) == 'string'
  is_hash: (obj)    -> obj and typeof(obj) == 'object' and not ember.isArray(obj)
  is_function: (fn) -> fn  and typeof(fn) == 'function'

  stringify: (obj) -> JSON.stringify(obj)

  warn:  (source, message='') -> console.warn @get_source_message(source, message)
  error: (source, message='') -> throw new ember.Error @get_source_message(source, message)

  get_source_message: (source, message) ->
    name = (@is_hash(source) and @is_function(source.toString) and source.toString()) or ''
    name += ': '  if name
    name + message

  toString: -> 'TotemRequireModules'

export default new TotemRequireModules
