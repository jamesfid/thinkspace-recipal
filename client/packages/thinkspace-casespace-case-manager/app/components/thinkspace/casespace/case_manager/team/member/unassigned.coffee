import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  tagName:          ''
  selected_members: null

  is_selected: ember.computed 'selected_members.length', -> @get('selected_members').contains @get('model')

  # Components
  c_user_avatar:   ns.to_p 'common', 'user', 'avatar'

  
  actions:
    select: -> @sendAction 'select_member', @get('model')

