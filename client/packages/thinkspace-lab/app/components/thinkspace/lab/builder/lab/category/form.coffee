import ember from 'ember'
import ns    from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend val_mixin,

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  category_columns: ember.computed ->
    admin    = @get('admin')
    category = @get('model')
    admin.category_columns(category)

  title:              null
  correctable_prompt: null

  show_errors: false

  actions:
    cancel: -> @sendAction 'cancel'

    save:   ->
      unless @get('is_valid')
        @set 'show_errors', true
        return
      category = @get('model')
      category.set 'title', @get('title')
      category.set 'value.correctable_prompt', @get('correctable_prompt')
      category.set 'value.columns', @get('category_columns')
      @sendAction 'save'

  didInsertElement: ->
    @set 'title', @get('model.title')
    @set 'correctable_prompt', @get('model.value.correctable_prompt')
    @$('input').first().focus()

  validations:
    title:
      presence: true
