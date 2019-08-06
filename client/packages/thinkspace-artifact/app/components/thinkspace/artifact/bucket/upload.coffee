import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  files_url: ember.computed -> ajax.adapter_model_url(model: ns.to_p 'artifact:file')

  upload_wrapper_selector: '.thinkspace-artifact_upload'

  ownerable_type: ember.computed -> @totem_scope.get_ownerable_type()
  ownerable_id:   ember.computed -> @totem_scope.get_ownerable_id()

  didInsertElement: ->
    upload_wrapper_selector = @get 'upload_wrapper_selector'
    $input                  = @$().find(upload_wrapper_selector).first()
    
    $input.fileupload
      dataType: 'json'
      dropZone: upload_wrapper_selector

      done: (e, data) =>
        model = @get 'model'

        # Load the payload.
        # => Have to handle this a bit differently than normal because we do not initiate a
        # => file creation through createRecord() - it will avoid didCreate/didLoad hooks.
        key = ns.to_p 'artifact:files'
        model.store.pushPayload(ns.to_p('artifact:file'), data.result)
        for file in data.result[key]
          model.store.find(ns.to_p('artifact:file'), file.id).then (file) =>
            file.didLoad()

