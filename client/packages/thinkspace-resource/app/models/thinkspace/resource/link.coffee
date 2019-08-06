import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'resourceable'
    ta.has_many    'tags', reads: {}
  ),
  
  url:               ta.attr('string')
  title:             ta.attr('string')
  resourceable_type: ta.attr('string')
  resourceable_id:   ta.attr('string')
  new_tags:          ta.attr()

  tag: ember.computed.reads ta.to_prop('tags', 'firstObject')

  didCreate: -> @didLoad()

  didLoad: ->
    @get('resourceable').then (resource) =>
      resource.get(ta.to_p 'links').then (links) =>
        links.pushObject(@) unless links.contains(@)

  set_new_tags: (tag) ->
    tag_ids = (tag and tag.get 'id') or []
    @set 'new_tags', ember.makeArray(tag_ids)
