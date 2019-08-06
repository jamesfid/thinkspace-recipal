import ember from 'ember'

# In a template add the radio-button handlebars helper e.g.:
#   = radio-button value='myvalue1' checked=category  #=> the two radio buttons are 'grouped' since reference the same 'checked=' property 'category'
#   = radio-button value='myvalue2' checked=category
# Each radio-button is independent of other radio buttons.
# To group the radio buttons, reference the same 'checked=' property (assumes the values are unique).
# The 'value' can be either a string or reference a property (e.g. like checked).
# The radio-button label is not required, but can be any html.  To make the label clickable, wrap the radio-button in a label tag e.g.:
#   label
#     = radio-button value='myvalue1' checked=category
#     | My Value 1 Category
radio_button = ember.View.extend
  tagName:           'input'
  type:              'radio'
  attributeBindings: ['type', 'htmlChecked:checked', 'value', 'name']

  htmlChecked: (->
    return @get('value') == @get('checked')
  ).property('value', 'checked'),

  change: ->
    @set('checked', @get('value'))

export default ember.Handlebars.makeViewHelper(radio_button)
