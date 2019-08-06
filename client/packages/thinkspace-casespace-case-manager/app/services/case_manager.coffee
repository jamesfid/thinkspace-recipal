import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'

export default ember.Object.extend
  reset_all: ->
    @reset_models()
    @get_case_manager_map().clear()

  reset_models: ->
    @set_current_space(null)
    @set_current_assignment(null)
    @set_current_phase(null)

  # ###
  # ### Current Models.
  # ###

  current_space:      null
  current_assignment: null
  current_phase:      null

  current_model: ember.computed 'current_space', 'current_assignment', 'current_phase', ->
    @get('current_phase') or @get('current_assignment') or @get('current_space') or null

  get_current_space:      -> @get 'current_space'
  get_current_assignment: -> @get 'current_assignment'
  get_current_phase:      -> @get 'current_phase'

  set_current_space:      (space)      -> @set 'current_space', space
  set_current_assignment: (assignment) -> @set 'current_assignment', assignment
  set_current_phase:      (phase)      -> @set 'current_phase', phase

  set_current_models: (current_models={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      switch
        when phase = current_models.phase
          phase.get(ns.to_p 'assignment').then (assignment) =>
            assignment.get(ns.to_p 'space').then (space) =>
              @set_current_space(space)            unless @get_current_space() == space
              @set_current_assignment(assignment)  unless @get_current_assignment() == assignment
              @set_current_phase(phase)
              resolve()
            , (error) => reject(error)
          , (error) => reject(error)
        when assignment = current_models.assignment
          assignment.get(ns.to_p 'space').then (space) =>
            @set_current_phase(null)
            @set_current_space(space) unless @get_current_space() == space
            @set_current_assignment(assignment)
            resolve()
          , (error) => reject(error)
        when space = current_models.space
          @set_current_assignment(null)
          @set_current_phase(null)
          @set_current_space(space) unless @get_current_space() == space
          resolve()
        else
          @reset_all()
          resolve()

  case_manager_map: ember.Map.create()
  get_case_manager_map:  -> @get 'case_manager_map'

  get_or_init_case_manager_map: (key) ->
    map = @get_case_manager_map().get(key)
    return map if ember.isPresent(map)
    @get_case_manager_map().set key, ember.Map.create()
    @get_case_manager_map().get(key)

  get_or_init_assignment_map: -> @get_or_init_case_manager_map @get_current_assignment()
  set_assignment_loaded:      -> @get_or_init_assignment_map().set 'loaded', true
  has_assignment_loaded:      -> @get_or_init_assignment_map().get 'loaded'

  get_store: -> @get('current_model.store')

  get_team_categories: ->
    new ember.RSVP.Promise (resolve, reject) =>
      map        = @get_case_manager_map()
      categories = map.get('team_categories')  if map.has('team_categories')
      return resolve(categories)  if ember.isPresent(categories)
      store = @get_store()
      store.find(ns.to_p 'team_category').then (categories) =>
        map.set 'team_categories', categories
        resolve(categories)
      , (error) => reject(error)

  get_store_spaces: ->
    store  = @get_store()
    spaces = store.all ns.to_p('space')
    spaces.filter (space) -> !space.get('isNew')

  get_updatable_store_spaces: -> @get_store_spaces.filter (space) -> space.can_update
