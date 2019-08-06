import ember from 'ember'

#####
# SelectView settings:
# 
# content:                        null | List of objects to select from. Can be either an array of ember records or strings. 
#                                          * Required
# optgroups                       null | Object categorically mapping optgroup names to arrays of ember records or strings. 
#                                          * Must contain all the objects in the supplied content
# multiple:                      false | If true, allows for selection of more than one option.
# data_placeholder: 'Select an Option' | Text which is displayed when no items are selected.
# no_select:                     false | If true, allows for single selection of no item. Uses data_placeholder as the display text if 'no_select_option_text' is not provided.
# no_select_option_text:          null | Option text for the 'No Response'/null option.
# display_property                null | Name of the property to use for displaying records
# class_names                       '' | Classes that are added to the select tag which can be inherited by chosen
# option_class_names                '' | Classes that are added to each option tag which can be inherited by chosen
# selected_items                    [] | Member or subset of content which is/are initially selected
# disabled_items                    [] | Member or subset of content which is/are initially disabled
# select_action                   null | Name of the controller action that a selection event will trigger
# deselect_action                 null | Name of the controller action that a deselection event will trigger
# value                           null | Name of the controller property that selected items will be set/added to.
# disabled                       false | If true, disables the select widget
# context                        null  | If set, updates chosen when context changes.
# validated                      false | If true and is multiple, makes a new array on each change to trigger ember-validations
## All of chosen-jquery's options can also be passed in. See http://harvesthq.github.io/chosen/options.html for a complete list.
#####

export default ember.View.extend
  tagName:           'select'
  templateName:      'select/select'
  attributeBindings: ['multiple', 'data_placeholder:data-placeholder']
  classNames:        ['chosen-select']
  classNameBindings: ['class_names']

  # HTML Attributes
  data_placeholder: 'Select an Option'
  multiple:         false

  # SelectView-specific options
  no_select:          false
  content:            null
  display_property:   null
  option_class_names: ''
  class_names:        ''
  selected_items:     []
  disabled_items:     []
  select_action:      null
  deselect_action:    null
  value:              null
  disabled:           false
  optgroups:          null
  context:            null
  validated:          false
  is_object_list:     false

  # Though the class_names passed in are correctly bound and updated on this view,
  # Chosen is not aware of the updates to the select element's classes,
  # so we manually remove and add them.
  update_class_names: ember.observer 'class_names', ->
    new_class_names = @get('class_names')
    old_class_names = @get('old_class_names')
    $chosen_select  = @$().siblings('.chosen-select')
    $chosen_select.removeClass(old_class_names)
    $chosen_select.addClass(new_class_names)
    @set 'old_class_names', new_class_names


  # Chosen-jQuery select options: see http://harvesthq.github.io/chosen/options.html for a list.
  allow_single_deselect:          false
  disable_search:                 false
  disable_search_threshold:       0
  enable_split_word_search:       true
  inherit_select_classes:         true
  max_selected_options:           Infinity
  no_results_text:                "No results match"
  placeholder_text_multiple:      "Select Some Options"
  placeholder_text_single:        "Select an Option"
  search_contains:                false
  single_backstroke_delete:       true
  display_disabled_options:       true
  display_selected_options:       true
  width:                          null

  single:                ember.computed.not 'multiple'
  show_empty_option:     ember.computed.and 'no_select', 'single'
  no_select_option_text: ember.computed.oneWay 'data_placeholder'
  optgroup:              ember.computed.notEmpty 'optgroups'
  select_ids_recomputed: 0

  # Determines whether the provided content is a list of records or not
  # => Specifically, checks if firstObject responds to .save(). Is there a better way?
  is_record_list: ( ->
    content   = @get('content')
    record    = content.get('firstObject') if content
    return record.save? if record

  ).property('content.firstObject', 'optgroups')

  # Parses optgroups into a 2d array to use for rendering in the template
  groups: ( ->
    optgroups = @get('optgroups')
    groups = []

    for name, optgroup of optgroups
      group = []
      for member in optgroup
        group.pushObject(member)
      groups.pushObject(group)

    groups
  ).property('optgroups')

  totem_select_id: ( ->
    @get('elementId')
  ).property('elementId')

  totem_select_id_property: ( ->
    totem_select_id = @get('totem_select_id')
    property = "totem_select_#{totem_select_id}_id"
  ).property('totem_select_id')

  # Ensures that select ids will still be set if the content is altered
  # and when promises are resolved it will rerender the select
  content_changed: ( ->
    @destroy_chosen()
    @rerender()
  ).observes('content', 'rerender_on')

  context_obs: (->
    @destroy_chosen()
    @$().trigger('chosen:updated')
  ).observes('context')

  didInsertElement: -> @initialize_chosen()

  initialize_chosen: ->
    view = @
    @set_select_ids()
    @set 'old_class_names', @get('class_names')
    options = @get_options()
    @$().chosen(options)
    @$().prop('disabled', true).trigger("chosen:updated") if @get('disabled')


    @$().on 'change', (evt, params) ->
      params = { deselected: '' } if params is undefined and view.get('allow_single_deselect') # seems weird that this is necessary
      id = params.selected if params and 'selected' of params
      id = params.deselected if params and 'deselected' of params

      unless id is undefined
        item       = if view.get('is_record_list') then view.get_record_with_id(id) else id
        controller = view.get('controller')
        value      = view.get('value')
        multiple   = view.get('multiple')
        validated  = view.get('validated')

        action     = if ('selected' of params) then view.get('select_action') else action = view.get('deselect_action') 

        if value
          values = value.split('.')
          prop   = values.pop()
          getter = values.join('.')

          switch
            when 'selected' of params
              if multiple
                controller.get(value).pushObject(item) if value? and controller.get(value).pushObject? and !controller.get(value).contains(item)
                if validated
                  new_array = ember.makeArray().concat(controller.get(value))
                  controller.set(value, new_array)
              else
                if ember.isEmpty(values)
                  controller.set(prop, item)
                else
                  obj    = controller.get(getter)
                  obj.set(prop, item)

            when 'deselected' of params
              if multiple
                controller.get(value).removeObject(item) if value? and controller.get(value).removeObject? and controller.get(value).contains(item)
                if validated
                  new_array = ember.makeArray().concat(controller.get(value))
                  controller.set(value, new_array)
              else
                if ember.isEmpty(values)
                  controller.set(prop, null)
                else
                  obj    = controller.get(getter)
                  obj.set(prop, null)

        controller.send(action, item) if action

  # Sets 'totem_select_id' on each record in the list so that this TotemSelect instance can uniquely identify all records in the list
  set_select_ids: ->
    if @get('is_record_list') and !@get('is_object_list')
      content                         = @get('content')
      totem_select_id_property        = @get('totem_select_id_property')
      content.forEach (record, index) =>
        record.set(totem_select_id_property, index + 1)
      @trigger_select_ids_recomputed()

  # Used to notify child views that the select ids have been reissued and the option values need updating
  trigger_select_ids_recomputed: ->
    @incrementProperty('select_ids_recomputed')

  # Gets the record corresponding with the 'totem_select_id' argument
  get_record_with_id: (id) ->
    record = null
    if id
      id                       = parseInt(id) if typeof id == 'string'
      totem_select_id_property = @get('totem_select_id_property')
      content                  = @get('content')
      content.forEach (item) =>
        if item.get(totem_select_id_property) == id
          record = item
    return record

  # Chosen will not destroy itself upon calling .chosen again, so manual removal is needed to prevent double rendering
  destroy_chosen: ->
    if @$()
      id              = @get('totem_select_id')
      chosen_id       = "#{id}_chosen"
      chosen_selector = '#' + chosen_id
      $chosen         = @$().siblings(chosen_selector)
      $chosen.remove()


  # Gets all the chosen options
  get_options: ->
    options =
      allow_single_deselect:     @get('allow_single_deselect')
      disable_search:            @get('disable_search')
      disable_search_threshold:  @get('disable_search_threshold')
      enable_split_word_search:  @get('enable_split_word_search')
      inherit_select_classes:    @get('inherit_select_classes')
      max_selected_options:      @get('max_selected_options')
      no_results_text:           @get('no_results_text')
      placeholder_text_multiple: @get('placeholder_text_multiple')
      placeholder_text_single:   @get('placeholder_text_single')
      search_contains:           @get('search_contains')
      single_backstroke_delete:  @get('single_backstroke_delete')
      display_disabled_options:  @get('display_disabled_options')
      display_selected_options:  @get('display_selected_options')
      width:                     @get('width')
