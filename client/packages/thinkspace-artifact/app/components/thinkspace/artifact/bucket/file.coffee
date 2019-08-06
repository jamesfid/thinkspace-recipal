import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  ttz: ember.inject.service()

  attachment_updated_at: ember.computed 'model.attachment_updated_at', -> @get('ttz').format(@get('model.attachment_updated_at'), format: 'MMM Do, h:mm a')

  file_url: ember.computed -> @get('model.url')

  can_update: ember.computed.bool 'model.updateable'

  show_file: false  # set to true to auto render the file

  # ### Components
  c_confirmation_modal: ns.to_p 'common', 'shared', 'confirmation', 'modal'

  c_file_component: ember.computed ->
    switch
      when @get 'model.is_pdf'
        ns.to_p 'artifact', 'bucket', 'file', 'pdf', 'wrapper'
      when @get 'model.is_image'
        ns.to_p 'artifact', 'bucket', 'file', 'image', 'wrapper'
      else
        null

  actions:
    show: -> @set 'show_file', true
    hide: -> @set 'show_file', false

    destroy: ->
      file = @get 'model'
      file.deleteRecord()
      file.save().then =>
        @tc.image.revoke_phase_url() if file.get('is_image') # revokes the phase image url
        @totem_messages.api_success source: @, model: file, action: 'delete', i18n_path: ns.to_o('artifact:file', 'destroy')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: file, action: 'delete'
