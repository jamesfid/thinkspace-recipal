import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import ckeditor_mixin from 'totem/mixins/ckeditor'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend ckeditor_mixin,
  # ### Properties
  classNames:    ['html_content']

  ckeditor_tag:       null
  editor_loaded:      false
  confirm_visible:    false
  confirm_changes:    null
  has_delete:         false
  error_messages:     null  # html validation errors
  validation_message: null  # model errors

  # ### Partials
  t_edit_confirm: ns.to_t 'html', 'builder', 'html', 'content', 'confirm'

  # ### Computed properties
  has_errors:         ember.computed.or 'error_messages', 'validation_message'

  # ### Events
  didInsertElement: ->
    edit_area = @$('textarea.html_html-edit-content')
    @set 'ckeditor_tag', edit_area
    options =
      height:      550
    @ckeditor_load().then =>
      edit_area.ckeditor (=> @set 'editor_loaded', true), options
    , (error) =>
      @totem_error.throw @, error

  willDestroyElement: -> @send 'cancel'


  actions:
    save:           -> @save @ckeditor_value()
    cancel:         -> @sendAction 'cancel'
    cancel_confirm: -> @confirm_off()
    next:           -> @submit_html_for_validation()

  # ### Helpers
  save: (new_html) -> @save_content(new_html)

  # CAUTION: If the user edits and changes the name of an existing input tag,
  # this will cause a element delete (old name) and element add (new name).
  # This may be correct, but if the user really wanted to 'rename' the
  # element, it has a big impact since the user responses are tied to
  # the old element name id and they will be lost.
  # Currently elements have a 'dependent: destroy' on user responses.
  save_content: (new_html) ->
    content = @get 'model'
    content.set 'html_content', new_html
    content.save().then (content) =>
      @totem_messages.api_success(source: @, model: content, action: 'save', i18n_path: ns.to_o('content', 'save'))
      @sendAction 'cancel'
    , (error) =>
      @totem_messages.api_failure(error, source: @, model: content)


  submit_html_for_validation: ->
      content  = @get 'model'
      new_html = @ckeditor_value()
      @confirm_off()
      @validate_html(content, new_html).then (result) =>
        @clear_error_messages()
        if result.errors
          @set 'error_messages', result.errors
        else
          @set 'confirm_changes', result.changes
          @set 'confirm_visible', true
          @set 'has_delete', result.changes.find (change) => change.tag == 'input' and change.action == 'delete'
      , (error) =>
        @totem_messages.api_failure error, source: @, model: content

  validate_html: (content, new_html) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null) if not new_html
      query = 
        verb:    'post'
        action:  'validate'
        model:   content
        id:      content.get('id')
        data:    {new_html: new_html}
      @totem_scope.add_authable_to_query(query.data)
      ajax.object(query).then (result) =>
        resolve(result)
      , (error) =>
        reject(error)


  confirm_off: -> @set 'confirm_visible', false

  clear_error_messages: ->
    @set 'validation_message', null
    @set 'error_messages', null