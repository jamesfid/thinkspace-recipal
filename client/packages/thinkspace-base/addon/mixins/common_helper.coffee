import ember from 'ember'

export default ember.Mixin.create

  taf: ember.inject.service()

## ###
## Generic Helpers
## ###


  # prints more detailed console.log
  lg: (context=true, args...) ->
    if context 
      console.trace @toString(), args...
    else
      console.trace args...

  # returns true if all values within the provided array are present, otherwise false
  all_present: (values) ->
    for value in values 
      return false unless ember.isPresent(value)
    return true


## ###
## Promise Helpers
## ###


  # calls ember.RSVP.hash and sets the key value pairs on the provided context afterwards
  rsvp_hash_with_set: (promises, context, prepend='', append='') ->
    ember.RSVP.hash(promises).then (results) ->
      for key, value of results
        context.set "#{prepend}#{key}#{append}", value
      results

  # resolves a value if it is a promise, otherwise resolves the passed in value
  resolve_promise: (promise) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if promise.then?
        promise.then (resolution) =>
          resolve resolution
      else
        resolve promise


## ###
## Ember Model Helpers
## ###



  # sets a polymorphic relationship, id, and type
  set_polymorphic: (record, property, value, totem_scope=null) ->
    unless @all_present([record, property, value])
      console.warn "No record, property, or value provided to set_polymorphic, relationship not set.", @
      return
    totem_scope = totem_scope || @totem_scope
    record.set property, value
    record.set "#{property}_id", value.get('id')
    record.set "#{property}_type", totem_scope.get_record_path(value) if ember.isPresent totem_scope

  # save all records in an enumeration
  save_all: (records) ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises = []
      records.forEach (record) =>
        promises.pushObject(@save_if_changed(record))
      ember.RSVP.Promise.all(promises).then (saved_records) =>
        resolve(saved_records)

  # saves the record if dirty, always returns a promise
  save_if_changed: (record) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if record.get('isDirty')
        record.save().then (saved_record) =>
          resolve saved_record
      else
        resolve record

  # destroy all records in an enumeration
  destroy_all: (records) ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises = []
      records.forEach (record) =>
        promises.pushObject(record.destroyRecord())
      ember.RSVP.Promise.all(promises).then (destroyed_records) =>
        resolve(destroyed_records)

  # deletes a record if it's new, otherwise destroys it
  destroy_record: (record) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if record.get('isNew')
        record.deleteRecord()
        resolve record
      else
        record.destroyRecord().then (saved_record) =>
          resolve saved_record

  # validate all components in an enumeration and returns whether or not all components are valid
  validate_all: (validatables, debug=false) =>
    new ember.RSVP.Promise (resolve, reject) =>
      promises = []
      validatables.forEach (validatable) =>
        promises.pushObject validatable.validate().then( => 
          return validatable.get('isValid')
        ).catch( => 
          console.log "[validate_all] Validatable is not valid:", validatable, validatable.get('errors') if debug
          return validatable.get('isValid')
        )

      ember.RSVP.Promise.all(promises).then (validities) =>
        all_valid = validities.every (is_valid) -> return is_valid
        resolve all_valid


## ###
## Array Helpers
## ###

  replace_at: (array, index, obj) =>
    array.removeObject(obj)
    array.insertAt(index, obj)
    array

  push_unless_contains: (array, obj) =>
    array.pushObject(obj) unless array.contains(obj)

  # TAF helpers
  flatten: (arrays) -> @get('taf').flatten(arrays)
  intersection: (arrays) -> @get('taf').intersection(arrays)
  difference: (array1, array2) -> @get('taf').difference(array1, array2)

  # filter by multiple conditions
  filter_by: (array, conditions) ->
    return array unless ember.isPresent conditions
    for k,v of conditions
      array = array.filterBy k, v
    return array

  # find by multiple conditions
  find_by: (array, conditions) ->
    return array unless ember.isPresent conditions
    for k,v of conditions
      array = array.filterBy k, v
    return array.get('firstObject')

  minimum_for_property: (records, property) ->
    records.sortBy(property).get('firstObject')

  maximum_for_property: (records, property) ->
    records.sortBy(property).get('lastObject')

  # returns a shallow copy of a provided array
  duplicate_array: (array) ->
    copy = []
    array.forEach (a) => copy.pushObject(a)
    copy    

  # gets a has_many relationship from from a record and calls toArray()
  has_many_to_array: (context, property) ->
    new ember.RSVP.Promise (resolve, reject) =>
      context.get(property).then (records) =>
        resolve(records.toArray())

  # adds or removes objects in array1 to match array2
  sync_array: (array1, array2) ->
    array1.forEach (a) =>
      array1.removeObject(a) unless array2.contains(a)
    array2.forEach (b) =>
      array1.pushObject(b) unless array1.contains(b)

  get_each: (model, relationship) ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises = model.getEach(relationship)
      ember.RSVP.Promise.all(promises).then (results) =>
        resolve results



## ###
## Object Helpers
## ###



  # iterates an object to get the key for a provided value
  get_key_for_value: (obj, val) ->
    for k of obj
      return k if obj[k] == val
    return undefined

  # returns an array of the values of an object
  get_values: (obj) ->
    a = []
    for k, v of obj
      a.push v
    a