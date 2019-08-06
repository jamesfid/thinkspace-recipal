import ember from 'ember'

# Eventually this will need checks for completed states, etc.
# => Colors will need to be swapped based on phase type, too.
export default ember.Handlebars.makeBoundHelper (current_state, title, options) ->
  unless options
    options = title
    title   = null
  tag_title = (title and "title='#{title}'") or ''
  if current_state
    "<div class='tsi tsi-small tsi-phase-#{current_state}' #{tag_title}></div>".htmlSafe()
  else
    "<div class='tsi tsi-small tsi-phase-unlocked #{tag_title}></div>".htmlSafe()
