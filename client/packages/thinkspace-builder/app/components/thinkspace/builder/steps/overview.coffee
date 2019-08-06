import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base  from 'thinkspace-builder/components/wizard/steps/base'

export default base.extend
  # ### Services
  ttz: ember.inject.service()

  # ### Computed properties
  model:            ember.computed.reads 'builder.model'
  title:            ember.computed.reads 'model.title'
  release_at:       ember.computed.reads 'model.release_at'
  due_at:           ember.computed.reads 'model.due_at'

  friendly_release_at: ember.computed 'release_at', ->
    date = @get 'release_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'MMMM Do YYYY, h:mm z', zone: @get('ttz').get_client_zone_iana()

  friendly_due_at: ember.computed 'due_at', ->
    date = @get 'due_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'MMMM Do YYYY, h:mm z', zone: @get('ttz').get_client_zone_iana()

  # ### Routes
  r_cases_details:   ns.to_r 'builder', 'cases', 'details'
  r_cases_phases:    ns.to_r 'builder', 'cases', 'phases'
  r_cases_logistics: ns.to_r 'builder', 'cases', 'logistics'
  r_phases_edit:     ns.to_r 'builder', 'phases', 'edit'

  # ### Components
  c_phase:        ns.to_p 'builder', 'steps',  'parts',  'phases', 'phase'
  c_phase_errors: ns.to_p 'builder', 'shared', 'phases', 'errors'

  # ### Events
  init: ->
    @_super()
    @set_phases().then => @set_all_data_loaded()

  # ### Helpers
  set_phases: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      @tc.query(ns.to_p('assignment'), {id: model.get('id'), action: 'load'}, single: true).then =>
        model.get('active_phases').then (phases) =>
          @set 'phases', phases
          resolve()
        , (error) => @error(error)
      , (error) => @error(error)
    , (error) => @error(error)

  actions:
    activate: ->
      @totem_messages.show_loading_outlet()
      @get('model').activate().then =>
        @totem_messages.hide_loading_outlet()

    inactivate: ->
      @totem_messages.show_loading_outlet()
      @get('model').inactivate().then =>
        @totem_messages.hide_loading_outlet()

    exit: -> @get('builder').transition_to_assignment()
