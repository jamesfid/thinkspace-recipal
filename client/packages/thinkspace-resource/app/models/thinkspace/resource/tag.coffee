import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'taggable'
    ta.has_many 'files', reads: {sort: 'title:asc'}
    ta.has_many 'links', reads: {sort: 'title:asc'}
  ), 

  title:         ta.attr('string')
  taggable_type: ta.attr('string')
  taggable_id:   ta.attr('string')

  has_files:     ember.computed.notEmpty ta.to_p('files')
  has_links:     ember.computed.notEmpty ta.to_p('links')
  has_resources: ember.computed.or 'has_files', 'has_links'

  resources:     ember.computed 'files', 'links', -> @get('files').concat(@get('links'))

  didCreate: -> @didLoad()

  didLoad: ->
    @get(ta.to_p 'files').then (files) =>
      files.forEach (file) =>
        file.get(ta.to_p 'tags').then (tags) =>
          tags.pushObject(@) unless tags.contains(@)
    @get(ta.to_p 'links').then (links) =>
      links.forEach (link) =>
        link.get(ta.to_p 'tags').then (tags) =>
          tags.pushObject(@) unless tags.contains(@)
    @get('taggable').then (taggable) =>
      taggable.get(ta.to_p 'tags').then (tags) =>
        tags.pushObject(@) unless tags.contains(@)
