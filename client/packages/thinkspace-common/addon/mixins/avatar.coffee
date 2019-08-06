import ember from 'ember'
import ta from 'totem/ds/associations'

export default ember.Mixin.create 

  avatar_url:        ta.attr('string')
  avatar_title:      ta.attr('string')
  avatar_updated_at: ta.attr('date')

  has_avatar: ember.computed.notEmpty 'avatar_title'