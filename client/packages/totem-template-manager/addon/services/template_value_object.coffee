import ember from 'ember'
import tvo_helper   from 'totem-template-manager/tvo/helper'
import tvo_value    from 'totem-template-manager/tvo/value'
import tvo_hash     from 'totem-template-manager/tvo/hash'
import tvo_status   from 'totem-template-manager/tvo/status'
import tvo_template from 'totem-template-manager/tvo/template'
import tvo_section  from 'totem-template-manager/tvo/section'

export default ember.Service.extend

  regenerate_view: null  # value does not change but observers can watch for a notifyPropertyChange (via 'tvo.regenerate()') and regenerate their views

  regenerate: -> @notifyPropertyChange 'regenerate_view'

  clear: -> @_clear()

  get_path_value: (path)        -> @get path
  set_path_value: (path, value) -> @set path, value

  # ###
  # ### Common Helpers.
  # ###

  guid_for: (source) -> ember.guidFor(source) or 'bad_guid'

  generate_guid: -> ember.generateGuid()

  tag_attribute_hash: ($tag) ->
    hash            = {}
    attrs           = $tag.prop('attributes') or []
    hash[attr.name] = attr.nodeValue  for attr in attrs
    hash

  tag_kind:  ($tag) -> $tag.prop('tagName').toLowerCase() # e.g. input, textarea, div, etc.
  tag_name:  ($tag) -> $tag.attr('name')
  tag_title: ($tag) -> $tag.attr('title')
  tag_type:  ($tag) -> $tag.attr('type')
  tag_class: ($tag) -> $tag.attr('class') or ''

  component_bind_properties: (path, hash) ->
    keys = []
    keys.push key for own key of hash
    bind = ''
    return bind if ember.isBlank(keys)
    bind += " #{key}=tvo.#{path}.#{key}"  for key in keys
    bind

  add_property: (options) -> @_add_property(options)

  stringify: (hash) -> JSON.stringify(hash)

  attribute_value_array: (value) -> value and value.split(' ').map (part) -> part.trim()

  is_object_valid: (object) -> object and (not object.get('isDestroyed') and not object.get('isDestroying'))

  # ###
  # ### Internal.  Use with caution if call outside of above functions.
  # ###

  tvo_properties: [
    {property: 'helper',   class: tvo_helper, create_once: true}
    {property: 'value',    class: tvo_value}
    {property: 'hash',     class: tvo_hash}
    {property: 'status',   class: tvo_status}
    {property: 'template', class: tvo_template}
    {property: 'section',  class: tvo_section}
  ]

  _get_tvo_properties: -> @get 'tvo_properties'

  _reset_object: (options={}) ->
    prop = options.property
    if options.create_once == true
      @_create_object(options)  unless @get(prop)  # only do once per tvo
    else
      @_destroy_object(prop)
      @_create_object(options)

  _destroy_object: (prop) ->
    obj = @get(prop)
    obj.destroy()  if obj

  _create_object: (options) ->
    prop  = options.property
    klass = options.class
    @set prop, klass.create
      tvo:          @
      tvo_property: prop

  _clear: ->
    @_reset_object(obj) for obj  in (@_get_tvo_properties() or [])
    @_destroy_added_properties()

  # Property will exists until the next tvo.clear().
  added_properties: null
  _get_added_properties: -> @get 'added_properties'
  _add_property: (options) ->
    added = ember.makeArray @_get_added_properties()
    added.push(options.property)
    @set 'added_properties', added
    @_create_object(options)
  _destroy_added_properties: ->
    for prop in (@_get_added_properties() or [])
      @_destroy_object(prop)
      delete(@[prop])
    @set 'added_properties', null


  toString: -> 'TemplateValueObject'
