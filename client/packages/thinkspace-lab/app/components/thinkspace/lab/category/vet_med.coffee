import ember from 'ember'
import ns    from 'totem/ns'
import lab   from 'thinkspace-lab/vet_med_lab'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  #tagName: ''

  init: ->
    @_super()
    tvo = @get('tvo')
    tvo.status.register_validation('lab', @, 'validate_lab')

  tvo: ember.inject.service()

  # ### Computed properties
  is_inactive:  ember.computed 'selected', -> @get('model') != @get('selected')
  is_view_only: ember.computed.bool 'totem_scope.is_view_only'

  lab: ember.computed ->
    lab.create
      tvo:              @get 'tvo'
      category:         @get 'model'
      lab_observations: []
      totem_scope:      @totem_scope
      totem_messages:   @totem_messages

  # ### Components
  c_observation: ember.computed -> ns.to_p 'lab:observation', @get('model.value.component')
  c_lab_result:  ns.to_p 'lab', 'result', 'vet_med'

  # ### Observer
  set_category_focus: ember.observer 'selected', ->
    return if @get('is_inactive')
    @get_lab().set_focus_on_selected_category()

  didInsertElement: -> if @get('is_inactive') then return else @get_lab().set_focus_on_selected_category()
  
  get_lab: -> @get 'lab'

  validate_lab: (status) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_lab().validate_lab_observations(status)
      resolve()

  click: (e) ->
    $target  = $(e.target)
    tag_name = $target.prop('tagName').toLowerCase()
    unless ['select', 'input', 'option'].contains(tag_name)
      $parents = $target.parents('tr.ts-lab_result')
      $select  = $parents.find('.ts-lab_select').first()
      $input   = $parents.find('input:enabled').first()
      if ember.isPresent($select) then $select.focus() else $input.focus()