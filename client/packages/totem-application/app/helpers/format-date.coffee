import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (date, formatting, options) ->

  return '' unless date
  formatted_date = moment(date).format(formatting)