import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/components/wizards/base'

export default base.extend

  actions:
    set_bundle_type: (bundle_type) ->
      wizard_manager = @get('wizard_manager')
      switch bundle_type
        when 'casespace'
          wizard_manager.set_query_param 'step', 'details'
      wizard_manager.set_query_param 'bundle_type', bundle_type

    cancel: -> @get('wizard_manager').exit()
