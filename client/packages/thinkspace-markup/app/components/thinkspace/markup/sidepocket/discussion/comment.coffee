import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  markup: ember.inject.service ns.to_p('markup', 'manager')

  # ### Properties
  model:        null # Comment
  discussion:   null
  is_anonymous: null

  is_editing:     false
  is_highlighted: false
  is_collapsed:   true

  # ### Computed properties
  tagName:           'li'
  classNames:        ['ts-markup_sidepocket-comment']
  classNameBindings: ['is_collapsed:is-collapsed', 'is_child:ts-markup_sidepocket-comment-reply']

  comment_text: ember.computed.reads 'model.comment'

  can_update: ember.computed.reads 'model.can_update'
  can_reply:  false#ember.computed.empty 'model.parent_id'

  children:     ember.computed.reads 'model.comments'
  has_children: ember.computed.reads 'model.has_children'
  is_child:     ember.computed.reads 'model.is_child'
  is_new:       ember.computed.reads 'model.isNew'

  # ### Components
  c_markup_discussion_comment: ns.to_p 'markup', 'sidepocket', 'discussion', 'comment'
  c_confirmation_modal:        ns.to_p 'common', 'shared', 'confirmation', 'modal'

  get_avatar_text: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('model.commenterable').then (commenterable) =>
        if @get('is_anonymous')
          resolve @get('markup').get_anonymized_commenter(commenterable)
        else
          resolve commenterable.get('initials')

  set_avatar_text: ->
    @get_avatar_text().then (avatar_text) =>
      @set 'avatar_text', avatar_text

  keyPress: (event) ->
    return unless @get('is_editing')
    key_code = event.keyCode
    if (key_code == 10 || key_code == 13) and event.ctrlKey # control + enter
      @send 'save' 
      event.preventDefault()
      event.stopPropagation()

  didInsertElement: ->
    @set_is_overflowing()
    @set_avatar_text()

  get_$input: -> @$('textarea')

  set_is_overflowing: -> 
    ember.run.schedule 'afterRender', =>
      $value = @$('.ts-markup_sidepocket-comment-value')
      @set 'is_overflowing', $value[0].scrollWidth >  $value.innerWidth()

  focus_input: ->
    if @get('is_editing')
      ember.run.schedule 'afterRender', =>
        $input = @get_$input()
        $input.select()
        $input.submit -> return false

  # ### Events
  init: ->
    @_super()
    @get('markup').add_comment_component(@)

  willDestroyElement: -> @get('markup').remove_comment_component(@)
  
  # ### Helpers
  set_is_editing:   -> 
    @set 'is_editing', true
    @focus_input()
  reset_is_editing: -> @set 'is_editing', false
  toggle_is_editing: -> if @get('is_editing') then @reset_is_editing() else @set_is_editing()

  save_discussion: ->
    new ember.RSVP.Promise (resolve, reject) =>
      markup     = @get('markup')
      discussion = @get('discussion')
      component  = markup.get_discussion_component_for_discussion(discussion)
      component.save_record().then =>
        resolve discussion

  delete_discussion: ->
    new ember.RSVP.Promise (resolve, reject) =>
      markup     = @get('markup')
      discussion = @get('discussion')
      component  = markup.get_discussion_component_for_discussion(discussion)
      component.delete_record()
      resolve discussion

  actions:
    edit: ->
      @toggle_is_editing()

    save: ->
      model      = @get 'model'
      comment    = @get 'comment_text'
      model.set 'comment', comment
      @reset_is_editing()
      @set_is_overflowing()
      @save_discussion().then =>
        model.save()

    cancel: -> 
      @reset_is_editing()
      model      = @get('model')
      discussion = @get('discussion')
      model.deleteRecord() if model.get('isNew')
      @delete_discussion() if discussion.get('isNew')
      
    remove: ->
      model      = @get('model')
      markup     = @get('markup')
      discussion = @get('discussion')
      component  = markup.get_discussion_component_for_discussion(discussion)
      model.get(ns.to_p('comments')).then (comments) =>
        model.destroyRecord().then =>
          comments.forEach (comment) => @get_store().unloadRecord(comment)
          discussion.get(ns.to_p('comments')).then (discussion_comments) =>
            component.destroy_record() if ember.isEmpty discussion_comments

    toggle_expand: ->
      @toggleProperty 'is_collapsed'

    add_reply: ->
      @get('children').then (children) =>
        model      = @get('model')
        discussion = @get('discussion')
        markup     = @get('markup')
        options    = 
          commenterable: markup.get_current_commenterable()
          comment:       'New Reply'
          position:      @get('children.length')
          parent:        @get('model')
        markup.add_comment_to_discussion_and_edit(discussion, options)

    add_to_library: ->
      model  = @get 'model'
      markup = @get 'markup'
      markup.add_comment_to_library(model)