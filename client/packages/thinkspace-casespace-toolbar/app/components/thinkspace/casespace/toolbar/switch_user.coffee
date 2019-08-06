import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  casespace: ember.inject.service()

  r_spaces_show: ns.to_r 'spaces', 'show'

  actions:
    switch_user: ->
      space = @get('casespace').get_current_space()
      @totem_messages.invalidate_session()  if ember.isBlank(space)
      data    = {space_id: space.get('id')}
      session = @get('session')
      session.authenticate('authenticator_switch_user:totem', session, data).then =>
        @totem_messages.show_loading_outlet()
        window.location = window.location.pathname  # remove the query string (e.g. phase's query_id) and reload the page
        # window.location.reload()
        # window.location.reload(true)  # do not use browser cache
        return
      , (error) =>
        console.error "Cannot switch user. Error:", error
