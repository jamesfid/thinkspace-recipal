import ember       from 'ember'
import tc          from 'totem/cache'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  get_item_itemable: (item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      id   = item.itemable_id
      type = item.itemable_type
      return resolve(null) if ember.isBlank(id) or ember.isBlank(type)
      type = totem_scope.rails_polymorphic_type_to_path(type)
      resolve tc.find_record(type, id)

  set_itemable_is_used: (item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_item_itemable(item).then (itemable) =>
        return resolve() if ember.isBlank(itemable)
        itemable.set_is_used()  if @is_function(itemable.set_is_used)
        resolve()

  clear_itemable_is_used_unless_used_by_another_item: (items) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve()  if ember.isBlank(items)
      items          = ember.makeArray(items)
      clear_promises = items.map (item) =>
        if @is_itemable_used_by_another_item(item)
          ember.RSVP.resolve()  # just add a resolved promise to the array since used by another item
        else
          @clear_itemable_is_used(item)
      ember.RSVP.all(clear_promises).then => resolve()

  is_itemable_used_by_another_item: (item) ->
    id   = item.itemable_id
    type = item.itemable_type
    return true if ember.isBlank(id) or ember.isBlank(type)  # not associated with an itemable
    type = totem_scope.rails_polymorphic_type_to_path(type)
    @value_items.find (i) => (i.itemable_id == id and totem_scope.rails_polymorphic_type_to_path(i.itemable_type) == type)

  clear_itemable_is_used: (item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_item_itemable(item).then (itemable) =>
        return resolve() if ember.isBlank(itemable)
        itemable.set_is_used(false)  if @is_function(itemable.set_is_used)
        resolve()

  get_item_itemable_icon: (item) ->
    return null if ember.isBlank(item.icon)
    @convert_itemable_icon_to_html(item.icon).htmlSafe()

  convert_itemable_icon_to_html: (icon_id) ->
    switch icon_id.toLowerCase()
      when 'html'         then '<i class="im im-book history" title="History"></i>'
      when 'lab'          then '<i class="fa fa-flask data" title="Data"></i>'
      when 'mechanism'    then '<i class="fa fa-circle-o mechanism" title="Mechanism"></i>'
      else '<i class="fa fa-square-o unknown" title="Unknown"></i>'
