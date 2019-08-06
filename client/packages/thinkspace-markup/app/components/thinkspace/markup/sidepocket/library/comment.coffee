import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  manager: ember.inject.service ns.to_p('markup', 'manager')

  # ### Properties
  model:             null
  library:           null
  tagName:           'li'
  classNames:        ['ts-markup-library_comment']
  classNameBindings: ['is_collapsed:is-collapsed', 'is_selected:is-selected']
  is_collapsed:      true
  is_tagging:        false

  # ### Computed properties
  is_selected: ember.computed 'manager.selected_library_comment', 'model', ->
    @get('manager.selected_library_comment') == @get('model')

  library_tags: ember.computed.reads 'library.model.all_tags'

  # ### Events
  click: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @sendAction 'select', @get('model')

  didInsertElement: ->
    @set_is_overflowing()
    @set_tags()

  # ### Helpers
  set_is_overflowing: -> 
    ember.run.schedule 'afterRender', =>
      $value = @$('.ts-markup-library_comment-text')
      @set 'is_overflowing', $value[0].scrollWidth >  $value.innerWidth()

  set_tags: ->
    tags     = ember.makeArray()
    all_tags = ember.makeArray(@get('model.all_tags'))

    all_tags.forEach (tag) =>
      tags.pushObject(tag)

    @set('tags', tags)

  update_tags: ->
    model = @get('model')
    tags  = @get('tags')

    model.set('all_tags', tags)
    model.save()

  actions:
    toggle_expand: -> @toggleProperty('is_collapsed')

    toggle_tagging: -> 
      if @get('is_tagging')
        @update_tags()

      @toggleProperty('is_tagging')
  