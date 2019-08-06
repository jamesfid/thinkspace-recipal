import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (item, collection, add) ->
  index = collection.indexOf(item)
  return index + add if ember.isPresent index
  return index