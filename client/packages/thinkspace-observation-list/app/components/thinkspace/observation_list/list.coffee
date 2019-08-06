import ember from 'ember'
import ns    from 'totem/ns'
import m_dragula      from 'thinkspace-observation-list/mixins/dragula'
import m_sort_order   from 'thinkspace-observation-list/mixins/sort_order'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend m_dragula, m_sort_order,
  classNames: ['ts-componentable']

  tvo:        ember.inject.service()
  thinkspace: ember.inject.service()

  container_class: 'obs-list_list'

  init: ->
    @_super()
    @get('tvo.helper').register @, actions: 
      'select-text':     'create_observation'
      'obs-list-values': 'get_observation_list_values'
      'itemables':       'get_observation_list_observations'

  didInsertElement: -> 
    @_super()
    @init_dragula()
    @get('thinkspace').set_component_column_as_sticky(@)

  t_title_region:     ns.to_t 'observation_list', 'list', 'title_region'
  c_observation_show: ns.to_p 'observation_list', 'observation', 'show'
  c_observation_new:  ns.to_p 'observation_list', 'observation', 'new'

  ownerable_observations: ember.computed ->
    @get('tvo.helper').ownerable_view_association_promise_array @, association: 'observations', ready: true

  is_view_only: ember.computed.reads 'viewonly'

  is_creating_observation: false

  has_path: ember.computed.bool 'attributes.has_path'

  actions:
    create_observation_start:   -> @set 'is_creating_observation', true
    create_observation_cancel:  -> @set 'is_creating_observation', false
    create_observation: (value) -> @create_observation(value)

    update_observation:  (observation) -> @update_observation(observation)
    destroy_observation: (observation) -> @remove_observation(observation)

  get_observation_list_values: ->
    new ember.RSVP.Promise (resolve, reject) =>
      resolve @get('model.observations').mapBy('value')
    , (error) => reject(error)

  get_observation_list_observations: ->
    new ember.RSVP.Promise (resolve, reject) =>
      resolve @get('model.observations')
    , (error) => reject(error)

  call_section_action_component: (section, action, observation) ->
    new ember.RSVP.Promise (resolve, reject) =>
      tvo = @get('tvo')
      return resolve() unless tvo.section.has_action(section, action)
      tvo.section.call_action(section, action, observation).then => resolve()

  create_observation: (value) ->
    list        = @get 'model'
    max         = list.get 'max_observation_position'
    position    = parseInt(max)
    position    = (isNaN(position) and 1) or position + 1
    category    = if position % 2 == 0 then 'Data' else 'History'
    observation = list.store.createRecord ns.to_p('observation'),
      position:       position
      value:          value
      category:       category
      created_at:     new Date()
    @totem_scope.set_record_ownerable_attributes(observation)
    observation.set ns.to_p('list'), list
    observation.save().then (observation) =>
      @totem_messages.api_success source: @, model: observation, action: 'save', i18n_path: ns.to_o('observation', 'save')
    , (error) =>
      @totem_messages.api_failure error, source: @, model: observation
    @send 'create_observation_cancel'

  update_observation: (observation) ->
    observation.save().then (observation) =>
      @totem_messages.api_success source: @, model: observation, action: 'save', i18n_path: ns.to_o('observation', 'save')
    , (error) =>
      @totem_messages.api_failure error, source: @, model: observation

  remove_observation: (observation) ->
    # when another component registers a 'remove_itemable' section action; call it with the 'remove' action
    @call_section_action_component('remove_itemable', 'remove', observation).then =>
      list = @get 'model'
      @unload_observation_notes(observation)  # Rails dependent: destroy so just unload
      observation.deleteRecord()  # delete in the store
      observation.save().then (observation) =>
        @totem_messages.api_success source: @, model: observation, action: 'delete', i18n_path: ns.to_o('observation', 'destroy')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: observation

  unload_observation_notes: (observation) ->
    observation.get(ns.to_p 'observation_notes').then (notes) =>
      notes.forEach (note) =>
        note.unloadRecord()
