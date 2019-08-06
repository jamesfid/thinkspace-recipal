import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Properties
  is_setting_expert_response: false

  # ### Components
  c_expert_selector: ns.to_p 'indented_list', 'builder', 'list', 'parts', 'expert_selector'
  c_radio:           ns.to_p 'common', 'shared', 'radio'

  is_expert:     ember.computed.reads 'model.expert'
  is_not_expert: ember.computed.not 'is_expert'

  # ### Events
  init: ->
    @_super()
    console.log "[list:settings] model: ", @get('model')

  # ### Helpers
  set_model_expert_value: (value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      model.set 'expert', value
      model.save().then =>
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  set_is_setting_expert_response:   -> @set 'is_setting_expert_response', true
  reset_is_setting_expert_response: -> @set 'is_setting_expert_response', false

  actions:
    set_is_expert: -> 
      @totem_messages.show_loading_outlet()
      @set_model_expert_value(true).then =>
        @totem_messages.hide_loading_outlet()

    set_is_not_expert: ->
      @totem_messages.show_loading_outlet()
      @set_model_expert_value(false).then =>
        @totem_messages.hide_loading_outlet()

    set_is_setting_expert_response: -> @set_is_setting_expert_response()
