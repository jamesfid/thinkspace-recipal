import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'


export default ember.Object.extend
  # ### Properties
  model:     null
  id:        null
  label:     null
  type:      null
  settings:  null

  assessment:   null
  slider_step:  1
  slider_value: 3

  is_selected: false

  # ### Computed properties
  points_descriptive_enabled: ember.computed 'assessment.points_descriptive_enabled', 'model.settings.labels.scale.min', 'model.settings.labels.scale.max', ->
    (@get('points_descriptive_low') and @get('points_descriptive_high')) or @get('assessment.points_descriptive_enabled')

  points_descriptive_low: ember.computed 'assessment.points_descriptive_low', 'model.settings.labels.scale.min', ->
    @get_model_property('settings.labels.scale.min') or @get('assessment.points_descriptive_low')

  points_descriptive_high: ember.computed 'assessment.points_descriptive_high', 'model.settings.labels.scale.max', ->
    @get_model_property('settings.labels.scale.max') or @get('assessment.points_descriptive_high')

  points_min: ember.computed 'assessment.points_min', 'settings.points.min', ->
    s_points = @get 'settings.points.min'
    return s_points if ember.isPresent(s_points)
    a_points = @get 'assessment.points_min'   
    if ember.isPresent(a_points) then a_points else 0

  points_max: ember.computed 'assessment.points_max', 'settings.points.max', ->
    s_points = @get 'settings.points.max'
    return s_points if ember.isPresent(s_points)
    a_points = @get 'assessment.points_max'   
    if ember.isPresent(a_points) then a_points else 0

  has_comments: ember.computed 'settings.comments.enabled', -> @get 'settings.comments.enabled'

  # ### Events
  init: ->
    @_super()
    @map_model_properties()

  # ### Helpers
  map_model_properties: ->
    # Establish bindings for the template to use to access model properties more easily.
    model = @get 'model'
    @set 'id',       model.id
    @set 'label',    model.label
    @set 'type',     model.type
    @set 'settings', model.settings

  get_model_property: (path) ->
    model = @get 'model'
    model = ember.Object.create(model)
    model.get(path)

  # ### Setters
  set_value: (property, value) ->
    fn = "set_#{property}"
    return unless @[fn]?
    @[fn](value)
    @map_model_properties()

  set_points_min:      (points) ->       util.set_path_value @, 'model.settings.points.min', parseInt(points)
  set_points_max:      (points) ->       util.set_path_value @, 'model.settings.points.max', parseInt(points)
  set_scale_label_min: (label) ->        util.set_path_value @, 'model.settings.labels.scale.min', label
  set_scale_label_max: (label) ->        util.set_path_value @, 'model.settings.labels.scale.max', label
  set_has_comments:    (has_comments) -> util.set_path_value @, 'model.settings.comments.enabled', has_comments

  set_label: (label) ->
    model       = @get 'model'
    model.label = label