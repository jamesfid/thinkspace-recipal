import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import ta    from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  library:          null
  close_action:     null
  library_empty:    false
  selected_tags:    []
  model:            null

  sort_text: [{display: 'Most Used'}, {display:'Recently Used'}, {display:'Recently Created'}, {display: 'A - Z'}]

  selected_sort: 'Most Used'

  is_adding_category:        false
  is_adding_library_comment: false
  all_selected:              true

  add_comment_class:  'keypress-comment-input'
  add_category_class: 'keypress-category-input'

  tags_component: null

  new_comment_text: ''

  c_validated_input:  ns.to_p('common', 'shared', 'validated_input')
  t_library_tagger:   ns.to_t('markup', 'library', 'edit', 'manager', 'tagger')
  c_clickable_tag:    ns.to_p('markup', 'library', 'edit', 'manager', 'tag')
  c_checkbox:         ns.to_p('common', 'shared', 'checkbox')
  c_common_dropdown:  ns.to_p('common', 'dropdown')
  c_library_tags:     ns.to_p('markup', 'library', 'edit', 'manager', 'tags')
  c_library_comments: ns.to_p('markup', 'library', 'edit', 'manager', 'comments')

  library_all_tags: ember.observer 'model.all_tags', ->
    model = @get('model')

  sorted_comments: ember.computed 'selected_sort', 'model.comments.length', ->
    selected_sort = @get('selected_sort')
    model = @get('model')

    if ember.isPresent(model)
      promise = new ember.RSVP.Promise (resolve, reject) =>
        model.get('comments').then (library_comments) =>
          if selected_sort == 'Most Used'
            sorted_arr = library_comments.sortBy('uses')
            sorted_arr.reverse()
          else if selected_sort == 'Recently Used'
            sorted_arr = library_comments.sortBy('last_used')
            sorted_arr.reverse()
          else if selected_sort == 'Recently Created'
            sorted_arr = library_comments.sortBy('created_at')
            sorted_arr.reverse()
          else if selected_sort == 'A - Z'
            sorted_arr = library_comments.sortBy('comment')

          resolve(sorted_arr)

      ta.PromiseArray.create promise: promise

  sorted_and_filtered_comments: ember.computed 'sorted_comments.length', 'selected_tags.length', ->
    sorted_comments = @get('sorted_comments')
    model = @get('model')
    selected_tags = @get('selected_tags')
    all_selected = @get('all_selected')

    promise = new ember.RSVP.Promise (resolve, reject) =>
      # Process selected tags and filter.
      comments = sorted_comments.filter (comment) =>
        tags    = comment.get('all_tags')
        has_tag = false
        if all_selected
          has_tag = true
        else
          selected_tags.forEach (tag) =>
            has_tag = true if tags.contains(tag)
        has_tag
        
      resolve(comments)

    ta.PromiseArray.create promise: promise

  comments_obs: ember.observer 'model.comments.length', 'selected_tags.length', ->
    if ember.isPresent(@get('model'))
      promise = new ember.RSVP.Promise (resolve, reject) =>
        model         = @get('model')
        selected_tags = @get('selected_tags')
        all_selected  = @get('all_selected')
        if ember.isPresent(model)
          model.get('comments').then (comments) =>
            if ember.isEmpty(comments) # Library is empty.
              @set 'library_empty', true
              return resolve()
            if ember.isEmpty(selected_tags) and !all_selected # No tags selected.
              @set 'library_empty', false
              return resolve() 
            # Process selected tags and filter.
            comments = comments.filter (comment) =>
              tags    = comment.get('all_tags')
              has_tag = false
              if all_selected
                has_tag = true
              else
                selected_tags.forEach (tag) =>
                  has_tag = true if tags.contains(tag)
              has_tag
            @set 'library_comments', comments
            resolve()
          , (error) =>
            reject(error)
        else
          reject()

  all_tags_obs: ember.observer 'selected_tags.length', ->
    ## If no tags are selected, we want to select all of them.
    selected_tags = @get('selected_tags')
    all_selected  = @get('all_selected')

    if ember.isEmpty(selected_tags)
      @set('all_selected', true)

    else if all_selected
      @set('all_selected', false)

  tags_did_change: ->
    component = @get('tags_component')

    return unless ember.isPresent(component)

    component.tags_did_change()

  get_tag_query: (model, action, all_tags, comment) ->
    query =
      model:  model
      id:     model.get('id')
      verb:   'put'
      action: action
      data:   
        all_tags: all_tags
        comment_id: comment.get('id')

  keyPress: (e) ->
    if ember.isEqual(e.keyCode, 13)
      @send('add_library_comment')

  actions:
    exit: -> window.history.back()
    
    register_tags_component: (component) ->
      @set('tags_component', component)

    toggle_add_comment: ->
      @toggleProperty('is_adding_library_comment')

    add_library_comment: ->
      comment_text     = @get('new_comment_text')
      model            = @get('model')
      current_user     = @totem_scope.get_current_user_id()
      library_comments = @get('library_comments')

      if comment_text != '' and model?
        library_comment = @totem_scope.get_store().createRecord(ns.to_p('markup', 'library_comment'))

        library_comment.set('comment',   comment_text)
        library_comment.set('library',   model)
        library_comment.set('user_id',   current_user)
        library_comment.set('uses',      0)
        library_comment.set('last_used', null)

        library_comment.save().then (saved_comment) =>
          @totem_messages.api_success source: @, model: library_comment, action: 'save', i18n_path: ns.to_o('comment', 'save')
          @set('new_comment_text', '')

      @set('is_adding_library_comment', false)

    select_tag: (tag) ->
      selected_tags = @get('selected_tags')
      if selected_tags.contains(tag)
        selected_tags.removeObject(tag)
      else
        selected_tags.pushObject(tag)

    toggle_tag_selection: (tag) ->
      @send('select_tag', tag)

    all_selected: ->
      @set('all_selected', true)
      @set('selected_tags', ember.makeArray())

    remove_comment_tag: (comment, tag) ->
      all_tags  = comment.get('all_tags')
      model     = @get('model')

      if all_tags.contains(tag)
        all_tags.removeObject(tag)

      query = @get_tag_query(model, 'remove_comment_tag', all_tags, comment)

      ajax.object(query).then =>
        @tags_did_change()

    add_comment_tag: (comment, tag) ->
      all_tags  = comment.get('all_tags')
      model     = @get('model')

      unless all_tags.contains(tag)
        all_tags.pushObject(tag)
        
        query = @get_tag_query(model, 'add_comment_tag', all_tags, comment)

        ajax.object(query).then =>
          @tags_did_change()

    select_sort: (sort_type) ->
      for key, value of sort_type
        @set('selected_sort', value)

    close_library: ->
      @sendAction('close_action')

    confirm_category_add: (category_name) ->
      model        = @get('model')

      unless category_name == ''

        query = 
          model:    ns.to_p('markup', 'library')
          id:       model.get('id')
          verb:     'put'
          action:   'add_tag'
          data:
            tag_name: category_name

        ajax.object(query).then (payload) =>
          ajax.normalize_and_push_payload('library', payload, single: true)