import ember    from 'ember'
import ta       from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'authable'
    ta.has_many    'lab:categories', reads: {sort: 'position'}
  ), 

  title:         ta.attr('string') 
  authable_type: ta.attr('string')
  authable_id:   ta.attr('number')

  edit_component: ta.to_p 'lab', 'admin', 'chart', 'admin'

  admin_exit: ->
    store = @get('store')
    store.unloadAll(ta.to_p 'lab:observation')
    store.unloadAll(ta.to_p 'lab:result')
    store.unloadAll(ta.to_p 'lab:category')
    store.unloadAll(ta.to_p 'lab:chart')
