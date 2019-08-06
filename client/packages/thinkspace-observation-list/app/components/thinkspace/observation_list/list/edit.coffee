import ember from 'ember'
import ns    from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend val_mixin,

  categories: ember.computed.reads 'model.category_values'

  c_category_radio: ns.to_p 'observation_list', 'list', 'category_radio'

  input_value: null

  actions:
    select: -> @sendAction 'select', @get('model')
    exit:   -> @sendAction 'select', null

    save: ->
      list = @get 'model'
      list.set 'category.name', @get('input_value')
      list.save().then (list) =>
        @totem_messages.api_success source: @, model: list, action: 'update', i18n_path: ns.to_o('list', 'save')
        @send 'exit'
      , (error) =>
        @totem_messages.api_failure error, source: @, model: list, action: 'update'

    cancel: ->
      bucket = @get 'model'
      bucket.rollback()  if bucket.get('isDirty')
      @send 'exit'

    check: (id) -> @set 'input_value', id
    uncheck:    -> @set 'input_value', null

  didInsertElement: -> @set 'input_value', @get('model.category_id')

  validations:
    input_value:
      presence:
        message: 'You must select one of the above categories'
