import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-builder/components/wizard/steps/base'

export default base.extend
  # ### Properties
  title: ember.computed.reads 'builder.model.title'
  instructions: ember.computed.reads 'builder.model.instructions'
  # ### Callbacks
  callbacks_next_step: ->
    new ember.RSVP.Promise (resolve, reject) =>
      title   = @get 'title'
      model   = @get 'model'
      instructions  = @get 'instructions'
      builder = @get 'builder'
      model.set 'title', title
      builder.set_is_saving()
      model.save().then =>
        builder.reset_is_saving()
        @get('builder').transition_to_next_step()
        resolve()
      , (error) => @get('builder').encountered_save_error(error)
    , (error) => console.error 'Error caught in details step.'

