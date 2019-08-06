import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  layout_name: ember.computed -> @get('list.layout').toLowerCase()

  list_title: ember.computed ->
    layout_name = @get('layout_name')
    switch layout_name
      when 'diagnostic_path'     then 'Diagnostic Path'
      when 'other'               then 'Other Layout'
      else layout_name.toUpperCase()
