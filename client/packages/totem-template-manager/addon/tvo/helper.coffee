import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import totem_error    from 'totem/error'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'

export default ember.Object.extend

  # ###
  # ### Component Init Related.
  # ###

  register: (component, options={}) ->
    @is_component(component)
    section           = options.section or @get_component_section(component)
    options.component = component # set the component reference in the options to be registered in the section
    @tvo.section.register section, options

  # Create a computed property on the component that will become true when the 'tvo.section.section-name.ready' property(s) becomes true.
  # Options:
  #  ready:    default 'source'; name of the component's template attribute containing the section names to wait on ready
  #  property: default 'ready';  name of the property to define on the component
  define_ready: (component, options={}) ->
    @is_component(component)
    ready_watch = @tvo.section.ready_properties @get_component_attribute(component, options.ready or 'source')
    ready_prop  = options.property or 'ready'
    if ember.isBlank(ready_watch)
      ember.defineProperty component, ready_prop, ember.computed -> true
    else
      ember.defineProperty component, ready_prop, ember.computed.and ready_watch...

  # ###
  # ### Component Related.
  # ###

  get_component_attribute: (component, attr) ->
    @is_component(component)
    component.get "attributes.#{attr}"

  get_component_section: (component)         ->
    @is_component(component)
    @get_component_attribute(component, 'section')

  is_component: (component) ->
    totem_error.throw @, "Must pass a component as the first argument."  unless component
    totem_error.throw @, "First argument must a component instance."     unless component.get('instrumentName') == 'component'

  # Return a promise array that resolves to the record's association.
  # Can be used in a computed property and referenced in a template's 'each'.
  ownerable_view_association_promise_array: (component, options={}) ->
    @is_component(component)
    promise = new ember.RSVP.Promise (resolve, reject) =>
      record = options.model or component.get('model')
      @ownerable_view_association_records(record, options).then (records) =>
        @set_component_ready(component, options)
        @after_component_ready(component, options)
        resolve records
      , (error) => reject(error)
    ta.PromiseArray.create promise: promise

  set_component_ready: (component, options={}) ->
    return unless options.ready or options.after_ready
    @is_component(component)
    section = options.section or @get_component_section(component)
    totem_error.throw @, "Must pass a section component_ready."  unless section
    @tvo.section.ready section

  after_component_ready: (component, options={}) ->
    fn = options.after_ready
    return unless fn
    @is_component(component)
    totem_error.throw @, "Must pass a function to after_component_ready."  unless typeof(fn) == 'function'
    args = options.args or null
    fn.call(component, args)

  # ###
  # ### Record View Query.
  # ###

  load_ownerable_view_records: (record, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = totem_scope.get_unviewed_query(record, options)
      if query  # if the query is null, the record's ownerable data have already been loaded
        show_loading = not (options.show_loading == false)
        totem_messages.show_loading_outlet()  if show_loading
        record_type_key = totem_scope.record_type_key(record)
        record.store.find(record_type_key, query).then =>
          resolve()
          totem_messages.hide_loading_outlet()  if show_loading
        , (error) => reject(error)
      else
        resolve()

  # Return a promise that resolves to the record's association.
  # Query the server if the association records are not already loaded.
  ownerable_view_association_records: (record, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      association = options.association
      totem_error.throw @, "Must pass an association name to ownerable_view_association_records."  unless association
      @load_ownerable_view_records(record, options).then =>
        resolve record.get(association)
      , (error) => reject(error)

  # Return a promise that resolves to the record's association's association records.
  # Load the ownerable view records via the record, then for each association record
  # get its association's records.
  ownerable_view_association_records_each: (record, association_array, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      association_each = options.each
      totem_error.throw @, "Must pass an association_array to ownerable_view_association_records_each."  unless association_array
      totem_error.throw @, "Must pass an association_each to ownerable_view_association_records_each."   unless association_each
      @load_ownerable_view_records(record, options).then =>
        promises = association_array.getEach(association_each)
        ember.RSVP.Promise.all(promises).then (records) =>
          resolve(records)
        , (error) => reject(error)
      , (error) => reject(error)

  toString: -> 'TvoHelper'
