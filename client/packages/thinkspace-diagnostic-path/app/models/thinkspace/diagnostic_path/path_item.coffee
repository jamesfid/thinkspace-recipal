import ember      from 'ember'
import ta         from 'totem/ds/associations'
import data_mixin from 'totem/mixins/data'


export default ta.Model.extend data_mixin, ta.add(
    ta.belongs_to  'path', reads: {}
    ta.polymorphic 'path_itemable'
    ta.has_many    'path_items',
      inverse: ta.to_p('path_item:parent')
      reads: [
        {name: 'path_items', sort: 'position:asc' }
        {name: 'unscoped_path_items', sort: 'position:asc'}  # filtering is done at the path's path items (e.g. top levle), not here
      ]
    ta.belongs_to 'path_item:parent',
      type:    ta.to_p('path_item')
      inverse: ta.to_p('path_items')
  ), 

  position:           ta.attr('number')
  description:        ta.attr('string')
  path_id:            ta.attr('number')
  parent_id:          ta.attr('number')
  path_itemable_id:   ta.attr('number')
  path_itemable_type: ta.attr('string')
  ownerable_id:       ta.attr('number')  # used in filter
  ownerable_type:     ta.attr('string')  # used in filter
  category:           ta.attr()

  # ### Totem Data
  totem_data_config: ability: true

  instructions: "Double-click to edit the observation"

  has_children:      ember.computed.gt ta.to_prop('path_items', 'length'), 0
  mechanism_icon:    ember.computed -> '<i class="fa fa-circle-o mechanism" title="Mechanism"></i>'.htmlSafe()
  is_mechanism:      ember.computed 'path_itemable_id', 'category', ->
    !ember.isPresent(@get('path_itemable_id')) and !ember.isPresent(@get('category'))
  has_path_itemable: ember.computed.notEmpty 'path_itemable_id'
  itemable:          ember.computed 'path_itemable.value', 'description', 'position', ->
    ta.PromiseObject.create
      promise: @get('path_itemable').then (itemable) =>
        if itemable
          value = @get_path_itemable_value(itemable)
        else
          value = @get_path_item_value()
        value: (value or '').htmlSafe()


  category_icon: ember.computed 'path_itemable.category_icon', 'category', ->
    has_path_itemable = @get 'has_path_itemable'
    if has_path_itemable
      @get('path_itemable.category_icon')
    else
      category = @get 'category'
      if ember.isPresent(category) then @get('category_json_icon') else @get('mechanism_icon')

  category_id:   ember.computed -> (@get('category.name') or '').toLowerCase()
  category_json_icon: ember.computed ->
    switch @get('category_id')
      when 'd'
        console.log @
        icon = '<i class="fa fa-flask data" title="Data"></i>'
      when 'h'
        icon = '<i class="im im-book history" title="History"></i>'
      when 'm'
        icon = '<i class="fa fa-circle-o mechanism" title="Mechanism"></i>'
      else
        icon = '<i class="fa fa-square unknown" title="Unknown"></i>'
    icon.htmlSafe()

  get_path_itemable_value: (itemable) -> itemable.get('value')
  # get_path_itemable_value: (itemable) ->
  #   testing_prefix = "(#{@get('position')}): " +  @get('id') + " : i" + itemable.get('id') + ' : '
  #   testing_prefix + itemable.get('value')

  get_path_item_value: -> @get('description') or @get('instructions')
  # get_path_item_value: ->
  #   testing_prefix = "(#{@get('position')}): >" +  @get('id') + " : "
  #   testing_prefix + (@get('description') or @get('instructions'))

  didLoad: -> 
    parent_id = @get('parent_id')
    @get(ta.to_p 'path').then (path) =>
      path_items = path.get(ta.to_p 'path_items')
      path_items.then (path_items) =>
        path_items.pushObject(@) unless path_items.contains(@)
        if ember.isPresent(parent_id)
          @store.find(ta.to_p('path_item'), parent_id).then (parent) =>
            parent.get(ta.to_p('path_items')).then (path_items) =>
              path_items.pushObject(@) unless path_items.contains(@)

  didUpdate: -> @didLoad()