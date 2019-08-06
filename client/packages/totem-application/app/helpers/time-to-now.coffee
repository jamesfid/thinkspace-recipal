import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (date, options) ->
  moment(date).toNow()
