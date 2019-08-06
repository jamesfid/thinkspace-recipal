import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (number, single, plural, options) ->
  if number == 1 then return single else return plural