import ember from 'ember'
import ns    from 'totem/ns'
import ajax           from 'totem/ajax'
import totem_error    from 'totem/error'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'
import js_delta       from 'thinkspace-diagnostic-path/path_manager/jquery_sortable/delta'

export default ember.Object.create
  # ###
  # ### DRAGEND entry points.
  # ###
  dragend_new_diagnostic_path_item: (path, event, itemable_type, itemable_id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      item  = @get_new_path_item(path, path_itemable_type: itemable_type, path_itemable_id: itemable_id)
      delta = new js_delta(path, event, item)
      delta.process().then =>
        @update_path(delta).then =>
          resolve()

  dragend_move_diagnostic_path_items: (path, event) ->
    new ember.RSVP.Promise (resolve, reject) =>
      delta = new js_delta(path, event)
      delta.process().then =>
        @update_path(delta).then =>
          resolve()

  dragend_new_mechanism_path_item: (path, event, description='') ->
    new ember.RSVP.Promise (resolve, reject) =>
      item  = @get_new_mechanism_path_item(path, description)
      delta = new js_delta(path, event, item)
      delta.process().then =>
        @update_path(delta).then =>
          resolve()

  update_path: (delta) ->
    new ember.RSVP.Promise (resolve, reject) =>
      console.info " [Start] Processing with delta: ", delta
      return resolve() if @is_invalid_change(delta)

      status = delta.get('status')
      switch status
        when 'add_new_item'
          @process_increments_for_move('future', delta)
        when 'reorder_item_down'
          @process_decrements_for_reorder('future', delta)
          delta.set('future.position', parseInt(delta.get('future.position')) - 1)
        when 'reorder_item_up'
          @process_increments_for_reorder('future', delta)
        when 'move_item'
          @process_decrements_for_move('original', delta) if ember.isPresent(delta.get('original.parent.children')) and not delta.get('is_new')
          @process_increments_for_move('future', delta)   if ember.isPresent(delta.get('future.parent.children'))

      console.info "[End] Finished processing, resulting delta: ", delta
      @process_handlers(delta).then =>
        @set_original_item_parent_and_position(delta)
        @save_delta(delta).then =>
          resolve()

  set_original_item_parent_and_position: (delta) ->
    path     = delta.get('path')
    item     = delta.get('original.item.record')
    parent   = delta.get('future.parent.record')
    position = delta.get('future.position')
    if ember.isPresent(parent) then parent_id = parent.get('id') else parent_id = null
    item.set 'parent_id', parent_id
    item.set 'position',  position
    item.set 'path_id',   path.get('id')

  process_decrements_for_reorder: (type, delta) ->
    children = delta.get("#{type}.parent.children")
    return unless ember.isPresent(children)
    decrements = children.slice(delta.get('original.position') + 1, delta.get('future.position'))
    @add_items_to_changes(decrements, -1, delta)

  process_increments_for_reorder: (type, delta) ->
    children = delta.get("#{type}.parent.children")
    return unless ember.isPresent(children)
    increments = children.slice(delta.get('future.position'), delta.get('original.position'))
    increments.removeObject(delta.get('original.item.record')) # Don't process the original record since it would be in this set.
    @add_items_to_changes(increments, 1, delta)

  process_decrements_for_move: (type, delta) ->
    children = delta.get("#{type}.parent.children")
    return unless ember.isPresent(children)
    index      = children.indexOf(delta.get('original.item.record'))
    decrements = children.slice(index + 1, children.get('length'))
    @add_items_to_changes(decrements, -1, delta)

  process_increments_for_move: (type, delta) ->
    children = delta.get("#{type}.parent.children")
    position = delta.get("#{type}.position")
    return unless ember.isPresent(children)
    increments = children.slice(position, children.get('length'))
    @add_items_to_changes(increments, 1, delta)

  process_handlers: (delta) ->
    new ember.RSVP.Promise (resolve, reject) =>
      handlers = []
      ember.RSVP.all(handlers).then =>
        resolve()

  add_items_to_changes: (items, position_offset, delta) ->
    changes = delta.get('changes')
    items.forEach (item) =>
      changes[item.get('id')] = { position: item.get('position') + position_offset, parent_id: item.get('parent_id') }
    delta.set('changes', changes)

  save_delta: (delta) ->
    new ember.RSVP.Promise (resolve, reject) =>
      path      = delta.get('path')
      path_item = delta.get('original.item.record')
      changes   = delta.get('changes')

      path_item.save().then (path_item) =>
        if ember.isPresent(ember.keys(changes))
          query =
            verb:      'put'
            action:    'bulk'
            model:     path
            id:        path.get('id')
            ownerable: totem_scope.get_ownerable_record()
            data:      
              path_items: changes
          ajax.object(query).then (payload) =>
            totem_messages.api_success source: @, model: path_item, i18n_path: ns.to_o('path_item', 'save')
            path_item.store.pushPayload payload
            resolve()
          , (error) =>
            totem_messages.api_failure error, source: @, model: path_item
        else
          totem_messages.api_success source: @, model: path_item, i18n_path: ns.to_o('path_item', 'save')
          resolve()

  get_path_item_from_id: (path, id) ->
    # Path is just used for store access.
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null) unless ember.isPresent(id)
      path.store.find(ns.to_p('path_item'), id).then (path_item) =>
        resolve(path_item)

  is_invalid_change: (delta) ->
    path     = delta.get('path')
    item     = delta.get('original.item.record')
    parent   = delta.get('future.parent.record')
    position = delta.get('future.position')
    invalid  = false
    invalid  = true if ember.isEqual(parent, item) # Do not process if you're nesting into yourself.
    # Handle case of nesting under a children's children.
    if ember.isPresent(parent)
      $path_item    = $(".diag-path_list-item [model_id='#{parent.get('id')}']")
      parents_query = $path_item.parents("[model_id='#{item.get('id')}']")
      invalid       = true unless parents_query.length == 0
    invalid

  assign_children_to_grandparent: (delta) ->
    new ember.RSVP.Promise (resolve, reject) =>
      path = delta.get('path')
      return resolve() if delta.get('event.is_collapsed')
      item   = delta.get('original.item.record')
      return resolve() unless ember.isPresent(item)
      parent = delta.get('original.parent.record')
      if     ember.isPresent(parent) then parent_id = parent.get('id') else parent_id = null
      switch
        when ember.isPresent(parent_id) # Parent is an item.
          item.store.find(ns.to_p('path_item'), parent_id).then (grandparent) =>
            grandparent.get(ns.to_p('path_items')).then (siblings) =>
              item.get(ns.to_p('path_items')).then (children) =>
                children       = children.sortBy('position')
                grandparent_id = grandparent.get('id')
                position       = siblings.get('length')
                position       = position - 1 unless ember.isEqual(parent, delta.get('future.parent.record'))
                children.forEach (child) =>
                  child.set('parent_id', grandparent_id)
                  child.set('position', position)
                  changes                  = delta.get('changes')
                  changes[child.get('id')] = { position: position, parent_id: grandparent_id }
                  delta.set('changes', changes)
                  position++
                resolve()
        else # Parent is the path.
          item.get(ns.to_p('path_items')).then (children) =>
            children = children.sortBy('position')
            position = path.get('children.length')
            position = position - 1 if ember.isPresent(delta.get('future.parent.record'))
            children.forEach (child) =>
              child.set('parent_id', null)
              child.set('position', position)
              changes                  = delta.get('changes')
              changes[child.get('id')] = { position: position, parent_id: null }
              delta.set('changes', changes)
              position++
            resolve()

  sync_ember_path_item_parent: (path, path_item, changes) ->
    # This hook could be used to do client side relationship manipulation to smooth out the UX.
    # Currently, the path relies on didUpdate/didLoad hooks to set the relationships accordingly.
    # The code below will render it more quickly and without the 'pops' that the server side loads bring.
    # The downside is that it involves a race condition when operations are done quickly.
    new ember.RSVP.Promise (resolve, reject) =>
      resolve()
      # original_parent_id = path_item.get('parent_id')
      # new_parent         = changes.parent
      # new_parent_id      = (new_parent and new_parent.get('id')) or null
      # switch
      #   when ember.isPresent(original_parent_id)
      #     path.store.find(ns.to_p('path_item'), original_parent_id).then (parent_path_item) =>
      #       parent_path_item.get(ns.to_p('path_items')).then (path_items) =>
      #         path_items.removeObject(path_item) if path_items.contains(path_item)
      #         resolve()
      #   when ember.isPresent(new_parent_id)
      #     path.store.find(ns.to_p('path_item'), new_parent_id).then (parent_path_item) =>
      #       parent_path_item.get(ns.to_p('path_items')).then (path_items) =>
      #         path_items.pushObject(path_item) unless path_items.contains(path_item)
      #         resolve()
      #   else
      #     resolve()

  # ###
  # ### DESTROY Path Item(s) (e.g. path item and any children).
  # ###

  all_path_item_children: (path_item, children=[], depth=0, max=20) ->
    depth += 1
    totem_error.throw @, "Maximum depth exceeded (#{max}) getting all path item children ."  if depth > max  # max is a sanity check, nothing exact
    items = path_item.get('path_items')
    items.forEach (item) =>
      children.push item
      @all_path_item_children(item, children, depth)
    children

  destroy_path_item: (path_item) ->
    path_item.get(ns.to_p 'path').then (path) =>
      items = @all_path_item_children(path_item)
      items.push path_item
      @destroy_path_items_and_unload(path, items)

  # A path item destroy always calls the 'bulk_destroy' action with the path item id and any nested
  # path item ids.  A 'deleteRecord' and 'save' is not performed on the path item, but rather the path item
  # is 'unloaded' (along with any nested path items) since they have been destroyed on the server.
  destroy_path_items_and_unload: (path, path_items) ->
    if ember.isPresent(path_items)
      query =
        verb:      'delete'
        action:    'bulk_destroy'
        model:     path
        id:        path.get('id')
        data:      
          path_items: path_items.mapBy 'id'
      ajax.object(query).then =>
        path_items.forEach (path_item) => path_item.deleteRecord()
        totem_messages.api_success source: @, model: path_items, action: 'bulk_destroy', i18n_path: ns.to_o('path', 'save'), i18n: []
        @unload_path_items(path, path_items)
      , (error) =>
        totem_messages.api_failure error, source: @, model: path_items, action: 'bulk_destroy'

  unload_path_items: (path, path_items) ->
    @set_path_items_itemables_is_used(path_items, false).then =>
      path_items.forEach (item) => item.unloadRecord()
      @set_path_path_item_itemables_is_used(path, true)

  # ###
  # ### Helpers.
  # ###

  get_new_path_item: (path, new_options) ->
    new_item = path.store.createRecord ns.to_p('path_item')
    totem_scope.set_record_ownerable_attributes(new_item)
    new_item.set(attr, new_options[attr])  for own attr of new_options
    new_item

  get_new_mechanism_path_item: (path, label) ->
    item = path.store.createRecord ns.to_p('path_item'),
      description: label
    totem_scope.set_record_ownerable_attributes(item)
    item

  is_same_level: ($item, $items) -> $.inArray($item, $items)

  is_same_model: ($one, $two) ->
    return false unless ember.isPresent($one)
    return false unless ember.isPresent($two)
    $one.attr('model_id') == $two.attr('model_id')

  debug_event_status: (event) ->
    container = event.dropped_container
    $items    = $(container.items)
    $parent   = container.parentContainer and $(container.parentContainer.items)
    $prev     = $(container.prevItem)
    console.info event
    console.info 'item first:', $items.first().attr('model_id')
    if $parent
      console.info 'parent first:', $parent.first().attr('model_id')
    else
      console.info 'no parent'
    console.info 'prev item: ', $prev.attr('model_id')
    console.info 'prev level = items level:', @is_same_level($prev, $items)
    console.info 'dragged item: ', $(event.currentTarget).attr('model_id')

  # ###
  # ### Path Itemables 'is_used'.
  # ###

  set_path_path_item_itemables_is_used: (path, value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      path.get(ns.to_p 'path_items').then (path_items) =>
        @set_path_items_itemables_is_used(path_items, value).then =>
          resolve()
      , (error) => reject(error)

  set_path_items_itemables_is_used: (path_items, value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve()  if ember.isBlank(path_items)
      itemable_promises = path_items.map (path_item) => @set_path_itemable_is_used(path_item, value)
      ember.RSVP.Promise.all(itemable_promises).then =>
        resolve()
      , (error) => reject(error)

  set_path_itemable_is_used: (path_item, value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      path_item.get('path_itemable').then (itemable) =>
        return unless itemable
        return unless typeof(itemable.set_is_used) == 'function'
        itemable.set_is_used(value)
        resolve()
      , => reject()

  toString: -> 'DiagnosticPath::PathManager'