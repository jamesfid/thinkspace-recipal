import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  # ### Services
  casespace: ember.inject.service()

  # ### Properties
  queryParams:    ['query_id', 'phase_settings']
  query_id:       null

  phase_settings: null

  # ### Observers
  # On a change of the phase settings, set on the casespace service for easy component usage.
  # => Need an observer to catch the initial state on a refresh.
  phase_settings_obs: ember.observer 'phase_settings', ->
    phase_settings = @get 'phase_settings'
    return unless ember.isPresent(phase_settings)
    string = decodeURIComponent(phase_settings)
    return unless ember.isPresent(string)
    obj = JSON.parse(string)
    @set_phase_settings(obj)

  # ### Components
  c_phase_show: ns.to_p 'phase', 'show'

  set_phase_settings:   (obj) -> 
    @get('casespace').set_phase_settings(obj) # Proxy any changes to the casespace service.
    @set 'phase_settings', encodeURIComponent(JSON.stringify(obj))

  reset_phase_settings: -> @set 'phase_settings', null
  reset_query_id: -> @set 'query_id', null

  actions:
    submit_phase: -> @send('submit')
