export default {

  phase:         ownerable: true, authable: false
  phase_score:   ownerable: true, authable: true
  phase_state:   ownerable: true, authable: true
  content:       ownerable: true, authable: true
  list:          ownerable: true, authable: false
  response:      ownerable: true, authable: true
  observation:   ownerable: true, authable: true
  team_category: ownerable: true, authable: true
  path:          ownerable: true, authable: false
  bucket:        ownerable: true, authable: false
  comment:       ownerable: true, authable: false
  discussion:    ownerable: true, authable: false
  viewer:        ownerable: true, authable: false

  'lab:chart':       ownerable: true, authable: false
  'lab:observation': ownerable: true, authable: true
  'tbl:assessment':  ownerable: true, authable: true
  'tbl:review':      ownerable: true, authable: true
  'tbl:overview':    ownerable: true, authable: true
  'wf:assessment':   ownerable: true, authable: false
  'wf:forecast':     ownerable: true, authable: false
  'wf:response':     ownerable: true, authable: true
  'sim:simulation':  ownerable: true, authable: true

}
