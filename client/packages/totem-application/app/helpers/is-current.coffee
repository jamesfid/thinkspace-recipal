import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (each_obj, current_obj, options) ->
  hash = options.hash or {}
  if each_obj and each_obj == current_obj
    string = hash.if_true or ''
  else
    string = hash.if_false or ''
  string.htmlSafe()
