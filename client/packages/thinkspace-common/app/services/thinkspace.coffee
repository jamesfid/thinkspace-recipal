import ember          from 'ember'
import config         from 'totem/config'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'

export default ember.Object.extend
  # ### Services
  sockets: ember.inject.service()

  # ### Lifecycle
  init: ->
    @_super()
    @get('sockets').initialize()

  # ### Toolbar / wizard.
  toolbar_is_hidden:    false
  toolbar_is_minimized: false
  dock_is_visible:      false
  display_terms_modal:  false

  check_users_terms: (user) ->
    terms_updated_at = new Date(config.terms.updated_at)
    user_accepted_at = user.get('terms_accepted_at')

    if ember.isEmpty(user_accepted_at) or (user_accepted_at < terms_updated_at)
      @set 'display_terms_modal', true

  hide_toolbar:        -> @set 'toolbar_is_hidden', true
  show_toolbar:        -> @set 'toolbar_is_hidden', false
  toggle_hide_toolbar: -> @toggleProperty('toolbar_is_hidden')

  minimize_toolbar:        -> @set 'toolbar_is_minimized', true
  expand_toolbar:          -> @set 'toolbar_is_minimized', false
  toggle_minimize_toolbar: -> @toggleProperty('toolbar_is_minimized')

  hide_dock:   -> @set 'dock_is_visible', false
  show_dock:   -> @set 'dock_is_visible', true
  toggle_dock: -> @toggleProperty 'dock_is_visible'

  enable_wizard_mode:  -> @hide_toolbar()
  disable_wizard_mode: -> @show_toolbar()

  scroll_to_top: -> 
    $('#content-wrapper').scrollTop(0) 
    $(window).scrollTop(0)

  current_transition: null
  get_current_transition:              -> @get 'current_transition'
  set_current_transition: (transition) -> @set 'current_transition', transition

  transition_is_for: (transition, match=null) ->
    return false unless (transition and match)
    target = transition.targetName or ''
    target.match(match)

  # ### Layout
  sticky_browser_resize: null

  set_component_column_as_sticky: (component) ->
    columns_class = ".#{config.grid.classes.columns}"
    sticky_class  = config.grid.classes.sticky
    $column       = component.$().parents(columns_class).first()
    return unless ember.isPresent($column)
    $column.addClass(sticky_class)
    $siblings = $column.siblings(columns_class)
    $siblings.addClass(sticky_class)
    @bind_sticky_columns()

  bind_sticky_columns: ->
    @add_height_to_sticky_columns()
    @bind_sticky_browser_resize()

  add_height_to_sticky_columns: ->
    sticky_class = ".#{config.grid.classes.sticky}"
    height       = @get_visible_content_height()
    $(sticky_class).each (i, container) =>
      $container = $(container)
      $container.css 'height', "#{height}px"

  get_visible_content_height: -> 
    h_window = $(window).height()
    h_nav    = $('#navbar').outerHeight()
    h_dock   = $('.thinkspace-dock').outerHeight()
    h_window - h_nav - h_dock

  bind_sticky_browser_resize: ->
    return if ember.isPresent(@get('sticky_browser_resize'))
    binding = $(window).resize =>
      @add_height_to_sticky_columns()
    @set 'sticky_browser_resize', binding


  # ### Notifications and sockets
  add_system_notification: (type, message, sticky=true) ->
    fn = totem_messages[type]
    totem_messages[type](message, sticky) if fn?