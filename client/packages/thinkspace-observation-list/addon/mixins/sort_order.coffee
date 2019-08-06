import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'

export default ember.Mixin.create

  # ###
  # ### Handle Dragula Drop Event in Re-Ordering Observations.
  # ###

  handle_dragula_drop: (el, target, source, sibling) ->
    $el      = $(el)
    $sibling = $(sibling)
    changes  = @get_observation_increment_and_decrement_changes($el, $sibling)
    @save_observation_order(changes) if ember.isPresent(changes)

  get_observation_increment_and_decrement_changes: ($el, $sibling) ->
    obs = @get_element_observation($el)
    $el.remove()
    sibling_obs      = @get_element_observation($sibling)
    observations     = @get_ownerable_observations_in_position_order()
    move_to_position = @get_dragged_observation_move_to_position(observations, obs, sibling_obs)
    move_up          = @is_dragged_observation_moved_up(obs, sibling_obs)
    return null if move_to_position == obs.get('position')
    changes = []
    obs_pos = obs.get('position') + 0
    obs.set 'position', move_to_position
    changes.push {id: obs.get('id'), position: move_to_position}
    observations.forEach (observation, index) =>
      unless observation == obs
        i   = index + 1  # positions start with 1 not 0
        pos = observation.get('position')
        if i <= move_to_position
          i -= 1  if pos > obs_pos
        else
          i += 1  if pos <= obs_pos
        i += 1  if move_up and pos == move_to_position
        unless pos == i
          id = observation.get('id')
          changes.push {id: id, position: i}
          observation.set 'position', i
    changes

  is_dragged_observation_moved_up: (obs, sibling_obs) ->
    return false unless sibling_obs
    obs.get('position') > sibling_obs.get('position')

  get_ownerable_observations_in_position_order: -> @get('model').get('observations').copy()

  get_dragged_observation_move_to_position: (observations, obs, sibling_obs) ->
    if sibling_obs
      pos  = obs.get('position')
      spos = sibling_obs.get('position')
      if pos > spos then spos else (spos - 1)
    else
      observations.get('lastObject.position') or observations.length

  get_element_observation: ($el) ->
    return null if ember.isBlank($el)
    type     = ns.to_p 'observation'
    model_id = $el.attr('model_id')
    @get('model.store').getById(type, model_id)

  save_observation_order: (changes) ->
    new ember.RSVP.Promise (resolve, reject) =>
      list  = @get('model')
      query = 
        verb:   'put'
        action: 'observation_order'
        model:  list
        id:     list.get('id')
        data:   
          order: changes
      totem_scope.add_ownerable_to_query(query.data)
      totem_scope.add_authable_to_query(query.data)
      ajax.object(query).then =>
        totem_messages.api_success source: @, model: list, action: 'observation_order'
        resolve()
      , (error) =>
        totem_messages.api_failure error, source: @, model: list
