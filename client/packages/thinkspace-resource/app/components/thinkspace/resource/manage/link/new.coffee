import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  t_manage_link_form: ns.to_t 'resource', 'manage', 'link', 'form'

  title:     null
  url:       null
  selection: null

  actions:
    cancel: -> @sendAction 'cancel'

    save: ->
      resourceable = @get 'resourceable'
      title        = @get 'title'
      url          = @get 'url'
      link         = resourceable.store.createRecord ns.to_p('link'),
        title:             title
        url:               url
        resourceable_type: @totem_scope.record_type_key(resourceable)
        resourceable_id:   resourceable.get('id')
      link.set_new_tags @get 'selection'
      link.save().then (link) =>
        @totem_messages.api_success source: @, model: link, i18n_path: ns.to_o('link', 'save')
        @send 'cancel'
      , (error) =>
        @totem_messages.api_failure error, source: @, model: link
