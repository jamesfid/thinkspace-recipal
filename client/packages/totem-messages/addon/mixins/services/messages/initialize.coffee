import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Mixin.create

  ttz: ember.inject.service()

  message_model_type: null  # override in the appropriate messages service
  message_load_url:   null  # override in the appropriate messages service

  messages_queue:     null  # only used when 'message_model_type' is blank

  init: ->
    @_super()
    @ttz = @get('ttz')
    @reset()

  reset: ->
    @messages_queue = []
    @reset_filters()

  reset_filters: (map) ->
    for key, value of @
      if key.match(/^_msg_/)
        value.content.destroy() if value.content and value.content.destroy
        value.destroy() if value.destroy
        delete(@[key])

  toString: -> 'TotemMessagesService'
