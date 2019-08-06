import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  markup: ember.inject.service ns.to_p('markup', 'manager')

  # ### Properties
  model:             null # Discussion
  classNames:        ['ts-markup_discussion', 'ts-markup_discussion-default']
  classNameBindings: ['is_highlighted:is-highlighted']

  width:  50 # px of the marker
  height: 50 # px of the marker

  # ### Computed properties
  discussion_number:  ember.computed 'discussions.length', 'model', ->
    discussions = @get 'discussions'
    model       = @get 'model'
    @get('markup').get_discussion_number(discussions, model)

  # ### Events
  init: ->
    @_super()
    @get('markup').add_marker_component(@)

  willDestroyElement: -> @get('markup').remove_marker_component(@)
  willInsertElement:  -> @position_from_value()

  click: (e) ->
    e.stopPropagation()
    e.preventDefault()
    model = @get 'model'
    @get('markup').highlight_discussion(model)

  # ### Highlight helpers
  set_is_highlighted:   -> @set 'is_highlighted', true
  reset_is_highlighted: -> @set 'is_highlighted', false
  get_is_highlighted:   -> @get 'is_highlighted'

  # ### Positioning helpers
  position_from_value: ->
    position      = @get 'model.value.position'
    height        = @get 'height'
    width         = @get 'width'
    height_offset = parseFloat (height / 2.0)
    width_offset  = parseFloat (width / 2.0)

    render_x = position.x - width_offset
    y        = position.y
    page     = position.page
    page_top = $("canvas[page='#{page}']").position().top # Page height is off by 4px for each page except first.
    render_y = if page > 1 then (y + page_top - height_offset) else (y - height_offset)
    @$().css
      top:  render_y
      left: render_x

