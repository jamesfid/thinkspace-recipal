import ember      from 'ember'
import ns         from 'totem/ns'
import val_mixin  from 'totem/mixins/validations'
import base       from 'thinkspace-base/components/base'

export default base.extend val_mixin,
  # ### Services
  manager: ember.inject.service ns.to_p('peer_assessment', 'builder', 'manager')

  # ### Properties
  
  # ### Components
  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'
  c_radio:           ns.to_p 'common', 'shared', 'radio'
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'

  # ### Computed properties
  type:              ember.computed.reads 'model.assessment_type'
  is_balance:        ember.computed.equal 'type', 'balance'
  is_categories:     ember.computed.equal 'type', 'categories'
  is_read_only:      ember.computed.reads 'model.is_read_only'
  points_per_member: ember.computed.reads 'model.points_per_member'
  points_different:  ember.computed.reads 'model.points_different'

  actions:
    toggle_points_different: -> @toggleProperty('points_different')
    
    set_is_categories: ->  
      return if @get 'is_read_only'
      @set 'type', 'categories'
    set_is_balance:    ->  
      return if @get 'is_read_only'
      @set 'type', 'balance'

    save: ->
      @validate().then (valid) =>
        return unless valid
        model             = @get 'model'
        type              = @get 'type'

        switch type
          when 'categories'
            model.set_is_categories()
            model.reset_points_per_member()
          when 'balance'
            points_different  = @get 'points_different'
            points_per_member = @get 'points_per_member'
            model.set_is_balance() 
            model.set_points_per_member(points_per_member)
            model.set_points_different(points_different)

        @totem_messages.show_loading_outlet()
        model.save().then =>
          @totem_messages.hide_loading_outlet()
          @sendAction 'cancel'

    cancel: -> @sendAction 'cancel'

    activate: ->
      model = @get 'model'
      @validate().then (valid) =>
        if valid
          confirm = window.confirm('Are you sure you want to activate this evaluation?  You will not be able to make changes to the evaluation or teams once this is done.')
          return unless confirm
          @totem_messages.show_loading_outlet()
          @tc.query(ns.to_p('tbl:assessment'), {id: model.get('id'), action: 'activate', verb: 'PUT'}, single: true).then (assessment) =>
            @totem_messages.hide_loading_outlet()
            @sendAction 'cancel'
        else
          @totem_messages.error('This evaluation is not valid, please ensure it is and try again.')


  validations:
    points_per_member:
      numericality:
        greaterThan: 0
        'if': 'is_balance'
