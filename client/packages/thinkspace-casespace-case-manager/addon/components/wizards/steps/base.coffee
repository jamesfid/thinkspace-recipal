import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  step:         '' # Step name for the current step.
  default_step: ember.computed -> @get('steps.firstObject')
  is_editing:   ember.computed.not 'model.isNew'

  # Services
  thinkspace:     ember.inject.service()
  wizard_manager: ember.inject.service()
  
  # Components
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  c_radio:           ns.to_p 'common', 'shared', 'radio'
  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'

  init: ->
    @_super()
    page_title = @get 'page_title'
    @get('wizard_manager').set_page_title(page_title)  if ember.isPresent(page_title)

  wizard_ajax: (query, model) ->
    new ember.RSVP.Promise (resolve, reject) =>
      store = @get_store()
      ajax.object(query).then (payload) =>
        payload_type = ns.to_p(ember.Inflector.inflector.pluralize(model))
        type         = ns.to_p(model)
        records      = payload[payload_type]
        return resolve([])  if ember.isBlank(records)
        normalized = records.map (record) => store.normalize(type, record)
        records    = store.pushMany(type, normalized)
        resolve(records)
      , (error) => reject(error)

  get_store: -> @container.lookup('store:main')

  actions:
    complete: -> @get('wizard_manager').send_action 'complete_step', @get('step')
    back:     -> @get('wizard_manager').send_action 'back', @get('step')

    go_to_step: (step) -> @get('wizard_manager').send_action 'go_to_step', step
