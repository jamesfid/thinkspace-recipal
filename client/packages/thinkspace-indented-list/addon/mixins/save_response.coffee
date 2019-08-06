import ember          from 'ember'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'

export default ember.Mixin.create

  save_response: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @readonly  # catch-all incase called by some method
      @process_save_response_queue().then =>
        resolve()
      , (error) =>
        console.error "Error saving response", error
        @set 'save_error', true
        @queued_saves.clear()
        reject(error)

  process_save_response_queue: ->
    new ember.RSVP.Promise (resolve, reject) =>
      ember.run.schedule 'afterRender', @, =>
        if ember.isPresent(@queued_saves)
          @queued_saves.push(true)
          return resolve()
        @queued_saves.push(true)
        @save_response_record().then =>
          @queued_saves.pop()
          return resolve() if ember.isBlank(@queued_saves)  # no new saves queued during ajax request
          @queued_saves.clear()
          @process_save_response_queue()
          resolve()
        , (error) => reject(error)

  save_response_record: ->
    new ember.RSVP.Promise (resolve, reject) =>
      items = @value_items.copy()

      # ### FOR TESTING ONLY
      items = items.map (item) ->
        delete(item.test_id)
        item

      @set_items_pos_y(items)
      @response.set 'value.items', items
      unless @send_response_to_server
        console.info 'Saving the response to the server is turned off (options.save_response == false).'
        return resolve()
      @response.save().then =>
        totem_messages.api_success source: @, model: @response, action: 'save', i18n_path: ns.to_o 'indented:response', 'save'
        resolve()
      , (error) =>
        reject(error)
