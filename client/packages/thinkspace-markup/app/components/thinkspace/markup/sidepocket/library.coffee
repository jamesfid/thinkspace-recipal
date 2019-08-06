import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  manager: ember.inject.service ns.to_p('markup', 'manager')

  # ### Properties
  model:   null

  # ### Computed properties
  wrapped_library_tags: ember.computed 'model', 'model.all_tags', -> 
    tags    = ember.makeArray @get('model.all_tags')
    wrapped = new Array
    tags.forEach (tag) => wrapped.push {display: tag}
    wrapped = wrapped.sortBy('display')
    wrapped.insertAt(0, {display: 'All', reset: true})
    wrapped
    
  filtered_library_comments: ember.computed 'model', 'model.comments', 'manager.selected_library_tags.@each', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      model   = @get 'model'
      return resolve(new Array) unless model
      manager = @get 'manager'
      tags    = manager.get_selected_library_tags()
      model.get(ns.to_p('library_comments')).then (comments) =>
        return resolve(comments) if ember.isEmpty(tags)
        filtered = comments.filter (comment) =>
          comment_tags = comment.get('all_tags')
          has_match    = false
          comment_tags.forEach (comment_tag) =>
            has_match = true if tags.contains(comment_tag)
          has_match
        resolve filtered
    ta.PromiseArray.create promise: promise

  selected_library_tags:         ember.computed.reads    'manager.selected_library_tags'
  has_filtered_library_comments: ember.computed.notEmpty 'filtered_library_comments'
  has_selected_library_tags:     ember.computed.notEmpty 'manager.selected_library_tags'

  # ### Components
  c_library_comment: ns.to_p 'markup', 'sidepocket', 'library', 'comment'
  c_dropdown:        ns.to_p 'common', 'dropdown'
  c_loader:          ns.to_p 'common', 'loader'

  # ### Routes
  r_libraries_edit: ns.to_r 'markup', 'libraries', 'edit'

  # ### Events
  init: ->
    @_super()
    @get('manager').get_library_for_current_user().then (library) =>
      library.get(ns.to_p('library_comments')).then =>
        @set 'model', library
        @set_all_data_loaded()

  actions:
    select: (comment) ->
      manager = @get 'manager'
      if comment == manager.get_selected_library_comment()
        manager.reset_selected_library_comment()
      else
        manager.set_selected_library_comment(comment)

    select_tag: (tag) ->
      return unless tag 
      if tag.reset
        @get('manager').reset_selected_library_tags()
      else
        tag = tag.display
        @get('manager').add_selected_library_tag(tag)

    deselect_tag: (tag) ->
      return unless tag
      @get('manager').remove_selected_library_tag(tag)