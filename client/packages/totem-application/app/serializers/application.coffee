import ds          from 'ember-data'
import totem_scope from 'totem/scope'

export default ds.ActiveModelSerializer.extend

  # Note: serializerIntoHash is called when serializing a record
  # (e.g. save for create and update), but not called on delete or store.find.
  serializeIntoHash: (hash, type, record, options) ->
    totem_scope.serialize_into_hash(hash, type, record, options)  # add any auth query params
    @_super(hash, type, record, options)
