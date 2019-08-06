import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (result, prop, options) ->
  return '' unless result and prop
  range = result.get("values.columns.#{prop}") or {}
  lower = range.lower or ''
  upper = range.upper or ''
  sep   = range.sep   or ' - '
  switch
    when lower and upper  then lower + sep + upper
    when lower            then lower
    when upper            then upper
    else ''

