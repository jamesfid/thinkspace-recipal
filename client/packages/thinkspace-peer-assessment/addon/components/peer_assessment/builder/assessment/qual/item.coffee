import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'

export default ember.Object.extend
  # ### Properties
  model:         null
  id:            null
  label:         null
  type:          null
  feedback_type: null

  assessment:   null

  # ### Computed properties
  is_textarea: ember.computed.equal 'type', 'textarea'
  is_text:     ember.computed.equal 'type', 'text'

  # ### Events
  init: ->
    @_super()
    @map_model_properties()

  # ### Helpers
  map_model_properties: ->
    # Establish bindings for the template to use to access model properties more easily.
    model = @get 'model'
    @set 'id',            model.id
    @set 'label',         model.label
    @set 'type',          model.type
    @set 'feedback_type', model.feedback_type

  # ### Setters
  set_value: (property, value) ->
    fn = "set_#{property}"
    return unless @[fn]?
    @[fn](value)
    @map_model_properties()

  set_id:            (id) ->     util.set_path_value @, 'model.id', parseInt(id)
  set_label:         (label) ->  util.set_path_value @, 'model.label', label
  set_type:          (type) ->   util.set_path_value @, 'model.type', type
  set_feedback_type: (type) ->   util.set_path_value @, 'model.feedback_type', type
