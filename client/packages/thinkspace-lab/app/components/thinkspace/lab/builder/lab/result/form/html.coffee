import ember from 'ember'
import ns    from 'totem/ns'
import base  from './base'
import ckeditor_mixin from 'totem/mixins/ckeditor'

export default base.extend ckeditor_mixin,

  html: null

  init: ->
    @_super()
    @edit_html() if @get('is_edit')

  init_values: -> @set 'html', @get_unbound_html()

  get_display_value: -> @get_html().htmlSafe()

  ckeditor_tag:  null
  editor_loaded: false

  get_html:        -> @get_model_value_path() or ''
  set_html: (html) -> @set_model_value_path(html)

  get_unbound_html:  -> '' + @get_html()

  form_valid: ->
    new ember.RSVP.Promise (resolve, reject) =>
      editor = @get('editor_loaded')
      return reject() unless editor  # somethings wrong if editor not loaded
      html = @ckeditor_value()
      @set_html(html)
      resolve()

  edit_html_observer: ember.observer 'is_edit', -> 
    return unless @get('is_edit')
    @edit_html()

  edit_html: ->
    ember.run.schedule 'afterRender', =>
      edit_area = $('textarea.lab-admin_edit-html-result')
      return if ember.isBlank(edit_area)
      @set 'ckeditor_tag', edit_area
      options = {height: 200, width: 450, resize_enabled: false}
      @ckeditor_load().then =>
        edit_area.ckeditor (=> @set 'editor_loaded', true), options
      , (error) =>
        @totem_error.throw @, error

  rollback: -> return
