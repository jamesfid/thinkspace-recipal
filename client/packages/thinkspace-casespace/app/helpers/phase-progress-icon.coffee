import ember from 'ember'

# Eventually this will need checks for completed states, etc.
# => Colors will need to be swapped based on phase type, too.
export default ember.Handlebars.makeBoundHelper (current_phase, each_phase, current_state, options) ->
  if current_phase == each_phase
    '<div class="tsi tsi-small tsi-phase-current"></div>'.htmlSafe()
  else
    "<div class='tsi tsi-small tsi-phase-#{current_state}'></div>".htmlSafe()
