import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  title: ember.computed.reads 'model.title'


  actions:
    save: ->
      model = @get 'model'
      title = @get 'title'
      model.set 'title', title
      model.save().then =>
        @sendAction 'cancel'

    cancel: -> @sendAction 'cancel'