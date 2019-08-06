export default {

  # Namespace keys to resolve the full path for a key in the 'type_to_namespace'.
  # The keys values can be any value that matches a 'type_to_namespace' key's value
  # (or a unique key for using just the namespace).
  #
  # If want to use a 'namespaces' key in a 'ns.to_' function and resolve to the namespace path,
  # (e.g. without adding the type) it cannot match a key in 'type_to_namespace'.
  #   e.g. no 'casespace' key in 'type_to_namespace':     to_p('casespace') -> 'thinkspace/casespace'
  #   e.g. casespace: 'casespace' in 'type_to_namespace': to_p('casespace') -> 'thinkspace/casespace/casespace'
  namespaces:
    authorization:          'thinkspace/authorization'
    toolbar:                'thinkspace/casespace/toolbar'
    sidepocket:             'thinkspace/casespace/sidepocket'
    crumbs:                 'thinkspace/casespace/toolbar/crumbs'
    dock:                   'thinkspace/dock'
    common:                 'thinkspace/common'
    casespace:              'thinkspace/casespace'
    artifact:               'thinkspace/artifact'
    diagnostic_path:        'thinkspace/diagnostic_path'
    diagnostic_path_viewer: 'thinkspace/diagnostic_path_viewer'
    html:                   'thinkspace/html'
    input_element:          'thinkspace/input_element'
    lab:                    'thinkspace/lab'
    markup:                 'thinkspace/markup'
    observation_list:       'thinkspace/observation_list'
    resource:               'thinkspace/resource'
    team:                   'thinkspace/team'
    peer_assessment:        'thinkspace/peer_assessment'
    weather_forecaster:     'thinkspace/weather_forecaster'
    simulation:             'thinkspace/simulation'
    builder:                'thinkspace/builder'

  # Convert commonly used key values to a full namespace path.
  # When using a 'ns.to_' function, the type key will be converted to a namespaced path.
  #
  # The 'type' must be the first argument and match either a key in 'type_to_namespace'
  # or the 'namespaces'.  Any remaining arguments are added to the path.
  # The 'ns.to_' functions return the same value only with a different seperator.
  #   e.g. ns.to_p('team', 'arg1', 'arg2') -> 'thinkspace/team/team/arg1/arg2'
  #   e.g. ns.to_r('team', 'arg1', 'arg2') -> 'thinkspace/team/team.arg1.arg2'
  #
  # Keys must be unique and can be made unique by using 'unique-prefix:duplicate-type'.
  #   e.g. 'phase_template_section:parent': 'casespace' -> thinkspace/casespace/parent
  #   e.g. 'user:parent': 'common'                      -> thinkspace/common/parent
  #
  # CAUTION: The 'key' must be the singular value for lookup, but the original type value
  #          (whether singular or plural) is added to the path.
  type_to_namespace:

    # thinkspace/authorization
    ability:  'authorization'
    metadata: 'authorization'

    # thinkspace/common
    user:            'common'
    owner:           'common'
    space:           'common'
    space_type:      'common'
    space_user:      'common'
    configuration:   'common'
    configurable:    'common'
    component:       'common'
    invitation:      'common'
    password_reset:  'common'
    discipline:      'common'
    agreement:       'common'
    key:             'common'


    # thinkspace/markup
    comment:         'markup'
    library:         'markup'
    library_comment: 'markup'
    discussion:      'markup'

    # thinkspace/resource
    resourceable: 'resource'
    file:         'resource'
    link:         'resource'
    tag:          'resource'

    # thinkspace/team
    team:          'team'
    team_category: 'team'
    team_user:     'team'
    team_teamable: 'team'
    team_viewer:   'team'
    team_set:      'team'

    # thinkspace/casespace
    assignment:      'casespace'
    phase:           'casespace'
    phase_template:  'casespace'
    phase_component: 'casespace'
    phase_state:     'casespace'
    phase_score:     'casespace'

    gradebook:             'casespace'
    peer_review:           'casespace'
    case_manager:          'casespace'
    case_manager_template: 'casespace'

    content:       'html'
    path:          'diagnostic_path'
    path_item:     'diagnostic_path'
    path_itemable: 'diagnostic_path'
    viewer:        'diagnostic_path_viewer'
    bucket:        'artifact'

    'artifact:file':    'artifact'
    'path_item:parent': 'diagnostic_path'

    'comment:parent': 'markup'

    'lab:chart':       'lab'
    'lab:category':    'lab'
    'lab:result':      'lab'
    'lab:observation': 'lab'

    'wf:assessment':      'weather_forecaster'
    'wf:assessment_item': 'weather_forecaster'
    'wf:forecast':        'weather_forecaster'
    'wf:forecast_day':    'weather_forecaster'
    'wf:item':            'weather_forecaster'
    'wf:response':        'weather_forecaster'
    'wf:response_score':  'weather_forecaster'
    'wf:station':         'weather_forecaster'

    list:                     'observation_list'
    observation:              'observation_list'
    observation_note:         'observation_list'
    'observation_list:group': 'observation_list'

    element:          'input_element'
    response:         'input_element'

    'tbl:assessment': 'peer_assessment'
    'tbl:review':     'peer_assessment'
    'tbl:review_set': 'peer_assessment'
    'tbl:team_set':   'peer_assessment'
    'tbl:overview':   'peer_assessment'

    'sim:simulation': 'simulation'

    'builder:template': 'builder'

}
