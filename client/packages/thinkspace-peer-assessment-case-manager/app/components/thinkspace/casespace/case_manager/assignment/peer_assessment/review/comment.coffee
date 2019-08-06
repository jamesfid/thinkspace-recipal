import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  tagName:    ''
  model:      null # JSON item from assessment
  review:     null
  assessment: null
  comment:    null # JSON item from review

  is_editing:  false

  # ### Computed properties
  value:       ember.computed.reads 'comment.value'
  label:       ember.computed.reads 'model.label'
  has_value:   ember.computed.notEmpty 'value'
  is_not_sent: ember.computed.reads 'review.is_not_sent'

  # ### Events
  init: ->
    @_super()
    review  = @get 'review'
    model   = @get 'model'
    comment = review.get_qualitative_comment_for_id model.id
    @set 'comment', comment

  actions:
    edit: -> @toggleProperty 'is_editing'
    save: ->
      review = @get 'review'
      review.set_qualitative_value @get('model.id'), @get('model.feedback_type'), @get('value')
      @totem_messages.show_loading_outlet()
      review.save().then =>
        @totem_messages.api_success source: @, model: review, action: 'update', i18n_path: ns.to_o('tbl:review', 'save')
        @totem_messages.hide_loading_outlet()
        @set 'is_editing', false