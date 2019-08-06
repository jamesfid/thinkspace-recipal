import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: 'tr'
  roles:   ['read', 'update', 'owner']

  actions:
    destroy: ->
      @get('model').destroyRecord()

    save: ->
      # TODO: Why does this not refresh the state of the record?
      @get('model').save()
      
      # model = @get('model')
      # model.save().then (model) =>
      #   model.set('role', model.get('data.role'))
