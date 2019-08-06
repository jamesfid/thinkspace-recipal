import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/components/wizards/steps/base'

export default base.extend
  
  # ### Properties
  get_modal:        -> $('.reveal-modal') # Cannot use @$() as it does not scope to root.
  destroy_modal:    -> @get_modal().foundation('reveal', 'close')

  # ### Callbacks
  didInsertElement: -> @get_modal().foundation('reveal', 'open')

  actions:
    approve: ->   @destroy_modal(); @sendAction 'approve'
    cancel:  ->   @destroy_modal(); @sendAction 'cancel'
