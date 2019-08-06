import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  # ### Components
  c_builder_header:  ns.to_p 'builder', 'header'
  c_builder_toolbar: ns.to_p 'builder', 'toolbar'
  c_messages:        ns.to_p 'dock', 'messages', 'messages'