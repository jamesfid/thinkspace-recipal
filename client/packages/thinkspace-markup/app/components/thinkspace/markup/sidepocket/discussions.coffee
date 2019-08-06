import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import scope from 'totem/scope'
import ta    from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  manager:    ember.inject.service ns.to_p('markup', 'manager')
  casespace:  ember.inject.service() # Used to call sidepocket functions
  thinkspace: ember.inject.service()

  # ### Computed properties
  is_library_open: ember.computed.reads 'manager.is_library_open'
  is_pdf:          ember.computed.reads 'manager.is_pdf'
  is_pdf_loading:  ember.computed.reads 'manager.is_pdf_loading'
  current_phase:   ember.computed.reads 'casespace.current_phase'

  other_discussions: ember.computed 'totem_scope.ownerable_record', 'casespace.current_phase', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      model   = @get 'model'
      manager = @get 'manager'
      discussions = ember.makeArray()
      if ember.isPresent(model)
        discussions = @container.lookup('store:main').filter ns.to_p('markup', 'discussion'), (discussion) =>
          manager.discussion_has_authable(discussion, model) and manager.discussion_has_ownerable(discussion) and manager.discussion_discussionable_is_in_store(discussion) and !manager.discussion_has_discussionable(discussion, model)
      resolve(discussions)
    ta.PromiseArray.create promise: promise

  phase_discussions: ember.computed 'totem_scope.ownerable_record', 'casespace.current_phase', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      model   = @get 'model'
      manager = @get 'manager'
      discussions = ember.makeArray()
      if ember.isPresent(model)
        discussions = @container.lookup('store:main').filter ns.to_p('markup', 'discussion'), (discussion) =>
          manager.discussion_has_authable(discussion, model) and manager.discussion_has_ownerable(discussion) and manager.discussion_discussionable_is_in_store(discussion) and manager.discussion_has_discussionable(discussion, model)
      resolve(discussions)
    ta.PromiseArray.create promise: promise

  discussions_sort_by: ['sort_by']
  sorted_phase_discussions: ember.computed.sort 'phase_discussions', 'discussions_sort_by'
  sorted_other_discussions: ember.computed.sort 'other_discussions', 'discussions_sort_by'

  has_no_phase_discussions: ember.computed.empty 'phase_discussions'
  has_no_other_discussions: ember.computed.empty 'other_discussions'
  has_no_discussions:       ember.computed.and 'has_no_phase_discussions', 'has_no_other_discussions'

  # ### Observers
  fetch_comments_observer: ember.observer 'totem_scope.ownerable_record', 'casespace.current_phase', ->
    @reset_all_data_loaded()
    if ember.isPresent(@get('casespace.current_phase'))
      @fetch_discussions().then =>
        @set_all_data_loaded() unless @is_destroyed()

  # ### Components
  c_library:                      ns.to_p 'markup', 'sidepocket', 'library'
  c_loader:                       ns.to_p 'common', 'loader'
  c_markup_discussion_sidepocket: ns.to_p 'markup', 'sidepocket', 'discussion'

  # ### Events
  init: ->
    @_super()
    @fetch_discussions().then (discussions) =>
      # TODO: Re-add when the 423 on users#show for a team member is solved.
      #@get('manager').set_anonymized_commenters(discussions).then =>
      @set_all_data_loaded()
      ember.run.schedule 'afterRender', =>
        @didInsertElement()

  didInsertElement:   -> @get('manager').open_comments()
  willDestroyElement: -> @get('manager').close_comments()

  click: (e) ->
    manager         = @get 'manager'
    library_comment = manager.get_selected_library_comment()
    target_class    = manager.get_library_target_class()
    if e.target.classList.contains(target_class) and library_comment
      @add_comment_to_phase(false, library_comment: library_comment)
      manager.reset_selected_library_comment()


  # ### Helpers
  is_destroyed: -> @get 'isDestroyed'

  fetch_discussions: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model   = @get('current_phase')
      options = 
        ownerable:      @totem_scope.get_ownerable_record()
        authable:       model
        discussionable: model
      @get('manager').get_discussions(options).then (discussions) =>
        resolve(discussions)

  set_anonymized_commenterables: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('discussions').then (discussions) =>
        promises = []
        discussions.forEach (discussion) =>
          promises.pushObject discussion.get_commenterables()
        ember.RSVP.Promise.all(promises).then (commenterables) =>
          commenterables = @get('taf').flatten(commenterables).uniq()
          map            = ember.Map.create()
          commenterables.forEach (commenterable, index) =>
            map.set commenterable, index
          @set 'anonymized_commenterables', map
          resolve map

  add_comment_to_phase: (edit=true, comment_options={}) ->
    manager = @get 'manager'
    phase   = @get 'model'
    options = 
      authable:       phase
      discussionable: phase
      ownerable:      @totem_scope.get_ownerable_record()
      creatorable:    @totem_scope.get_current_user()
    options.save = true if comment_options.library_comment
    manager.add_discussion(options).then (discussion) =>
      comment_options.commenterable = @totem_scope.get_current_user()
      if edit
        manager.add_comment_to_discussion_and_edit(discussion, comment_options)
      else
        manager.add_comment_to_discussion(discussion, comment_options)

  actions:
    add_comment_to_library: (comment)      -> @get('manager').add_comment_to_library(comment)
    select_library_comment: (comment)      -> @add_comment library_comment: comment

    open_library:  -> @get('manager').open_library()
    close_library: -> @get('manager').close_library()

    add_comment_to_phase: -> @add_comment_to_phase()
