import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['thinkspace-resource_link']

  c_manage_link_edit: ns.to_p 'resource', 'manage', 'link', 'edit'

  prompt:       'No tag'
  edit_visible: false

  actions:

    edit:   -> @set 'edit_visible', true
    cancel: -> @set 'edit_visible', false

    destroy: ->
      link = @get 'model'
      link.deleteRecord()
      link.save().then =>
        @totem_messages.api_success source: @, model: link, action: 'delete', i18n_path: ns.to_o('link', 'destroy')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: link, action: 'delete'
