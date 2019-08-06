import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (form, forms, options) ->
  date           = form.get('admin_at')
  formatting     = "MMM Do YYYY"
  formatted_date = moment(date).format(formatting)

  if form == forms.get('lastObject')
    return formatted_date
  else
    formatted_date = moment(date).format(formatting) + ' / '