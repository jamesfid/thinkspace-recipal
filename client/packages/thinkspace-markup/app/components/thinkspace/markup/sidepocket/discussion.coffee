import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  markup: ember.inject.service ns.to_p('markup', 'manager')

  # ### Properties
  model:    null # Discussion
  comments: null # [Comments...]

  is_anonymous:      false
  is_scrolled_to:    false # Has the manager scrolled to this?
  is_highlighted:    false # Is the component actively highlighted?
  is_for_phase:      false # Is the discussion related to a phase?
  classNames:        ['ts-markup_sidepocket-discussion']
  classNameBindings: ['is_scrolled_to:is-scrolled-to', 'is_highlighted:is-highlighted']

  # ### Computed properties
  comments_sort_by:     ['position']
  sorted_comments:      ember.computed.sort 'comments', 'comments_sort_by'
  # can't use a computed filter here because it doesn't watch comment's parent_id
  root_comments:        ember.computed 'comments.@each.parent_id', -> 
    @get('comments').filter (comment) -> ember.isEmpty(comment.get('parent_id'))
  sorted_root_comments: ember.computed.sort 'root_comments', 'comments_sort_by'

  discussion_number:  ember.computed 'discussions.length', 'model', ->
    discussions = @get 'discussions'
    model       = @get 'model'
    @get('markup').get_discussion_number(discussions, model)

  # ### Components
  c_markup_discussion_comment: ns.to_p 'markup', 'sidepocket', 'discussion', 'comment'
  c_confirmation_modal:        ns.to_p 'common', 'shared', 'confirmation', 'modal'

  # ### Events
  init: ->
    @_super()
    @get('markup').add_discussion_component(@)
    @set_comments().then => @set_all_data_loaded()

  willDestroyElement: -> @get('markup').remove_discussion_component(@)

  click: (e) ->
    markup          = @get 'markup'
    library_comment = markup.get_selected_library_comment()
    return unless library_comment
    model   = @get 'model' # Discussion
    options = 
      library_comment: library_comment
      commenterable:   @totem_scope.get_current_user()
    markup.reset_selected_library_comment()
    markup.add_comment_to_discussion(model, options)


  # ### Setters
  set_comments: ->
    model = @get 'model'
    model.get(ns.to_p('markup', 'comments')).then (comments) => @set 'comments', comments

  # ### Scroll helpers
  set_is_scrolled_to:   -> 
    @set 'is_scrolled_to', true
    ember.run.later =>
      @reset_is_scrolled_to() unless @get('isDestroyed') or @get('isDestroying')
    , 500
  reset_is_scrolled_to: -> @set 'is_scrolled_to', false

  # ### Highlight helpers
  set_is_highlighted:   -> @set 'is_highlighted', true
  reset_is_highlighted: -> @set 'is_highlighted', false
  get_is_highlighted:   -> @get 'is_highlighted'

  # ### Save/delete helpers
  save_record: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      if model.get('isDirty')
        model.save().then => resolve model
      else
        resolve model

  destroy_record: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.destroyRecord().then =>
        resolve model

  delete_record: ->
    model = @get('model')
    model.deleteRecord()



  actions:

    add_comment: ->
      model    = @get('model')
      markup   = @get('markup')
      options  = 
        commenterable: markup.get_current_commenterable()
        comment:       'New comment'
        position:      @get('comments.length')
      markup.add_comment_to_discussion_and_edit(model, options)

    remove: ->
      model = @get('model')
      model.get(ns.to_p('comments')).then (comments) =>
        model.destroyRecord().then =>
          comments.forEach (comment) => @get_store().unloadRecord(comment)


    highlight: ->
      model = @get 'model'
      @get('markup').highlight_discussion(model)
