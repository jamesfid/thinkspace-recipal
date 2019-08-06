import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['html_content']

  tvo: ember.inject.service()

  layout:   ember.computed -> @get('template')
  template: ember.computed -> ember.Handlebars.compile @get('html_content')

  totem_data_config: ability: {ajax_source: true}

  # # ### Computed properties
  # layout:   ember.computed -> @get('template')
  # template: ember.computed -> ember.Handlebars.compile @get('html_content')