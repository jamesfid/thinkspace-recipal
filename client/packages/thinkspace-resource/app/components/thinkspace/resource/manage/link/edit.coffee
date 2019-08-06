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

    save:   ->
      link = @get 'model'
      link.set 'title', @get('title')
      link.set 'url',   @get('url')
      link.set_new_tags @get 'selection'
      link.save().then =>
        @totem_messages.api_success source: @, model: link, action: 'save', i18n_path: ns.to_o('link', 'save')
        @send 'cancel'
      , (error) =>
        @totem_messages.api_failure error, source: @, model: link, action: 'save'

  didInsertElement: ->
    @set 'title',     @get('model.title')
    @set 'url',       @get('model.url')
    @set 'selection', @get('model.tag')