import ember from 'ember'
import reqm  from 'totem/config/require_modules'

class TotemMixins

  constructor: ->
    @target_cache  = {}
    @mixin_cache   = {}
    @target_mixins = {}
    @show_warnings = true

  # ###
  # ### Public Methods.
  # ###

  add:    (target_paths, mixin_paths) -> @add_mixins(target_paths, mixin_paths)
  add_to: (mixin_paths, target_paths) -> @add_mixins(target_paths, mixin_paths)

  turn_warnings_on:  -> @show_warnings = true
  turn_warnings_off: -> @show_warnings = false

  # ###
  # ### Internal Methods.
  # ###

  add_mixins: (target_paths, mixin_paths) ->
    @error "must pass 'target paths' to add mixins [#{@stringify(target_paths)}]."  if ember.isBlank(target_paths)
    @error "must pass 'mixin paths' to add mixins [#{@stringify(mixin_paths)}]."    if ember.isBlank(mixin_paths)
    for target_path in ember.makeArray(target_paths)
      for mixin_path in ember.makeArray(mixin_paths)
        @add_mixin(target_path, mixin_path)

  add_mixin: (target_path, mixin_path) ->
    @error "'target_path' is blank or not a string [#{@stringify(target_path)}]."  unless @valid_path(target_path)
    @error "'mixin_path' is blank or not a string [#{@stringify(mixin_path)}]."  unless @valid_path(mixin_path)
    return if @target_has_mixin(target_path, mixin_path)
    target = @require_target(target_path)
    @error "target at path '#{path}' is invalid -- a target must be a class or mixin.'"  unless @valid_target(target)
    mixin = @require_mixin(mixin_path)
    @error "mixin at path '#{mixin_path}' is not a mixin."  unless @is_mixin(mixin)
    target.reopen(mixin)

  target_has_mixin: (target_path, mixin_path) ->
    mixins = (@target_mixins[target_path] ?= [])
    if mixins.contains(mixin_path)
      @warn "'#{target_path}' has a duplicate mixin request for '#{mixin_path}'.  Ignoring."
      true
    else
      mixins.push(mixin_path)
      false

  require_target: (path) -> 
    target = @target_cache[path]
    return target if target
    target = @require_module(path)
    @error "target module at path '#{path}' not found."  unless target
    @target_cache[path] = target
    target

  require_mixin: (path) -> 
    mixin = @mixin_cache[path]
    return mixin if mixin
    mixin = @require_module(path)
    @error "mixin module at path '#{path}' not found."  unless mixin
    @mixin_cache[path] = mixin
    mixin

  require_module: (path) ->
    mod = reqm.require_module(path)  # first try without app prefix e.g. in the addon folder
    return mod if mod
    app_path = reqm.app_path(path)
    reqm.require_module(app_path)    # second (and last) try with app prefix e.g. orchid/

  valid_path:   (obj) -> obj and typeof(obj) == 'string'
  valid_target: (obj) -> obj and (obj.isClass or @is_mixin(obj))
  is_mixin:     (obj) -> obj and obj instanceof ember.Mixin

  # ###
  # ### Warnings/Errors.
  # ###

  warn:  (message) -> @show_warnings and reqm.warn(@, message)
  error: (message) -> reqm.error(@, message)

  stringify: (obj) -> reqm.stringify(obj)

  toString: -> 'TotemMixins'

export default new TotemMixins
