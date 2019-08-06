import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''
  
  # ### Services
  casespace:           ember.inject.service()

  # ### Properties
  has_bar: false 
  
  # ### Computed properties
  model:        ember.computed.reads 'casespace.current_phase' # Phase
  is_gradebook: ember.computed.equal 'bar_type', 'gradebook'

  c_bar_type:   ember.computed 'bar_type', ->
    type = @get 'bar_type'
    return null unless ember.isPresent(type)
    ns.to_p 'casespace', 'ownerable', 'bar', type

  # ### Observers
  addon_observer: ember.observer 'casespace.active_addon', ->
    addon = @get 'casespace.active_addon'
    if ember.isPresent(addon)
      name = addon.get 'addon_name'
      switch name
        when 'gradebook'
          @set_bar_type name
        when 'peer_review'
          @set_bar_type name
    else
      @reset_bar_type()

  # ### Helpers
  set_bar_type:   (type) -> 
    @set 'has_bar', true
    @set 'bar_type', type
  reset_bar_type: (type) -> 
    @set 'has_bar', false
    ember.run.schedule 'afterRender', =>
      @set 'bar_type', null
