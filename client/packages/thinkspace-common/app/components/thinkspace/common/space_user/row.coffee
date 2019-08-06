import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: 'tr'
  friendly_roles: ember.computed.alias 'model.friendly_roles'

  state_change_ajax: (action) ->
    model = @get 'model'
    query = 
      id:     model.get 'id'
      action: action
      verb:   'PUT'
    @tc.query(ns.to_p('space_user'), query, single: true)

  actions:
    save: (friendly_role) ->
      space_user = @get 'model'
      space_user.set_role_from_friendly(friendly_role)
      space_user.save().then (saved_space_user) =>
        @totem_messages.api_success source: @, model: saved_space_user, action: 'update', i18n_path: ns.to_o('space_user', 'save')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: space_user, action: 'update'


    inactivate: ->
      @totem_messages.show_loading_outlet()
      @state_change_ajax('inactivate').then =>
        @totem_messages.api_success source: @, model: @get('model'), action: 'update', i18n_path: ns.to_o('space_user', 'save')
        @totem_messages.hide_loading_outlet()

    activate: ->
      @totem_messages.show_loading_outlet()
      @state_change_ajax('activate').then =>
        @totem_messages.api_success source: @, model: @get('model'), action: 'update', i18n_path: ns.to_o('space_user', 'save')
        @totem_messages.hide_loading_outlet()

    resend: ->
      @get('model.user').then (user) =>

        refresh_options =
          model:  user
          id:     user.get('id')
          action: 'refresh'
          verb:   'PUT'

        resend_options =
          model:  @get('model')
          id:     @get('model.id')
          action: 'resend'
          verb:   'PUT'

        ajax.object(refresh_options).then (payload) =>
          ajax.object(resend_options).then =>
            @totem_messages.api_success source: @, model: @get('model'), action: 'resend', i18n_path: ns.to_o('invitation', 'resend')
