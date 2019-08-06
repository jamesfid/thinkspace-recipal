import ember from 'ember'

export default ember.Object.extend

  register: (section, options) -> @tvo.set_path_value @_get_path(section), options

  ready: (section, value=true) -> @_ready(section, value)

  ready_properties: (value) -> @_ready_properties(value)

  lookup: (section) -> @tvo.get @_get_path(section)
  
  actions: (section) -> @_actions(section)
  
  component: (section) -> @_component(section)

  has_action: (section, action) -> @_has_action(section, action)

  send_action: (section, action, value) -> @_send_action(section, action, value)

  call_action: (section, action, value=null) -> @_call_action(section, action, value)

  # ###
  # ### Internal.
  # ###

  _ready: (section, value) ->
    @_setup_section(section)
    @_set_value("#{section}.ready", value)

  _ready_properties: (value) ->
    return [] unless value
    @tvo.attribute_value_array(value).map (prop) -> "tvo.section.#{prop}.ready"

  _set_value: (key, value) ->
    path = @_get_path(key)
    @tvo.set path, value
    path

  _get_path: (key) -> "#{@tvo_property}.#{key}"

  _component: (section) ->
    component = (@lookup(section) or {}).component
    @tvo.is_object_valid(component) and component

  _actions: (section, action) -> (@lookup(section) or {}).actions

  _has_action: (section, action) -> (@actions(section) or {})[action]

  _send_action: (section, action, value) ->
    component = @component(section)
    console.error "Section send action [#{action}] component not registered."  unless component
    actions     = @actions(section) or {}
    send_action = null
    for own k, v of actions
      send_action = v  if k == action
    console.error "Section send action [#{action}] not found."  unless send_action
    component.send send_action, value  if component and send_action

  _call_action: (section, action, value) ->
    component = @component(section)
    console.error "Section send action [#{action}] component not registered."  unless component
    actions    = @actions(section) or {}
    call_action = null
    for own k, v of actions
      call_action = v  if k == action
    console.error "Section get action [#{action}] not found."  unless call_action
    console.error "Component does not have function [#{call_action}]."  unless component[call_action] and typeof(component[call_action]) == 'function'
    component[call_action](value)

  _setup_section: (section) ->
    path = @_get_path(section)
    return if @tvo.get(path)
    @_set_value(section, {})

  toString: -> 'TvoSection'
