import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  auto_clear_after: 2000
  dismiss_after:    250
  dismissed:        false

  image_class_prefix:   'ts-message_image-'
  info_image_suffixes:  ['info-1']
  error_image_suffixes: ['error-1']
  
  info_headers:  ['Success', 'Hooray!', 'Woohoo']
  error_headers: ['Uh Oh', 'Whoops', "D'oh"]

  # ### Computed properties
  is_debug:    ember.computed.bool  'totem_messages.debug_on'
  auto_clear:  ember.computed.not 'model.sticky'
  image_class: ember.computed 'model.type', -> @get_image_class_for_type()
  type_header: ember.computed 'model.type', -> @get_header_for_type()

  # ### Events
  didInsertElement: ->
    @add_clear_timer() if @get('auto_clear')

  # ### Clearing helpers
  click: ->
    @set 'dismissed', true
    @clear_message(@get('dismiss_after'))

  add_clear_timer: ->
    ms = @get 'auto_clear_after'
    ember.run.later @, (=>
      @clear_message(ms) if ember.isPresent(@$()) and (not @get('dismissed'))
    ), ms

  clear_message: (ms) ->
    totem_messages = @totem_messages
    @$().fadeOut(ms)
    ember.run.later @, (=>
      totem_messages.remove_message(@get('model'))
      @destroy()
    ), ms

  # ### Image helpers
  get_default_image_class: ->
    prefix = @get 'image_class_prefix'
    prefix + 'default'

  get_image_class_for_type: ->
    type     = @get 'model.type'
    suffixes = @get "#{type}_image_suffixes"
    return @get_default_image_class() unless ember.isPresent(suffixes)
    suffix = suffixes[Math.floor(Math.random() * suffixes.length)]
    prefix = @get 'image_class_prefix'
    prefix + suffix

  # ### Header helpers
  get_header_for_type: ->
    type    = @get 'model.type'
    headers = @get "#{type}_headers"
    return '' unless ember.isPresent(headers)
    headers[Math.floor(Math.random() * headers.length)]

  actions:
    suppress: -> @totem_messages.set_suppress_all()
