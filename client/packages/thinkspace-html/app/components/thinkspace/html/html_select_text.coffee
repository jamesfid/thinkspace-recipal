import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-html/components/base'

export default base.extend

  mouseUp: (event) ->
    return if @totem_scope.get('is_view_only')
    sel_obj = window.getSelection()  # Not x-browser or database backed
    value   = sel_obj.toString()
    return unless value
    sel_obj.removeAllRanges()
    tvo      = @get 'tvo'
    action   = 'select-text'
    sections = tvo.attribute_value_array @get("attributes.#{action}")
    return if ember.isBlank(sections)
    for section in sections
      if tvo.section.has_action(section, action)
        tvo.section.send_action section, action, value
