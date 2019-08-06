import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (result, prop, options) ->
  return '' unless result and prop
  value_prop = 'values.columns.' + prop
  switch prop
    when 'title'
      description = result.get('description')
      title       = result.get('title')
      (description and "<span title='#{description}'>#{title}</span>".htmlSafe()) or title
    else
      result.get value_prop
