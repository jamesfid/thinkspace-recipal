import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  active:        false
  content:       null
  parent_action: null
  parent_attr:   null

  classNames: ['sim_btn-list']

  init: ->
    if @get('is_selected')
      @set('active', true)

    @_super()

  is_selected: ember.computed 'parent_attr', 'content', ->
    @get('parent_attr') == @get('content')

  btn_style: ember.computed 'active', ->
    if @get('active')
      @send('parent_send_action')
      return 'cnc-btn-blue'

  btn_obs: ember.observer 'is_selected', ->
    if @get('active')
      unless @get('is_selected')
        @set('active', false)

  actions:
    toggle_active: ->
      if @get('active') == false
        @toggleProperty('active')

    parent_send_action: ->
      content = @get('content')
      @sendAction('parent_action', content)
      