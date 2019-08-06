import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
import ckeditor_mixin from 'totem/mixins/ckeditor'

export default base.extend ckeditor_mixin,
  # ### Properties
  ckeditor_tag:       null
  editor_loaded:      false

  # ### Components
  c_loader: ns.to_p 'common', 'loader'

  # ### Events
  didInsertElement: ->
    edit_area = @$('textarea.bucket_instructions-content')
    @set 'ckeditor_tag', edit_area
    options =
      height: 250
    @ckeditor_load().then =>
      edit_area.ckeditor (=> @set 'editor_loaded', true), options
    , (error) =>
      @totem_error.throw @, error

  willDestroyElement: -> @send 'cancel'

  actions:
    save:           -> 
      content = @ckeditor_value()
      model   = @get 'model'
      model.set 'instructions', content

      @totem_messages.show_loading_outlet()
      model.save().then =>
        @totem_messages.hide_loading_outlet()
        @sendAction 'cancel'

    cancel:         -> @sendAction 'cancel'