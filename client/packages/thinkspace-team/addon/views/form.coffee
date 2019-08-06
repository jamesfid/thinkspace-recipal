import ember from 'ember'

export default ember.View.extend

  title:         ember.computed.reads 'controller.model.title'        # needed for validation
  team_category: ember.computed.reads 'controller.model.category_id'  # needed for validation
  save_disabled: ember.computed.or    'controller.validation_message', 'controller.model_validation_message'

  team_category_change: ember.observer 'team_category', -> @valid()

  focus_input: -> @$('input').first().focus()

  didInsertElement: ->
    @focus_input()

  validations: 
    title:
      presence: true
    team_category:
      presence: true

