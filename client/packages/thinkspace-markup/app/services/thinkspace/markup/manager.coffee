import ember          from 'ember'
import ns             from 'totem/ns'
import tc             from 'totem/cache'
import ta             from 'totem/ds/associations'
import totem_messages from 'totem-messages/messages'
import totem_scope    from 'totem/scope'

export default ember.Service.extend
  # ### Services
  thinkspace: ember.inject.service()
  casespace:  ember.inject.service()
  taf:        ember.inject.service()

  # ### Properties
  library:          null
  is_library_open:  false
  is_pdf:           false
  is_pdf_loading:   false
  is_comments_open: false

  selected_library_tags: []

  # Registries
  discussion_components: []
  marker_components:     []
  comment_components:    []

  selectors:       
    comment_gutter_wrapper: '#ts-markup_comment-gutter-wrapper'
    comment_gutter_header:  '#ts-markup_comment-gutter-header'
    content_wrapper:        '#content-wrapper'

  # ### Computed properties
  # ### Opening / closing
  open_library: ->
    casespace  = @get 'casespace'
    thinkspace = @get 'thinkspace'
    casespace.set_sidepocket_width 2
    @set 'is_library_open', true
    thinkspace.minimize_toolbar()
    @bind_sticky_columns()

  close_library: ->
    casespace  = @get 'casespace'
    thinkspace = @get 'thinkspace'
    casespace.set_sidepocket_width 1
    @set 'is_library_open', false
    thinkspace.expand_toolbar()
    @bind_sticky_columns()
    @reset_selected_library_comment()
    @reset_selected_library_tags()

  open_comments: ->
    ember.run.schedule 'afterRender', =>
      @bind_sticky_columns()
      @set_is_pdf_loaded() if @get_is_pdf()
      @set_is_comments_open()

  close_comments: -> 
    @close_library()
    @reset_is_comments_open()

  bind_sticky_columns: ->
    ember.run.schedule 'afterRender', =>
      @get('thinkspace').bind_sticky_columns()

  # ### Data getters
  get_current_commenterable: ->
    totem_scope.get_current_user()

  get_comments: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      ownerable   = options.ownerable
      authable    = options.authable
      query       = 
        action:    'fetch'
        ownerable: ownerable
        authable:  authable
        auth:
          view_ids:         ownerable.get('id')
          view_type:        totem_scope.get_record_path(ownerable)
      tc.query(ns.to_p('markup', 'comment'), query).then (comments) =>
        resolve(comments)

  get_discussions: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      ownerable      = options.ownerable
      authable       = options.authable
      discussionable = options.discussionable
      query          = 
        action:    'fetch'
        ownerable: ownerable
        authable:  authable
        auth:
          view_ids:            ownerable.get('id')
          view_type:           totem_scope.get_record_path(ownerable)
          discussionable_id:   discussionable.get('id')
          discussionable_type: totem_scope.get_record_path(discussionable)
      tc.query(ns.to_p('markup', 'discussion'), query).then (discussions) =>
        resolve(discussions)

  set_anonymized_commenters: (discussions, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises = ember.makeArray()
      discussions.forEach (discussion) =>
        promises.pushObject discussion.get_commenterables()
      ember.RSVP.Promise.all(promises).then (commenterables) =>
        commenterables = @get('taf').flatten(commenterables).uniq().sortBy 'id'
        commenterables = @get('taf').shuffle(commenterables) if options.shuffle
        map = ember.Map.create()
        commenterables.forEach (commenterable, index) =>
          map.set commenterable, index + 1
        @set 'anonymized_commenters', map
        resolve map

  get_anonymized_commenter: (commenter) ->
    commenters = @get('anonymized_commenters')
    console.error '[markup:manager] get_anonymized_commetner: anonymized_commenters has not been set yet.' unless ember.isPresent commenters
    commenters.get commenter

  get_library_for_current_user: ->
    new ember.RSVP.Promise (resolve, reject) =>
      library = @get 'library'
      return resolve(library) if ember.isPresent(library)
      query = 
        action: 'fetch'
      tc.query(ns.to_p('markup', 'library'), query, single: true).then (library) =>
        @set 'library', library
        resolve(library)
      , (error) => @error error
    , (error) => @error error

  # ### Library additions
  add_comment_to_library: (comment) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null) unless ember.isPresent(comment)
      @get_library_for_current_user().then (library) =>
        text            = comment.get('comment')
        library_comment = totem_scope.get_store().createRecord ns.to_p('markup', 'library_comment'),
          comment:                           text
          uses:                              0
          last_used:                         new Date()
          user_id:                           totem_scope.get_current_user_id()
          "#{ns.to_p('markup', 'library')}": library
        library_comment.save().then =>
          resolve(library_comment)

  # ### Comment addition
  add_comment: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      comment_text  = @get_comment_from_options(options) or 'New comment'
      console.error "[markup:manager] Cannot create a comment without valid text." unless ember.isPresent(comment_text)
      commenterable = options.commenterable # Who left the comment
      console.error "[markup:manager] Cannot create a comment without a valid commenterable." unless ember.isPresent(commenterable)
      discussion    = options.discussion
      console.error "[markup:manager] Cannot create a comment without a valid discussion." unless ember.isPresent(discussion)
      parent        = options.parent
      position      = options.position or 0
      save          = options.save or false

      # Parent is set up front to avoid the 'warp to top, then back down' issue in the list.
      # => parent_id presence is used in the 'is_child' check, so need to set it here, too.
      if ember.isPresent(parent)
        comment = @get_store().createRecord ns.to_p('markup', 'comment'),
          'thinkspace/markup/discussion': discussion,
          'discussion_id':                discussion.get('id'),
          'thinkspace/markup/parent':     parent,
          'parent_id':                    parent.get('id'),
          position:                       position
          created_at:                     new Date(),
          comment:                        comment_text
      else
        comment = @get_store().createRecord ns.to_p('markup', 'comment'),
          'thinkspace/markup/discussion': discussion,
          'discussion_id':                discussion.get('id'),
          position:                       position
          created_at:                     new Date(),
          comment:                        comment_text
      @set_polymorphic_on_record comment, commenterable, 'commenterable'
      if save
        comment.save().then => resolve(comment)
      else
        resolve(comment)

  add_discussion: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      value          = options.value or new Object
      authable       = options.authable
      ownerable      = options.ownerable
      creatorable    = options.creatorable
      discussionable = options.discussionable
      console.error "[markup:manager] Cannot create a discussion without a valid authable."       unless ember.isPresent(authable)
      console.error "[markup:manager] Cannot create a discussion without a valid ownerable."      unless ember.isPresent(ownerable)
      console.error "[markup:manager] Cannot create a discussion without a valid creatorable."    unless ember.isPresent(creatorable)
      console.error "[markup:manager] Cannot create a discussion without a valid discussionable." unless ember.isPresent(discussionable)
      discussion = @get_store().createRecord ns.to_p('markup', 'discussion'),
        value:          value
        authable:       authable
        ownerable:      ownerable
        creatorable:    creatorable
        discussionable: discussionable
      # Set the non-relationship _id, _type values for store filter.
      @set_polymorphic_on_record discussion, authable,       'authable'
      @set_polymorphic_on_record discussion, ownerable,      'ownerable'
      @set_polymorphic_on_record discussion, creatorable,    'creatorable'
      @set_polymorphic_on_record discussion, discussionable, 'discussionable'
      if options.save
        discussion.save().then => resolve(discussion)
      else
        resolve(discussion)

  add_comment_to_discussion_and_edit: (model, options={}) ->
    options.edit = true
    @add_comment_to_discussion(model, options)

  add_comment_to_discussion: (model, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      console.error '[markup:manager] WARNING: Commenterable not passed in with options for `add_comment_and_edit_discussion`' unless options.commenterable
      options.discussion = model
      options.save       = true if options.library_comment
      @add_comment(options).then (comment) =>
        ember.run.schedule 'afterRender', =>
          # Do not edit the comment right away unless specified.
          if options.edit
            component = @get_comment_component_for_comment(comment)
            component.set_is_editing() if component
          discussion_component = @get_discussion_component_for_discussion(model)
          @scroll_sidepocket_to_component(discussion_component)

  get_comment_from_options: (options={}) ->
    library_comment = options.library_comment
    comment         = options.comment
    if ember.isPresent(library_comment) then return library_comment.get('comment') else return comment

  # ### Scroll helpers
  scroll_sidepocket_to_discussion: (model) ->
    component = @get_discussion_component_for_discussion(model)
    @scroll_sidepocket_to_component(component)

  scroll_sidepocket_to_component: (component) ->
    el = @get_$comment_gutter_wrapper()
    @scroll_el_to_component(el, component)

  scroll_content_wrapper_to_component: (component) ->
    el = @get_$content_wrapper()
    @scroll_el_to_component(el, component)

  scroll_el_to_component: (el, component) ->
    return unless component
    $component    = component.$()
    scroll_top    = $component.position().top
    el.animate
      scrollTop: scroll_top
    component.set_is_scrolled_to() if typeof component.set_is_scrolled_to == 'function' and !component.get('isDestroying') and !component.get('isDestroyed')

  # ### Highlight helpers
  highlight_discussion: (model) ->
    components = @get_discussion_components()
    discussion = null
    components.forEach (component) =>
      if component.get('model') == model
        component.set_is_highlighted()
        discussion = component
      else
        component.reset_is_highlighted()
    components = @get_marker_components()
    marker     = null
    components.forEach (component) =>
      if component.get('model') == model
        component.set_is_highlighted()
        marker = component
      else
        component.reset_is_highlighted()
    @scroll_sidepocket_to_component(discussion)  if discussion
    @scroll_content_wrapper_to_component(marker) if marker

  # ### Helpers
  set_polymorphic_on_record: (record, polymorphic, type) ->
    record.set "#{type}_id",   polymorphic.get('id')
    record.set "#{type}_type", totem_scope.get_record_path(polymorphic)

  # ### PDF helpers
  set_is_pdf:   -> @set 'is_pdf', true
  reset_is_pdf: -> @set 'is_pdf', false
  get_is_pdf:   -> @get 'is_pdf'

  set_is_pdf_loading:   -> @set 'is_pdf_loading', true
  reset_is_pdf_loading: -> @set 'is_pdf_loading', false
  get_is_pdf_loading:   -> @get 'is_pdf_loading'

  set_is_pdf_loaded: -> @reset_is_pdf_loading()

  # ### Selector helpers
  get_comment_gutter_wrapper_selector: -> @get 'selectors.comment_gutter_wrapper'
  get_$comment_gutter_wrapper:         -> $(@get_comment_gutter_wrapper_selector())
  get_comment_gutter_header_selector:  -> @get 'selectors.comment_gutter_header'
  get_$comment_gutter_header:          -> $(@get_comment_gutter_header_selector())
  get_content_wrapper_selector:        -> @get 'selectors.content_wrapper'
  get_$content_wrapper:                -> $(@get_content_wrapper_selector())

  # ### Measuring
  get_header_height: ->
    $header = @get_$comment_gutter_header()
    return 0 unless ember.isPresent($header)
    $header.outerHeight()

  # ### Component registries
  # TODO: Could type be inferred from component?
  add_component_to_registry: (type, component) ->
    components = @["get_#{type}_components"]()
    components.pushObject(component) unless components.contains(component)

  remove_component_from_registry: (type, component) ->
    components = @["get_#{type}_components"]()
    components.removeObject(component) if components.contains(component)

  add_discussion_component:    (component) -> @add_component_to_registry('discussion', component)
  remove_discussion_component: (component) -> @remove_component_from_registry('discussion', component)
  reset_discussion_components: -> @set 'discussion_components', new Array
  get_discussion_components:   -> @get 'discussion_components'

  add_marker_component:    (component) -> @add_component_to_registry('marker', component)
  remove_marker_component: (component) -> @remove_component_from_registry('marker', component)
  reset_marker_components: -> @set 'marker_components', new Array
  get_marker_components:   -> @get 'marker_components'

  add_comment_component:    (component) -> @add_component_to_registry('comment', component)
  remove_comment_component: (component) -> @remove_component_from_registry('comment', component)
  reset_comment_components: -> @set 'comment_components', new Array
  get_comment_components:   -> @get 'comment_components'

  # TODO: On register, could add to a model-based map to not filter on each request.
  get_marker_component_for_discussion: (model) ->
    console.log "[markup:manager] Getting marker components for discussion: ", model
    @get_marker_components().findBy 'model', model

  get_discussion_component_for_discussion: (model) ->
    console.log "[markup:manager] Getting discussion components for discussion: ", model
    @get_discussion_components().findBy 'model', model

  get_comment_component_for_comment: (model) ->
    console.log "[markup:manager] Getting comment components for comment: ", model
    @get_comment_components().findBy 'model', model

  # ### Discussion filters
  discussion_discussionable_is_in_store: (discussion) ->
    discussionable = tc.peek_record totem_scope.standard_record_path(discussion.get('discussionable_type')), discussion.get('discussionable_id')
    ember.isPresent(discussionable)

  discussion_has_ownerable: (discussion, ownerable=null) ->
    ownerable = totem_scope.get_ownerable_record() unless ownerable
    @discussion_has_polymorphic(discussion, ownerable, 'ownerable')

  discussion_has_authable: (discussion, authable) ->
    @discussion_has_polymorphic(discussion, authable, 'authable')

  discussion_has_discussionable: (discussion, discussionable) ->
    @discussion_has_polymorphic(discussion, discussionable, 'discussionable')

  discussion_has_polymorphic: (discussion, record, type) ->
    record_type      = totem_scope.standard_record_path(record)
    record_id        = parseInt record.get 'id'
    polymorphic_type = totem_scope.standard_record_path discussion.get "#{type}_type" 
    polymorphic_id   = parseInt discussion.get "#{type}_id"
    ember.isEqual(record_type, polymorphic_type) and ember.isEqual(record_id, polymorphic_id)

  # ### Library interactions
  set_selected_library_comment:   (library_comment) -> @set 'selected_library_comment', library_comment
  reset_selected_library_comment: -> @set 'selected_library_comment', null
  get_selected_library_comment:   -> @get 'selected_library_comment'

  add_selected_library_tag:   (tag) -> 
    tags = @get_selected_library_tags()
    tags.pushObject(tag) unless tags.contains(tag)
  remove_selected_library_tag: (tag) ->
    tags = @get_selected_library_tags()
    tags.removeObject(tag) if tags.contains(tag)
  reset_selected_library_tags: -> @set 'selected_library_tags', new Array
  get_selected_library_tags:   -> @get 'selected_library_tags'

  get_library_target_class: -> 'ts-markup_library-target'

  # ### Discussion number
  get_discussion_number: (discussions, discussion) -> discussions.indexOf(discussion) + 1

  # ### Comment openers
  set_is_comments_open:   -> @set 'is_comments_open', true
  reset_is_comments_open: -> @set 'is_comments_open', false
  get_is_comments_open:   -> @get 'is_comments_open'

  # ### Misc. helpers
  save_comment: (comment) -> comment.save()
  get_store:    -> @container.lookup('store:main')