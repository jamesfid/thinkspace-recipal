import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (str, item, collection, delimeter, options) ->
  index = collection.indexOf(item)
  size  = collection.get('length')
  return if index == size - 1 then str else str + delimeter
