import ember from 'ember'
import ns    from 'totem/ns'
import ckeditor_mixin from 'totem/mixins/ckeditor'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend ckeditor_mixin,

  ckeditor_tag:  null
  editor_loaded: false

  actions:
    select: -> @sendAction 'select', @get('model')
    exit:   -> @sendAction 'select', null

    save: ->
      bucket       = @get 'model'
      instructions = (@get('editor_loaded') and @ckeditor_value()) or @get('model.instructions')
      bucket.set 'instructions', instructions
      bucket.save().then (bucket) =>
        @totem_messages.api_success source: @, model: bucket, action: 'update', i18n_path: ns.to_o('bucket', 'save')
        @send 'exit'
      , (error) =>
        @totem_messages.api_failure error, source: @, model: bucket, action: 'update'

    cancel: ->
      bucket = @get 'model'
      bucket.rollback()  if bucket.get('isDirty')
      @send 'exit'

  didInsertElement: ->
    edit_area = @$('textarea.artifact_bucket-instructions')
    return unless edit_area
    @set 'ckeditor_tag', edit_area
    options =
      height: 300
    @ckeditor_load().then =>
      edit_area.ckeditor (=> @set 'editor_loaded', true), options
    , (error) =>
      @totem_error.throw @, error
