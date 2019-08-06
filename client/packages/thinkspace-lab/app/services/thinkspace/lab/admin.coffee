import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import totem_messages from 'totem-messages/messages'

export default ember.Service.extend

  test_ui_only: false
  test_ui_on:   -> @set 'test_ui_only', true
  test_ui_off:  -> @set 'test_ui_only', false

  # ###
  # ### Component Paths.
  # ###

  # ### Chart
  c_chart_show:      ns.to_p 'lab', 'builder', 'lab', 'chart', 'show'
  c_category_select: ns.to_p 'lab', 'builder', 'lab', 'chart', 'select_category'
  # ### Category
  c_category_show:   ns.to_p 'lab', 'builder', 'lab', 'category', 'show'
  c_category_new:    ns.to_p 'lab', 'builder', 'lab', 'category', 'new'
  c_category_edit:   ns.to_p 'lab', 'builder', 'lab', 'category', 'edit'
  c_category_form:   ns.to_p 'lab', 'builder', 'lab', 'category', 'form'
  c_category_delete: ns.to_p 'lab', 'builder', 'lab', 'category', 'destroy'
  # ### Result
  c_result_show:      ns.to_p 'lab', 'builder', 'lab', 'result', 'show'
  c_result_edit:      ns.to_p 'lab', 'builder', 'lab', 'result', 'edit'
  c_result_new:       ns.to_p 'lab', 'builder', 'lab', 'result', 'new'
  c_result_form:      ns.to_p 'lab', 'builder', 'lab', 'result', 'form'
  c_result_delete:    ns.to_p 'lab', 'builder', 'lab', 'result', 'destroy'
  c_form_analysis:    ns.to_p 'lab', 'builder', 'lab', 'result', 'form', 'analysis'
  c_form_abnormality: ns.to_p 'lab', 'builder', 'lab', 'result', 'form', 'abnormality'
  c_form_input:       ns.to_p 'lab', 'builder', 'lab', 'result', 'form', 'input'
  c_form_range:       ns.to_p 'lab', 'builder', 'lab', 'result', 'form', 'range'
  c_form_html:        ns.to_p 'lab', 'builder', 'lab', 'result', 'form', 'html'
  c_form_correctable: ns.to_p 'lab', 'builder', 'lab', 'result', 'form', 'correctable'
  # ### Common.
  c_validated_input:       ns.to_p 'common', 'shared', 'validated_input'
  c_dropdown_split_button: ns.to_p 'common', 'dropdown_split_button'

  # ###
  # ### Chart Send Requests.
  # ###

  load_chart: ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      chart = @get_chart()
      query =
        model:  chart
        id:     chart.get('id')
        verb:   'get'
        action: 'load'
      ajax.object(query).then (payload) =>
        chart.store.pushPayload(payload)
        resolve()
      , (error) =>
        reject(error)

  reorder_chart_categories: (changes) ->
    new ember.RSVP.Promise (resolve, reject) =>
      chart = @get_chart()
      query =
        model:  chart
        id:     chart.get('id')
        action: 'category_positions'
        verb:   'post'
        data:   
          category_positions: changes
      return resolve()  if @get('test_ui_only')
      totem_messages.show_loading_outlet()
      ajax.object(query).then =>
        totem_messages.hide_loading_outlet()
        resolve()
      , (error) =>
        reject(error)

  # ###
  # ### Category Send Requests.
  # ###

  save_category: (category, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      values = options.values
      @clone_category_values(category, values, options)  if ember.isPresent(values)
      category.get(ns.to_p 'lab:chart').then (chart) =>
        if ember.isBlank(chart)
          category.set ns.to_p('lab:chart'), @get_chart()
        return resolve()  if @get('test_ui_only')
        totem_messages.show_loading_outlet()
        category.save().then (category) =>
          totem_messages.hide_loading_outlet()
          resolve(category)
        , (error) =>
          totem_messages.api_failure error, source: @, model: category, action: 'save'

  delete_category: ->
    new ember.RSVP.Promise (resolve, reject) =>
      category = @get_selected_category()
      return resolve() if ember.isBlank(category)
      if @get('test_ui_only')
        category.unloadRecord()
        return resolve()
      category.deleteRecord()
      totem_messages.show_loading_outlet()
      category.save().then =>
          totem_messages.hide_loading_outlet()
          resolve(category)
        , (error) =>
          totem_messages.api_failure error, source: @, model: category, action: 'delete'

  reorder_category_results: (changes) ->
    new ember.RSVP.Promise (resolve, reject) =>
      category = @get_selected_category()
      query =
        model:  category
        id:     category.get('id')
        action: 'result_positions'
        verb:   'post'
        data:   
          result_positions: changes
      return resolve()  if @get('test_ui_only')
      ajax.object(query).then =>
        resolve()
      , (error) =>
        reject(error)

  clone_category_values: (category, values, options={}) ->
    props =
      title:    values.get('title')
      position: values.get('position')
      value:    values.get('value')
    options_props = options.properties
    props         = ember.merge(props, options_props)  if options_props
    category.setProperties(props)
    category

  # ###
  # ### Result Send Requests.
  # ###

  save_result: (result, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      values = options.values
      @clone_result_values(result, values, options)  if ember.isPresent(values)
      result.get(ns.to_p 'lab:category').then (category) =>
        if ember.isBlank(category)
          category = @get_selected_category()
          return reject('Selected category is blank.')  if ember.isBlank(category)
          result.set ns.to_p('lab:category'), category
        return resolve()  if @get('test_ui_only')
        totem_messages.show_loading_outlet()
        result.save().then (result) =>
          totem_messages.hide_loading_outlet()
          resolve(result)
        , (error) =>
          totem_messages.api_failure error, source: @, model: result, action: 'save'

  delete_result: ->
    new ember.RSVP.Promise (resolve, reject) =>
      result = @get_action_overlay_model()
      return resolve() if ember.isBlank(result)
      if @get('test_ui_only')
        result.unloadRecord()
        return resolve()
      result.deleteRecord()
      totem_messages.show_loading_outlet()
      result.save().then =>
          totem_messages.hide_loading_outlet()
          resolve(result)
        , (error) =>
          totem_messages.api_failure error, source: @, model: result, action: 'delete'

  clone_result_values: (result, values, options={}) ->
    props = 
      title:    values.get('title')
      position: values.get('position')
      metadata: values.get('metadata')
      value:    values.get('value')
    options_props = options.properties
    props         = ember.merge(props, options_props)  if options_props
    result.setProperties(props)
    result

  # ###
  # ### Sortables.
  # ###

  category_sortable_selector: '.ts-lab_admin-sortable-categories'
  result_sortable_selector:   '.ts-lab_admin-sortable-results'

  get_category_sortable_selector: -> @get('category_sortable_selector')
  get_result_sortable_selector:   -> @get('result_sortable_selector')

  on_drop_category_reorder: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      chart = @get_chart()
      @get_chart_categories().then (categories) =>
        selector = @get_category_sortable_selector()
        changes  = @find_and_set_reorder_changes(selector, categories, 'li')
        # console.info 'category changes:', changes
        return resolve()  if ember.isBlank(changes)
        component   = options.component
        notify_prop = options.notify
        if component and notify_prop
          component.notifyPropertyChange(notify_prop)
        @reorder_chart_categories(changes).then => resolve()

  on_drop_result_reorder: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_category_results().then (results) =>
        selector = @get_result_sortable_selector() + ':visible'
        changes  = @find_and_set_reorder_changes(selector, results, 'tr')
        # console.info 'result changes:', changes
        return resolve()  if ember.isBlank(changes)
        component   = options.component
        notify_prop = options.notify
        if component and notify_prop
          component.notifyPropertyChange(notify_prop)
        @reorder_category_results(changes).then => resolve()

  find_and_set_reorder_changes: (selector, records, tag) ->
    $items  = $(selector).find(tag)
    changes = []
    $items.each (index, child) =>
      rec_pos = index + 1
      $child  = $(child)
      id      = $child.attr('model_id')
      record  = records.findBy 'id', id
      if record
        position = record.get('position')
        unless position == rec_pos
          record.set 'position', rec_pos
          changes.push {id: id, position: rec_pos}
    changes

  # ###
  # ### Base Properties.
  # ###

  store:           null
  chart:           null
  admin_component: null

  selected_category:          null
  selected_category_columns:  null
  selected_category_headings: null

  get_store:         -> @get 'store'
  set_store: (store) -> @set 'store', store

  get_chart:         -> @get 'chart'
  set_chart: (chart) -> @set 'chart', chart

  get_admin_component:             -> @get 'admin_component'
  set_admin_component: (component) -> @set 'admin_component', component

  reset_selected_category: -> @set_selected_category @get_selected_category()

  get_selected_category: -> @get('selected_category')
  set_selected_category: (category) ->
    return if ember.isBlank(category)
    columns  = @category_columns(category)
    headings = columns.map (column) -> column.heading
    @setProperties
      selected_category:          category
      selected_category_columns:  columns
      selected_category_headings: headings

  get_selected_category_columns: -> @get('selected_category_columns') or []

  exit: -> @get_admin_component().send('exit')

  clear: ->
    @set_action_overlay_off()
    @setProperties
      selected_category:          null
      selected_category_columns:  null
      selected_category_headings: null

  # ###
  # ### Action Overlay Properties.
  # ###

  has_action_overlay: false

  c_action_overlay:       null
  action_overlay_model:   null
  result_form_components: []

  new_result_type:             null
  result_value_edit_component: null
  result_value_edit_model:     null

  set_action_overlay_off: ->
    @set 'has_action_overlay', false
    ember.run.schedule 'afterRender', => @clear_overlay_values()

  set_action_overlay: (component_name) ->
    name = @get(component_name)
    @set 'c_action_overlay', name
    @set 'has_action_overlay', true

  get_action_overlay_model:          -> @get 'action_overlay_model'
  set_action_overlay_model: (record) -> @set 'action_overlay_model', record

  is_result_value_edit_component: (component) ->
    result = component.get('model')
    component == @get('result_value_edit_component') and @guid_for(result) == @get('result_value_edit_model')

  set_result_value_edit_component: (component) ->
    prev_component = @get('result_value_edit_component')
    prev_component.rollback()  if ember.isPresent(prev_component)  # clicked on another result value (e.g. did not select cancel)
    @setProperties
      result_value_edit_component: component
      result_value_edit_model:     @guid_for component.get('model')

  get_result_form_components:            -> @get('result_form_components')
  add_result_form_component: (component) -> @get_result_form_components().push(component)

  guid_for: (object) -> ember.guidFor(object)

  set_edit_result_has_errors: (errors=true) -> @set 'edit_result_has_errors', errors

  clear_overlay_values: ->
    @setProperties
      new_result_type:             null
      result_value_edit_component: null
      result_value_edit_model:     null
      result_form_components:      []
      action_overlay_model:        null
      c_action_overlay:            null

  # ###
  # ### Chart.
  # ###

  set_chart_selected_category: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_chart_categories().then (categories) =>
        selected_category = categories.sortBy('position').get('firstObject')
        @set_selected_category(selected_category)  if selected_category
        resolve()

  get_chart_categories: ->
    new ember.RSVP.Promise (resolve, reject) =>
      chart = @get_chart()
      return reject()  if ember.isBlank(chart)
      chart.get(ns.to_p 'lab:categories').then (categories) =>
        resolve(categories)
      , (error) => reject()

  # ###
  # ### Category.
  # ###

  get_category_results: ->
    new ember.RSVP.Promise (resolve, reject) =>
      category = @get_selected_category()
      return reject()  if ember.isBlank(category)
      category.get(ns.to_p 'lab:results').then (results) =>
        resolve(results)
      , (error) => reject()

  mock_new_category_record: ember.Object.extend
    columns:             ember.computed.reads 'value.columns'
    description_heading: ember.computed -> @get('value.description') or 'Description'
    toString: -> 'mock_lab_category'

  category_columns: (category) ->
    columns         = []
    cat_columns     = category.get('columns') or []
    has_description = false
    cat_columns.map (cat_column) =>
      column          = ember.merge {}, cat_column
      has_description = true if column.source == 'description'
      columns.push(column)
    unless has_description
      columns.push({heading: category.get('description_heading'), source: 'description'})
    columns

  get_mock_new_category_record: ->
    @get('mock_new_category_record').create @category_new_defaults()

  category_new_defaults: ->
    title:    ''
    position: 0
    value:    
      component:           'vet_med'
      description_heading: @i18n_category_heading('description')
      correctable_prompt:  @t('builder.lab.category.correctable_prompt')
      columns: [
        {heading: @i18n_category_heading('result_name'), source: 'title'}
        {heading: @i18n_category_heading('result'),      source: 'result'}
        {heading: @i18n_category_heading('units'),       source: 'units'}
        {heading: @i18n_category_heading('range'),       source: 'ratings', range: true}
        {heading: @i18n_category_heading('analysis'),    observation: 'analysis'}
        {heading: @i18n_category_heading('abnormality'), observation: 'abnormality'}
      ]

  category_clone: (category) ->
    chart  = @get('chart')
    clone = chart.store.createRecord ns.to_p('lab:category')
    @set_clone_category_values(clone, category)
    clone.set ns.to_p('lab:chart'), chart
    chart.get(ns.to_p 'lab:categories').then (categories) =>
      categories.pushObject(clone)
      @get('admin').set_selected_category(clone)
      @send 'clear_action_overlay'

  i18n_category_heading: (key) -> @t("builder.lab.category.heading.#{key}")

  # ###
  # ### Result.
  # ###

  result_title_column: -> @get_selected_category_columns().findBy 'source', 'title'

  result_type_columns: (result, type) ->
    columns = []
    switch type
      when 'result'           then @add_result_columns(columns)
      when 'adjusted_result'  then @add_adjusted_result_columns(columns)
      when 'html_result'      then @add_html_result_columns(columns)
    @result_columns(columns, result)

  result_columns: (columns, result) ->
    return [] unless columns
    columns.map (col) =>
      column = ember.merge {}, col
      @set_component_values(column, result)

  set_component_values: (column, result) ->
    if column.observation
      column.fieldset = true
      switch column.observation
        when 'analysis'
          column.component  = @get('c_form_analysis')
          column.value_path = ['value.observations.analysis.selections', 'value.observations.analysis.normal', 'metadata.analysis.validate.correct']
        when 'abnormality'
          column.component  = @get('c_form_abnormality')
          column.value_path = ['metadata.abnormality.validate.correct', 'metadata.abnormality.max_attempts']
    else
      if ember.isPresent(column.correctable)
        column.fieldset   = true
        column.value_path = ['metadata.analysis.validate.correct', 'metadata.analysis.max_attempts']
      else
        column.fieldset = false
      switch column.source
        when 'title'
          column.component  = @get('c_form_input')
          column.value_path = 'title'
        when 'description'
          column.component  = @get('c_form_input')
          column.value_path = 'value.description'
        when 'result'
          column.component  = @get('c_form_input')
          column.value_path = 'value.columns.result'
          column.component  = @get('c_form_html')  if result.get('admin_is_html')
        when 'units'
          column.component  = @get('c_form_input')
          column.value_path = 'value.columns.units'
        when 'ratings'
          if column.range
            column.component  = @get('c_form_range')
            column.value_path = ['value.columns.ratings.lower', 'value.columns.ratings.upper']
            column.fieldset   = true
          else
            column.component  = @get('c_form_input')
            column.value_path = 'value.columns.ratings'
    column

  result_sources:      ['description', 'result', 'units', 'ratings']
  result_observations: ['analysis', 'abnormality']

  add_html_result_columns: (columns) ->
    @add_result_title_column(columns)
    columns.push {heading: @i18n_result_form_heading('html_result'), source: 'result'}

  add_adjusted_result_columns: (columns) ->
    @add_common_result_columns columns, @get('result_sources'), []
    columns.push {heading: @i18n_result_form_heading('adjusted_result'), component: @get('c_form_correctable'), correctable: true}

  add_result_columns: (columns) ->
    @add_common_result_columns columns, @get('result_sources'), @get('result_observations')

  add_result_title_column: (columns) ->
    title_column = @result_title_column()
    columns.push title_column if ember.isPresent(title_column)

  add_common_result_columns: (columns, sources, observations) ->
    @add_result_title_column(columns)
    # Set the result columns in the same order as in the category.
    common_columns = @get_selected_category_columns().filter (column) =>
      sources.contains(column.source) or observations.contains(column.observation)
    common_columns.forEach (column) =>
      result_column = {heading: column.heading}
      if column.observation
        result_column.observation = column.observation
      else
        result_column.source = column.source
        result_column.range  = column.range  if column.range
      columns.push(result_column)

  i18n_result_form_heading: (key) -> @t("builder.lab.admin.form.result_heading.#{key}")

  # ###
  # ### New Result Type Record Mock.
  # ###

  mock_new_result_record: ember.Object.extend
    admin_type: ember.computed.reads 'value.type'
    toString: -> 'mock_lab_result'

  get_mock_new_result_record: (type) ->
    props = @result_type_defaults()[type] or {}
    @get('mock_new_result_record').create(props)

  result_type_defaults: ->
    adjusted_result:
      admin_is_adjusted: true
      title:    ''
      position: 0
      metadata: 
        abnormality:
          no_value: true
        analysis:
          lock_on_max_attempts: false
          max_attempts:         3
          validate:             
            correct: ''
            correct_method: 'standard_adjusted'
      value:
        type: 'adjusted_result'
        columns:
          ratings:
            lower: ''
            upper: ''
          result: ''
          units:  ''
        description: ''
        observations:
          abnormality:
            input_type: 'none'
          analysis:
            input_type: 'correctable'

    html_result:
      admin_is_html: true
      title:    ''
      position: 0
      metadata: {}
      value:    
        type: 'html_result'
        columns:
          result: ''
        description: ''
        observations: {}

    result:
      title:    ''
      position: 0
      metadata: 
        abnormality:
          max_attempts: 3
          validate:
            correct: []
        analysis:
          validate:
            correct: 'normal'
      value:    
        type: 'result'
        columns:
          ratings:
            lower: ''
            upper: ''
          result: ''
          units:  ''
        description: ''
        observations:
          abnormality:
            input_type: 'input'
          analysis:
            input_type: 'select'
            normal:     'normal'
            selections: [
              {id: 'normal', label: 'Normal'}
              {id: 'high',   label: 'High'}
              {id: 'low',    label: 'Low'}
            ]
