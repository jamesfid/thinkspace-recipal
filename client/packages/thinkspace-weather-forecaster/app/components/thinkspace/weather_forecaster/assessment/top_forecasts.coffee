import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  top_forecasts_sort_by: ['score:desc', 'title:asc']
  top_forecasts_sorted:  ember.computed.sort 'top_forecasts', 'top_forecasts_sort_by'
