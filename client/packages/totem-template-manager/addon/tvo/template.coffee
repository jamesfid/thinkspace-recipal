import ember  from 'ember'
import {mp}   from 'totem/config'
import config from 'totem/config'
import ns     from 'totem/ns'

export default ember.Object.extend

  parse: (template) -> @_parse(template)

  add_components: (components) -> @_add_components(components)

  get_template: -> @get('$template')

  to_html: -> @get_template().html()
  compile: -> ember.Handlebars.compile @to_html()

  toString: -> 'TvoTemplate'

  # ##################
  # ### Internal ### #
  # ##################

  # ###
  # ### Parse Template.
  # ###

  _parse: (template) ->
    $template = $('<div/>').html(template)
    @_set_component_sections($template)
    @_replace_rows($template)
    @_replace_columns($template)
    @set '$template', $template
    @get_template()

  # Default a component's section value to the 'title' attribute if the 'section' attribute is not specified.
  _set_component_sections: ($template) ->
    $components = $template.find('component')
    for component in $components
      $comp = $(component)
      $comp.attr 'section', @tvo.tag_title($comp)  unless $comp.attr('section')

  _replace_rows: ($template) ->
    $rows = $template.find('row')
    for row in $rows
      $row      = $(row)
      $children = $row.children()
      $new_row  = $(@_row_html($row))
      $row.replaceWith($new_row)
      $new_row.append($children)

  _replace_columns: ($template) ->
    $cols = $template.find('column')
    for col in $cols
      $col      = $(col)
      $children = $col.children()
      $new_col  = $(@_col_html($col))
      $col.replaceWith($new_col)
      $new_col.append($children)

  _row_html: ($row) ->
    hash       = @tvo.tag_attribute_hash($row)
    hash.class = @_get_tag_classes($row, 'row')
    @_tag_with_attributes('div', hash)

  _col_html: ($col) ->
    hash = @tvo.tag_attribute_hash($col)
    cols = hash.width or 12
    delete(hash.width)
    columns_class = config.grid.classes.columns
    hash.class    = @_get_tag_classes($col, "#{columns_class} small-#{cols}")
    @_tag_with_attributes('div', hash)

  _tag_with_attributes: (tag, hash) ->
    new_tag = "<#{tag}"
    for own attr_name, attr_value of hash
      new_tag += " #{attr_name}='#{attr_value}'"
    new_tag += '>'
    new_tag

  _get_tag_classes: ($tag, classes='') -> (@tvo.tag_class($tag) + ' ' + classes).trim()

  # ###
  # ### Add Components.
  # ###

  _add_components: (components) ->
    new ember.RSVP.Promise (resolve, reject) =>
      common_component_promises = components.getEach(ns.to_p 'component')
      componentable_promises    = components.getEach('componentable')
      ember.RSVP.Promise.all(common_component_promises).then (common_components) =>
        ember.RSVP.Promise.all(componentable_promises).then (componentables) =>
          component_promises = []
          components.forEach (component, index) =>
            common_component = common_components.objectAt(index)
            componentable    = componentables.objectAt(index)
            component_promises.push @_add_component(common_component, component, componentable)
          ember.RSVP.Promise.all(component_promises).then =>
            resolve()
          , (error) =>
            console.error error

  _add_component: (common_component, component, componentable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      section          = component.get('section')
      $comp            = @_get_component_section_tag(section)
      preprocessors    = @_get_section_preprocessors(common_component, $comp)
      if ember.isPresent(preprocessors)
        preprocessor_promises = []
        bind_attributes       = []
        hash                  = {}
        for preprocessor in preprocessors
          attribute = preprocessor.attribute
          bind_attributes.push preprocessor.bind or attribute
          # May be multiple preprocessors for an attribute (paths is an array of arrays)
          # e.g. [ ['pre1-path1', pre1-path2], ['pre2-path1', pre2-path2, pre2-path3, ...] ]
          # Each nested-array is then converted in a module path using ns.to_p.
          paths = preprocessor.paths
          paths = paths.map (p) -> ns.to_p(p)  # convert each preprocessor path array into a ns path string
          value = componentable.get(attribute)
          preprocessor_promises.push @_preprocess(paths, componentable, value)
        # Run each attribute's preprocessors 'in order' to get all the preprocessed attributes final values.
        ember.RSVP.Promise.all(preprocessor_promises).then (values) =>
          hash[attr] = values.shift()  for attr in bind_attributes  # add attribute values to the hash so can bind on the component
          @_replace_template_component_html(common_component, component, componentable, section, hash)
          resolve()
        , (error) =>
          reject(error)
      else
        @_replace_template_component_html(common_component, component, componentable, section, hash)
        resolve()

  _get_component_section_tag: (section) ->
    $comp  = @get_template().find("component[section=#{section}]")
    length = $comp.length
    switch
      when length > 1
        console.warn "Section [#{section}] is duplicated #{length} times."
        null
      when length < 1
        console.warn "Section [#{section}] is not found."
        null
      else
        $comp

  # To override preprocessors and/or namespace information on the <component> tag need to add
  # the values in a jquery data object.
  # e.g. <component ... data-preprocessors='[{"attribute": "html_content", "paths": [["input_element", "preprocessors", "responses"]]}]'/>
  _get_section_preprocessors: (common_component, $comp) -> $comp.data('preprocessors') or common_component.get('preprocessors')

  # e.g. <component ... data-path='["html", "mypath", "myname"]'/>
  _get_component_path: (common_component, $comp) -> $comp.data('path') or common_component.get('value.path')

  _replace_template_component_html: (common_component, component, componentable, section, hash={}) ->
    $comp           = @_get_component_section_tag(section)
    component_path  = ns.to_p @_get_component_path(common_component, $comp)
    hash.attributes = @tvo.tag_attribute_hash($comp)
    hash.model      = componentable
    # The 'path' returned from 'tvo.value.set_value_for' is 'tvo.value' + guid of the object
    # (e.g. tvo.value.ember1234).  The hash keys are then referenced from this path e.g. tvo.value.ember1234.model.
    path            = @tvo.value.set_value_for component, hash
    bind_properties = @_get_bind_properties(path, hash)
    bind_actions    = @_get_bind_actions($comp)
    @tvo.set_path_value "#{path}.component_path", component_path
    # Create the componet's html with bindings from the hash key=value.
    html = '{{ component'
    html += " tvo.#{path}.component_path"
    html += bind_properties
    html += bind_actions
    html += ' }}'
    $comp.replaceWith(html)

  _get_bind_properties: (path, hash) ->
    keys = []
    keys.push key for own key of hash
    bind = ''
    return bind if ember.isBlank(keys)
    bind += " #{key}=tvo.#{path}.#{key}"  for key in keys
    bind

  _get_bind_actions: ($comp) ->
    actions = $comp.data('actions')
    bind    = ''
    return bind unless actions
    bind += " #{key}='#{value}'"  for own key, value of actions
    bind

  _preprocess: (preprocessors, componentable, value=null) ->
    new ember.RSVP.Promise (resolve, reject) => 
      tasks   = preprocessors.map => @_call_preprocessor
      promise = tasks.reduce (cur, next, i) =>
        return cur.then (value) =>
          preprocessor = preprocessors[i]
          return next.call(@, preprocessor, componentable, value)
      , ember.RSVP.resolve(value)
      promise.then (value) =>
        resolve(value)
      , (error) =>
        reject(error)
    , (error) =>
      reject(error)

  _call_preprocessor: (preprocessor, componentable, value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      mod      = "#{mp}#{preprocessor}"
      comp_mod = "#{mp}components/#{preprocessor}"
      req_mod  = null
      ember.tryCatchFinally(
        (=> req_mod = require comp_mod)  # try the component path first
        (=> req_mod = require mod)
        (=> req_mod)
      )
      return reject("Preprocessor [#{preprocessor}] could not be found by a require of path [#{comp_mod}] -or- [#{mod}].")  unless req_mod
      inst = req_mod.default.create(tvo: @tvo)
      inst.process(componentable, value).then (value) =>
        resolve(value)
      , (error) =>
        reject(error)

  # ###
  # ### Tests.
  # ###

  # _test_component: ->
  #   console.clear()
  #   component = {}
  #   hash      = {}
  #   store     = tvo.container.lookup 'store:main' # need to pass in the app container on tvo.create(container: Orchid.__container__)
  #   value     = '<input type="text" name="test_1"/>'
  #   element   = store.createRecord ns.to_p('element'),
  #     name: 'test_1'
  #   componentable = store.createRecord ns.to_p('content'),
  #     tool_content: value
  #   componentable.get(ns.to_p 'elements').then (elements) =>
  #     elements.pushObject(element)  unless elements.contains(element)
  #     preprocessors = ['components/' + ns.to_p('elements', 'preprocessor')]
  #     @_preprocess(preprocessors, componentable, value).then (value) =>
  #       hash.tool_content = value
  #       @_replace_template_component_html({}, componentable, 'html-1', hash)
  #       console.info @get_template(), hash

  # _test_preprocess_run_in_order: ->
  #   console.warn '.....test call preprocessors start.....'
  #   @_test_preprocess().then (value) =>
  #     console.warn '.....test final value=', value
  #     console.warn '.....test call preprocessors resolved.....'
  #   , (error) =>
  #     console.warn '!!!!!test preprocessor rejected!!!!!'

  # _test_preprocess: ->
  #   new ember.RSVP.Promise (resolve, reject) =>
  #     value         = 'test'
  #     preprocessors = ['aaaaa', 'bbbbb', 'ccccc', 'ddddd']
  #     tasks         = preprocessors.map => @_test_call_preprocessor
  #     promises = tasks.reduce (cur, next, i) => 
  #       return cur.then (value) =>
  #         preprocessor = preprocessors[i]
  #         return next.call(@, preprocessor, value)
  #     , ember.RSVP.resolve(value)
  #     promises.then (value) =>
  #       resolve(value)
  #   , (error) =>
  #     reject(error)

  # _test_call_preprocessor: (preprocessor, value, timeout=1000) ->
  #   new ember.RSVP.Promise (resolve, reject) =>
  #     setTimeout =>
  #       value += "->#{preprocessor}"
  #       console.info 'called preprocessor=', preprocessor, '  value=', value
  #       resolve(value)
  #     , timeout
