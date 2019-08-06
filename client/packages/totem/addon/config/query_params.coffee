import ember from 'ember'
import ns    from 'totem/ns'
import reqm  from 'totem/config/require_modules'

class TotemQueryParams

  constructor: ->
    @qp_map = {}

  process: (container) ->
    regex = reqm.config_regex('query_params')
    mods  = reqm.filter_by(regex)
    return if ember.isBlank(mods)
    for mod in mods
      hash = reqm.require_module(mod)
      @error "Module '#{mod}' is not a hash."  unless reqm.is_hash(hash)
      for model_path, qp of hash
        @error "Module '#{mod}' model path is not a string."                 unless reqm.is_string(model_path)
        @error "Module '#{mod}' query params is not a hash."                 unless reqm.is_hash(qp)
        @error "Module '#{mod}' model path '#{model_path}' is a duplicate."  if ember.isPresent(@qp_map[model_path])
        @qp_map[model_path] = qp
    @add_query_params_properties_to_model_classes(container)

  add_query_params_properties_to_model_classes: (container) ->
    for model_path, qp of @qp_map
      path = ns.to_p(model_path)
      @error "Model path '#{model_path}' does not exist."  if ember.isBlank(path)
      model_class = reqm.factory(container, 'model', path)
      @error "Model class '#{model_path}' for path '#{path}' does not exist."  if ember.isBlank(model_class)
      model_class.reopenClass
        include_authable_in_query:  qp.authable  or false
        include_ownerable_in_query: qp.ownerable or false

  error: (message='') -> reqm.error(@, message)

  toString: -> 'TotemQueryParams'

export default new TotemQueryParams
