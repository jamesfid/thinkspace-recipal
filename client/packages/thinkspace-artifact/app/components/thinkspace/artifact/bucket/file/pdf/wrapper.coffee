import ember  from 'ember'
import ns     from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames:        ['artifact_pdf-wrapper', 'clearfix']
  classNameBindings: ['show_file:is-visible:is-hidden']

  c_pdf_file:     ns.to_p 'artifact', 'bucket', 'file', 'pdf', 'file'

  file_container_id:      ember.computed 'model', -> @get('model.container_id')
  comment_section:        ember.computed.reads 'file_container_id'

  # TODO: this should be set via an ability or model attribute.
  can_comment: true

  didInsertElement: ->
    if @get('can_comment')
      width = '1260px'
      @$().css('width', width).css('margin', 0).css('position', 'relative')
