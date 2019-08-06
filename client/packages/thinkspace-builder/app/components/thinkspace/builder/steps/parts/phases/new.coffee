import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Properties
  model:           null # Assignment
  phase_templates: null # Using `phase_templates` as just `templates` causes an error in the template.

  # ### Component
  c_loader: ns.to_p 'common', 'loader'

  # ### Events
  init: ->
    @_super()
    @get_templates().then => @set_all_data_loaded()

  get_templates: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        action: 'templates'
        verb:   'GET'
      @tc.query(ns.to_p('phase'), query, payload_type: ns.to_p('builder:template')).then (templates) =>
        @set 'phase_templates', templates
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  clone_ajax: (template) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = 
        action:        'clone'
        verb:          'POST'
        assignment_id: @get 'model.id'
        template_id:   template.get 'id'
      @tc.query(ns.to_p('phase'), query, single: true).then =>
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  actions:
    clone: (template) ->
      @totem_messages.show_loading_outlet()
      @clone_ajax(template).then =>
        @sendAction 'cancel'
        @totem_messages.hide_loading_outlet()