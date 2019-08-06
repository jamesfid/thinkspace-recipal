import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  score:          ember.computed.reads 'group_values.score'
  team_ownerable: ember.computed.reads 'group_values.team_ownerable'
  can_edit:       ember.computed.and   'is_edit', 'group_values.state_id'

  title: ember.computed -> (@get('team_ownerable') and @get('group_values.team_label')) or @get('group_values.user_label') or @get('group_values.label')

  edit_score_visible: false

  input_size: 7
  new_score:  null

  actions:

    save: ->
      @set 'edit_score_visible', false
      @sendAction 'save_score', @get('group_values'), @get('new_score') or 0

    cancel: ->
      @set 'edit_score_visible', false

    toggle_edit: ->
      if @toggleProperty('edit_score_visible')
        ember.run.next =>
          parent = @get 'parentView'  # need the parent view since tagName is '' (plus wait for the input to render before setting focus)
          parent.$(':input').focus()  if parent
