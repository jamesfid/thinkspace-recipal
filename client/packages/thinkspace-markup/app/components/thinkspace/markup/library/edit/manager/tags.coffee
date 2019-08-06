import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  c_clickable_tag:   ns.to_p('markup', 'library', 'edit', 'manager', 'tag')
  c_validated_input: ns.to_p('common', 'shared', 'validated_input')
  c_checkbox:        ns.to_p('common', 'shared', 'checkbox')

  model:              null
  all_tags:           ember.computed.reads 'model.all_tags'
  
  selected_tags:      null
  select_tag_action:  null
  add_tag_action:     null
  category_name:      ''
  is_adding_category: false
  select_all:         null

  # Class to pass to input field to allow it to be selected
  input_class: null

  init: ->
    @_super()

    @sendAction('register_tags_component', @)

  tag_count: null

  all_tag_count: ember.computed 'sorted_tags', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('sorted_tags').then (sorted_tags) =>
        count = 0
        sorted_tags.forEach (tag) =>
          count += tag.count

        resolve({count: count})

    ta.PromiseObject.create promise: promise

  sorted_tags: ember.computed 'model', 'model.all_tags.length', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>  
      model = @get('model')
      return resolve([]) unless ember.isPresent(model)
      all_tags = model.get('all_tags')
      return resolve([]) if ember.isEmpty(all_tags)
      model.get('comments').then (comments) =>
        arr  = []
        temp = []

        all_tags.forEach (tag) =>
          obj      = {}
          obj.name = tag

          arr.pushObject(obj)

        comments.forEach (comment) =>
          comment_tags = comment.get('all_tags')

          comment_tags.forEach (comment_tag) =>
            obj = arr.findBy('name', comment_tag)
            if ember.isPresent(obj)
              if ember.isPresent(obj.count)
                obj.count += 1
              else
                obj.count = 1
            else
              console.error("[Markup:Tags] Tag #{comment_tag} not found in library.")

        arr.forEach (obj) =>
          obj.count = 0 unless ember.isPresent(obj.count)

        arr = arr.sortBy('count')
        arr.reverse()

        resolve(arr)

    ta.PromiseArray.create promise: promise


  tags_did_change: ->
    @propertyDidChange('sorted_tags')

  keyPress: (e) ->
    if ember.isEqual(e.keyCode, 13)
      @send('confirm_category_add')
      false

  actions:
    confirm_category_add: ->
      category_name = @get('category_name')
      unless category_name == ''
        @sendAction('add_tag_action', category_name)
        @set('is_adding_category', false)

    add_category: ->
      @set('is_adding_category', true)

    cancel_category_add: ->
      @set('is_adding_category', false)

    all_selected: ->
      @sendAction('select_all')

    select_tag_action: (tag) ->
      @sendAction('select_tag_action', tag)