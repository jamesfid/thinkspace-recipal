import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import ajax  from 'totem/ajax'
import base  from 'thinkspace-casespace-case-manager/components/wizards/steps/base'

export default base.extend
  # ### Properties
  all_data_loaded: false

  # ### Services
  case_manager: ember.inject.service()

  # ### Components
  c_loader: ns.to_p 'common', 'shared', 'loader'

  phase_templates: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      templates = @get('case_manager').get_case_manager_map().get 'cm_phase_templates'
      return resolve(templates)  if ember.isPresent(templates)
      @templates_ajax().then (templates) =>
        templates = templates.sortBy 'title'
        @get('case_manager').get_case_manager_map().set 'cm_phase_templates', templates
        @set 'all_data_loaded', true
        resolve(templates)
    ta.PromiseArray.create promise: promise

  actions:
    clone: (template) ->
      @totem_messages.show_loading_outlet message: 'Cloning phase template...'
      @clone_ajax(template).then =>
        @totem_messages.hide_loading_outlet()
      , (error) => console.error "[clone] Cloning failed: ", error

    close: -> @sendAction 'close'

  templates_ajax: ->
    new ember.RSVP.Promise (resolve, reject) =>
      store = @totem_scope.get_store()
      query = 
        model:  ns.to_p('phase')
        action: 'templates'
        verb:   'get'
      @wizard_ajax(query, 'case_manager_template').then (records) =>
        resolve(records)

  clone_ajax: (template) ->
    new ember.RSVP.Promise (resolve, reject) =>
      store = template.store
      query =
        model:  ns.to_p('phase')
        action: 'clone'
        verb:   'post'
        data:
          case_manager_template_id: template.get('id')
          assignment_id:            @get('model.id')
      ajax.object(query).then (payload) =>
        store.pushPayload(payload)
        resolve()
      , (error) => reject(error)
