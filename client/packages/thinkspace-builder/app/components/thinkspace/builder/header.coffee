import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  builder: ember.inject.service()

  # ### Components
  c_step: ns.to_p 'builder', 'header', 'step'

  # ### Properties
  space:   null
  tagName: ''

  # ### Computed properties
  model: ember.computed.reads 'builder.model'
  steps: ember.computed.reads 'builder.steps'

  title: ember.computed 'model.title', ->
    model = @get 'model'
    title = model.get 'title'
    if ember.isPresent(title) then title else 'New Case'

  # ### Events
  init: ->
    @_super()
    builder = @get 'builder'
    builder.get_space().then (space) =>
      @set 'space', space

  actions:
    exit: -> @get('builder').transition_to_assignment()


