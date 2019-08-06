import ember from 'ember'
import ns    from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend val_mixin,
  wizard_manager: ember.inject.service()

  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  t_space_form:      ns.to_t 'case_manager', 'space', 'form'

  title: ember.computed.reads 'model.title'

  title_region_title: ember.computed.reads 'model.title'
  action_name: 'Edit'

  actions:
    save: ->
      return unless @get('is_valid')
      space = @get('model')
      space.set 'title', @get('title')
      space.save().then =>
        @totem_messages.api_success source: @, model: space, action: 'save', i18n_path: ns.to_o('space', 'save')
        @transition_to_space()
      , (error) =>
        @totem_messages.api_failure error, source: @, model: space, action: 'save'

    cancel: ->
      space = @get('model')
      space.rollback()  if space.get('isDirty')
      @transition_to_space()

  transition_to_space: -> @get('wizard_manager').transition_to_space @get('model')

  validations: 
    title:
      presence:    true
      modelErrors: true
