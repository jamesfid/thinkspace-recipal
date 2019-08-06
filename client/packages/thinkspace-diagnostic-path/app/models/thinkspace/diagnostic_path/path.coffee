import ember from 'ember'
import ta from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.has_many     'path_items'
    ta.store_filter 'path_items',
      on:        'path_id'
      filter_on: 'parent_id'
      is_blank:  true
      reads:     {name: 'children', filter: true, sort: 'position:asc'}
  ),

  title:          ta.attr('string')
  has_path_items: ta.attr('boolean')
  abilities:      ta.attr()