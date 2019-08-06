import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Services
  tvo: ember.inject.service()

  # ### Components
  c_loader:                ns.to_p 'common', 'loader'
  c_list_responses:        ns.to_p 'indented_list', 'list', 'responses'
  c_list_expert_responses: ns.to_p 'indented_list', 'list', 'expert_responses'

  init: ->
    @_super()
    @get('tvo.helper').define_ready(@)
    @get('tvo.hash').set_value 'indented_list_attributes', @get('attributes')
