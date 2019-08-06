import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  model:            null
  all_library_tags: null
  tagName:          ''

  is_editing:  false
  is_deleting: false

  comment:   ember.computed.reads 'model.comment'
  uses:      ember.computed.reads 'model.uses'

  all_tags: ember.computed.reads 'model.all_tags'

  c_validated_input: ns.to_p('common', 'shared', 'validated_input')
  c_tag_marker:      ns.to_p('markup', 'library', 'edit', 'manager', 'marker')
  c_common_dropdown: ns.to_p('common', 'dropdown')

  dropdown_tags: ember.computed 'all_library_tags', ->
    all_library_tags = @get('all_library_tags')

    arr = []

    all_library_tags.forEach (tag) =>
      arr.pushObject({display: tag})

    arr

  last_used: ember.computed 'model.last_used', ->
    model = @get('model')
    last_used = model.get('last_used')
    moment_last_used = moment.utc(last_used)

    if last_used?
      return moment_last_used.utc().format('MMMM Do, YYYY')
    else
      return 'Not yet used'

  requires_input: ember.computed 'is_editing', 'is_deleting', ->
    @get('is_editing') or @get('is_deleting')

  actions:
    delete:        -> @set('is_deleting', true)
    edit:          -> @set('is_editing', true)

    cancel_delete: -> @set('is_deleting', false)
    cancel_edit:   -> 
      @set('comment', @get('model.comment'))
      @set('all_tags', @get('model.all_tags'))
      @set('is_editing', false)

    confirm_edit: ->
      model = @get('model')
      comment = @get('comment')

      model.set('comment', comment)
      model.set('all_tags', @get('all_tags'))
      model.save().then (saved_comment) =>
        @set('is_editing', false)
      , (error) =>
        console.log('Error in submitting edited comment.')

    confirm_delete: ->
      model = @get('model')
      model.deleteRecord()
      model.save()

    remove_tag: (tag) ->
      model = @get('model')
      @sendAction('remove_tag', model, tag)

    add_tag: (tag) ->
      model = @get('model')
      @sendAction('add_tag', model, tag.display)