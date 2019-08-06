import ember from 'ember'
import util  from 'totem/util'

default_icon = ['fa', 'fa-file-o']

icon_map = 
  html:  ['fa', 'fa-code']
  text:  ['fa', 'fa-file-text-o']
  image: ['fa', 'fa-camera']
  pdf:   ['fa', 'fa-file-pdf-o']

get_icon_html = (classes) -> new ember.Handlebars.SafeString("<i class='#{classes.join(' ')}'></i>")

export default ember.Handlebars.makeBoundHelper (content_type, classes, options) ->
  # If classes is NOT a string, it is the options (e.g. no additional classes).
  if typeof classes == 'string'
    classes = classes.split(' ')
  else
    options = classes
    classes = []

  if content_type
    for icon, icon_classes of icon_map
      if util.ends_with(content_type, icon) or util.starts_with(content_type, icon)
        classes.push(icon_class) for icon_class in icon_classes
        break
    if ember.isBlank(classes)
      # Return default file icon if content_type does not match an icon.
      get_icon_html(default_icon)
    else
      get_icon_html(classes.uniq())
  else
    # Return default file icon if no matching content_type.
    get_icon_html(default_icon)
