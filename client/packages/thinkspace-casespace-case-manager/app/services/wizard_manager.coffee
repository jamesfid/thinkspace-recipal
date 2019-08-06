import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'

export default ember.Object.extend
  case_manager: ember.inject.service()
  thinkspace:   ember.inject.service()

  wizard:     null # The specific wizard (e.g. casespace) that is being rendered.
  controller: null # The rendering conroller
  route:      null # The rendering route
  space:      null # The space the new assignment is for
  page_title: 'New Case' # Current title to render in the header.

  reset_all: -> @set 'transition_to_step', null

  send_action: (action, args...) -> @get('wizard').send(action, args...)

  # Controller / route helpers
  set_controller: (controller) ->      @set 'controller', controller
  set_route:      (route) ->           @set 'route', route
  set_page_title: (title) ->           @set 'page_title', title
  set_space:      (space) ->           @set 'space', space

  get_current_assignment: -> @get('case_manager').get_current_assignment()

  set_query_param: (param, value, options={}) ->
    fn           = "check_#{param}"
    controller   = @get('controller')
    wizard       = @get('wizard')
    current_step = controller.get('step')
    console.error "[wizard] Cannot set a query param without a controller set." unless ember.isPresent(controller)
    return ember.RSVP.resolve() unless typeof wizard[fn] == 'function'
    wizard[fn](value, options).then (new_value=null) =>
      value = new_value if ember.isPresent(new_value)
      controller.set(param, value)

  # Step traversal helpers
  back:          (step) -> @get('wizard').send('back', step); @scroll_to_top()  # Proxy to specific component for handling (e.g. casespace wizard)
  complete_step: (step) -> @get('wizard').send('complete_step', step); @scroll_to_top() 
  go_to_step:    (step) -> @get('wizard').send('go_to_step', step); @scroll_to_top() 
  exit:                 -> @get('route').send('exit'); @scroll_to_top() 

  scroll_to_top: -> @get('thinkspace').scroll_to_top()

  # Transition helpers
  transition_to_step: null

  transition_to_assignment_edit: (assignment, options={}) ->
    @set 'transition_to_step', (options.queryParams and options.queryParams.step)
    @get('route').transitionTo ns.to_r('case_manager', 'assignments', 'edit'), assignment, options

  transition_to_assignment_show: (assignment) ->
    assignment = @get_current_assignment() unless ember.isPresent(assignment)
    @get('route').transitionTo ns.to_r('casespace', 'assignments', 'show'), assignment

  transition_to_space: (space=null) ->
    route = @get('route')
    if ember.isPresent(space)
      if space.get('isDeleted') then route.transitionTo ns.to_r('spaces') else route.transitionTo ns.to_r('spaces', 'show'), space
    else
      route.transitionTo ns.to_r 'spaces', 'index'

  transition_to_selector: -> @get('route').transitionTo ns.to_r('case_manager', 'assignments', 'new'), { queryParams: { space_id: @get('space.id'), bundle_type: 'selector' } }
