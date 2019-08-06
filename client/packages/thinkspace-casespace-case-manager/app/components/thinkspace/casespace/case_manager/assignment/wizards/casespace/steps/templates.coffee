import ember      from 'ember'
import ns         from 'totem/ns'
import ta         from 'totem/ds/associations'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'

export default base.extend
  # ### Properties
  step:                'templates'
  all_data_loaded:     false
  page_title:          ember.computed.reads 'model.title'
  assignment_template: ember.computed.reads 'wizard_manager.wizard.template'

  # ### Components
  c_template_select: ns.to_p 'case_manager', 'assignment', 'wizards', 'casespace', 'steps', 'templates', 'select'
  c_loader:          ns.to_p 'common', 'shared', 'loader'

  assignment_templates: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      store = @totem_scope.get_store()
      @templates_ajax().then (templates) => 
        @set 'all_data_loaded', true
        resolve(templates)
    ta.PromiseArray.create promise: promise

  templates_ajax: ->
    new ember.RSVP.Promise (resolve, reject) =>
      store = @totem_scope.get_store()
      query =
        model:   ns.to_p('assignment')
        action: 'templates'
        verb:   'get'
      @wizard_ajax(query, 'builder:template').then (records) =>
        resolve(records)

  actions:
    set_template: (template) -> @get('wizard_manager').send_action 'set_template', template

    complete: ->
      return unless @get('assignment_template')
      @get('wizard_manager').send_action 'complete_step', 'templates'
