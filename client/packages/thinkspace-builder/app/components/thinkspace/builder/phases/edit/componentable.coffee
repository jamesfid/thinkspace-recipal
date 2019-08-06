import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base  from 'thinkspace-builder/components/wizard/steps/base'

export default base.extend
  # ### Services
  tvo:     ember.inject.service()
  builder: ember.inject.service()

  # ### Properties
  mode:              'preview'
  is_selected:       false
  classNames:        ['ts-builder_preview']
  classNameBindings: ['is_edit_mode_content:is-edit-mode-content']

  has_builder_content:  ember.computed 'component.has_builder_content',  'model', 'mode',  -> 
    ta.PromiseObject.create promise: @get_builder_ability('has_builder_content')
  has_builder_settings: ember.computed 'component.has_builder_settings', 'model', 'mode',  -> 
    ta.PromiseObject.create promise: @get_builder_ability('has_builder_settings')
  has_builder_preview:  ember.computed 'component.has_builder_preview',  'model', 'mode',  -> 
    ta.PromiseObject.create promise: @get_builder_ability('has_builder_preview')
  has_builder_messages: ember.computed.notEmpty 'builder_messages'
  builder_messages:     ember.computed 'model', 'mode', -> ta.PromiseArray.create promise: @get_builder_messages()

  get_builder_ability: (property) ->
    model = @get 'model'
    has   = @get "component.#{property}"
    if model.builder_abilities?
      new ember.RSVP.Promise (resolve, reject) =>
        model.builder_abilities().then (abilities) =>
          ability = abilities[property]
          has     = ability if ember.isPresent(ability)
          resolve(has)
    else
      new ember.RSVP.Promise (resolve, reject) =>
        resolve(has)

  get_builder_messages: ->
    model = @get 'model'
    if model.builder_messages?
      model.builder_messages()
    else
      new ember.RSVP.Promise (resolve, reject) => resolve()

  # ### Accessibility
  # attributeBindings: ['tabindex']
  # tabindex:          1

  # ### Computed properties
  display_toolbar: ember.computed.or 'is_selected', 'is_edit_mode_content'

  c_mode:     ember.computed 'component', 'mode', ->
    mode      = @get 'mode'
    component = @get 'component'
    property  = "builder_#{mode}_path"
    path      = component.get property
    ns.to_p path
    
  is_edit_mode_content: ember.computed.equal 'mode', 'content'

  # ### Mode helpers
  set_mode_content:  -> @reset_builder_toolbar(); @set_mode 'content'
  set_mode_settings: -> @reset_builder_toolbar(); @set_mode 'settings'
  set_mode_preview:  -> @reset_builder_toolbar(); @set_mode 'preview'
  set_mode: (mode)   -> @set 'mode', mode

  # ### Helpers
  reset_builder_toolbar: -> @get('builder').reset_toolbar()

  actions:
    set_mode_content:  -> @set_mode_content()  unless ember.isEqual(@get('mode'), 'content')
    set_mode_settings: -> @set_mode_settings() unless ember.isEqual(@get('mode'), 'settings')
    set_mode_preview:  -> @set_mode_preview()  unless ember.isEqual(@get('mode'), 'preview')
    set_mode: (mode) ->
      fn = "set_mode_#{mode}"
      console.error "[edit:compnentable] Does not respond to set_mode_#{mode}." unless @[fn]?
      @[fn]()

    cancel: -> @set_mode_preview()
