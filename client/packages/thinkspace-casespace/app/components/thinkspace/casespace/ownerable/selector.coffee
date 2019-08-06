import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  casespace: ember.inject.service()
  
  # ### Properties
  ownerables:          null # Array
  search:              null # String for user input for search
  multiple:            false # How many ownerables can be selected
  selected_ownerables: null # [] of ownerables
  menu_only:           false # Whether or not to display the 'Please click...' type of base

  searchable:              false # Passed in to determine if input appears
  is_selecting_ownerables: false

  click_watcher:       null # Handler to watch for non-related click events to close menu if open.
  click_watcher_event: 'mouseup.ownerable_selector'
  close_on_click:      true # Whether or not to close on a document click.

  # ### Computed properties
  model:                   ember.computed.reads 'casespace.current_phase' # Phase
  current_user:            ember.computed.reads 'totem_scope.current_user'
  has_selected_ownerables: ember.computed.notEmpty 'selected_ownerables'

  is_searchable:    ember.computed.reads 'searchable'
  is_searching:     ember.computed.notEmpty 'search'
  is_not_menu_only: ember.computed.not 'menu_only'

  filtered_ownerables: ember.computed 'search', 'ownerables', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      search       = @get 'search'
      current_user = @get 'current_user'
      @get_ownerables().then (ownerables) =>
        if ember.isPresent(search)
          matches = []
          ownerables.forEach (ownerable) =>
            full_name = ownerable.get 'full_name'
            matches.pushObject(ownerable) if full_name.match new RegExp(search)
          resolve matches
        else
          resolve ownerables.without(current_user)
    ta.PromiseArray.create promise: promise

  # ### Components
  c_selector_ownerable: ns.to_p 'casespace', 'ownerable', 'selector', 'ownerable'
  c_loader:             ns.to_p 'common', 'loader'

  # ### Observers

  # If a click happens outside of the bounds of the dropdown, close it.
  is_selecting_ownerables_observer: ember.observer 'is_selecting_ownerables', ->
    close_on_click = @get 'close_on_click'
    return unless close_on_click
    is_selecting = @get 'is_selecting_ownerables'
    if is_selecting then @bind_click_watcher() else @unbind_click_watcher()

  # ### Events
  willDestroyElement: -> @unbind_click_watcher()

  # ### Helpers
  set_is_selecting_ownerables:   -> @set 'is_selecting_ownerables', true
  reset_is_selecting_ownerables: -> @set 'is_selecting_ownerables', false

  # ### Ownerable helpers
  # => Used to ensure that ownerables is a promise for consistency and flexibility.
  get_ownerables: ->
    ownerables = @get 'ownerables'
    return ownerables if ownerables.then?
    new ember.RSVP.Promise (resolve, reject) =>
      resolve(ownerables)

  # ### Click watcher helpers
  # => Used to close the selection menu when a click occurs outside of the menu for usability.
  get_click_watcher_event: -> @get 'click_watcher_event'

  set_click_watcher:   (handler) -> @set 'click_watcher', handler
  reset_click_watcher: -> @set 'click_watcher', null
  get_click_watcher:   -> @get 'click_watcher'

  bind_click_watcher: ->
    watcher = @get_click_watcher()
    return if ember.isPresent(watcher)
    event = @get_click_watcher_event()
    watcher = $(document).bind event, (e) =>
      $container = @$()
      if !$container.is(e.target) and $container.has(e.target).length == 0
        @reset_is_selecting_ownerables()
    @set_click_watcher watcher

  unbind_click_watcher: ->
    watcher = @get_click_watcher()
    return unless ember.isPresent(watcher)
    event   = @get_click_watcher_event()
    $(document).unbind(event)
    @reset_click_watcher()

  actions:
    cancel: -> @sendAction 'cancel'
    select: (model) -> @sendAction 'select', model

    set_is_selecting_ownerables:    -> @set_is_selecting_ownerables()
    toggle_is_selecting_ownerables: -> @toggleProperty 'is_selecting_ownerables'