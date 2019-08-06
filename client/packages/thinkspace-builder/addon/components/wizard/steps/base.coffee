import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  all_data_loaded: false

  # ### Computed Properties
  model: ember.computed.reads 'builder.model'

  # ### Components
  c_loader: ns.to_p 'common', 'loader'

  # ### Helpers
  get_store:           -> @container.lookup('store:main')
  set_all_data_loaded: -> @set 'all_data_loaded', true

  error: (message) -> console.warn "[builder] ERROR: #{message}"

  actions:
    next: ->
      console.error '[wizard:steps:base] Object does not respond to `callbacks_next_step`' unless @callbacks_next_step?
      @callbacks_next_step()

    next_without_callback: ->
      @get('builder').transition_to_next_step()

    back: ->
      # TODO: Should this be a callback to save data, etc?
      @get('builder').transition_to_previous_step()
