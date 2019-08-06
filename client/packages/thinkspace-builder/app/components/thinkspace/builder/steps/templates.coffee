import ember          from 'ember'
import ns             from 'totem/ns'
import base           from 'thinkspace-builder/components/wizard/steps/base'

export default base.extend
  # ### Properties
  selected_template: null
  tagName:           ''

  # ### Components
  c_template_grid:     ns.to_p 'builder', 'steps', 'parts', 'templates', 'grid'
  c_template_detailed: ns.to_p 'builder', 'steps', 'parts', 'templates', 'detailed'

  # ### Events
  init: ->
    @_super()
    @set_templates().then => @set_all_data_loaded()

  # ### Helpers  
  set_templates: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.query(ns.to_p('builder:template'), templateable_type: 'thinkspace/casespace/assignment').then (templates) =>
        @set 'templates', templates
        resolve()

  set_selected_template: (template) -> @set 'selected_template', template
  reset_selected_template: -> @set 'selected_template', null

  # ### Callbacks
  callbacks_next_step: ->
    new ember.RSVP.Promise (resolve, reject) =>
      template = @get 'selected_template'
      builder  = @get 'builder'
      model    = @get 'model'
      model.set 'template_id', template.get('id')
      builder.set_is_saving()
      model.save().then =>
        builder.reset_is_saving()
        model.set 'template_id', null # Important
        @get('builder').transition_to_next_step()
        resolve()
      , (error) => @get('builder').encountered_save_error(error)
    , (error) => console.error 'Error caught in templates step.'

  actions:
    select: (template) ->
      @set_selected_template template

    back_to_grid: -> @reset_selected_template()
    use_selected_template: -> @send('next')