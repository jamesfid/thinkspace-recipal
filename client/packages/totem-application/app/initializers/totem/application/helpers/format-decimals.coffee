import ember from 'ember'

initializer = 
  name:  'totem-application-helpers-format-decimals'
  after: ['totem']
  initialize: (container, app) ->

    # Return a number string with decimals specified.
    ember.Handlebars.helper 'format-decimals', (number, decimals, options) ->
      number   = Number(number)
      decimals = Number(decimals)
      decimals = 1  if isNaN(decimals)
      return '' if isNaN(number)
      number.toFixed(decimals)

export default initializer
