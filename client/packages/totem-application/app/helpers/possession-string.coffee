import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (str, options) ->
  last_char = str.charAt(str.length - 1)
  ends_in_s = last_char == 's' or last_char == 'S'
  if ends_in_s then return str + '\'' else return str + '\'s'
