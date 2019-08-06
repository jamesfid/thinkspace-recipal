import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend
  # Services
  ttz: ember.inject.service()

  source:         ta.attr('string')
  expires_at:     ta.attr('date')

  friendly_expires_at: ember.computed 'expires_at', ->
    date = @get('expires_at')
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'MMMM Do YYYY, h:mm z', zone: @get('ttz').get_client_zone_iana()
