import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # Properties
  team_sets:          null
  current_team_sets:  ember.computed.reads 'team_manager.current_team_sets'

  # Components
  c_space_header:      ns.to_p 'space',        'header'
  c_file_upload:       ns.to_p 'common',       'file-upload'
  c_file_upload_modal: ns.to_p 'case_manager', 'team_sets', 'import_modal'

  # Routes
  r_team_sets_show: ns.to_r 'case_manager', 'team_sets', 'show'
  r_team_sets_new:  ns.to_r 'case_manager', 'team_sets', 'new'

  # Services
  team_manager: ember.inject.service()

  # Import
  import_form_action:  ember.computed 'model', -> "/api/thinkspace/common/spaces/#{@get('model.id')}/import_teams"
  import_model_path:   'thinkspace/common/space'
  import_params:       ember.computed 'model', -> {id: @get('model.id')}
  import_btn_text:     'Import Team Roster'
  import_loading_text: 'Importing team roster..'
