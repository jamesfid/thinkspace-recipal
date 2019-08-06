import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: 'tr'

  # ### Properties
  dropdown_collection_sort:   ['display:asc']
  dropdown_sorted_collection: ember.computed.sort 'dropdown_collection', 'dropdown_collection_sort'
  dropdown_collection:        ember.computed 'model', ->
    [{ display: 'Clone Phase', event: 'event_clone' }, { display: 'Delete Phase', event: 'event_destroy'}]

  is_destroying: false

  # ### Components
  c_dropdown:      ns.to_p 'common', 'dropdown'
  c_phase_destroy: ns.to_p 'case_manager', 'assignment', 'wizards', 'casespace', 'steps', 'phases', 'destroy'

  # ### Routes
  r_phase_edit:          ns.to_r 'case_manager', 'phases', 'edit'
  r_builder_phases_edit: ns.to_r 'builder', 'phases', 'edit'

  # ### Events
  event_clone:   ->
    phase = @get 'model'
    @totem_messages.show_loading_outlet message: "Cloning #{phase.get('title')}..."
    phase.get(ns.to_p('assignment')).then (assignment) =>
      query = 
        model:    phase
        action:   'clone'
        verb:     'post'
        data:
          phase_id:      phase.get('id')
          assignment_id: assignment.get('id') # Static to current assignment, could be from a selector in the future.
      ajax.object(query).then (payload) =>
        phase = ajax.normalize_and_push_payload 'phase', payload, single: true
        @totem_messages.hide_loading_outlet()
        @totem_messages.api_success source: @, model: phase, action: 'clone', i18n_path: ns.to_o('phase', 'clone')
      , (error) =>
        @totem_messages.hide_loading_outlet()
        @totem_messages.api_failure error, source: @, model: phase, action: 'clone'    
    , (error) => 
      @totem_messages.hide_loading_outlet()
      @totem_messages.api_failure error, source: @, model: phase, action: 'clone'


  event_destroy: -> @set 'is_destroying', true

  reset_is_destroying: -> @set 'is_destroying', false

  actions:
    select: (selected) ->
      event = selected.event
      @[event]() if ember.isPresent(event) and @[event]?

    cancel_destroy: ->  @reset_is_destroying()
    destroy:        ->
      phase = @get 'model'
      phase.deleteRecord()
      phase.save().then =>
        @reset_is_destroying()
        @totem_messages.api_success source: @, model: phase, action: 'destroy', i18n_path: ns.to_o('phase', 'destroy')
      , (error) =>
        @reset_is_destroying()
        @totem_messages.api_failure error, source: @, model: phase, action: 'destroy'

