import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'templateable'
  ),

  title:             ta.attr('string')
  description:       ta.attr('string')
  templateable_type: ta.attr('string')
  templateable_id:   ta.attr('number')
  value:             ta.attr()

  images_thumbnail_src: ember.computed.reads 'value.images.thumbnail'