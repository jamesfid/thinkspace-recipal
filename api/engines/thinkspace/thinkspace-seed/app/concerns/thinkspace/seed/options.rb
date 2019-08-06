module Thinkspace::Seed::Options

  PROCESS_OPTIONS = {
    order: [
      :users,
      :institutions,
      :institution_users,
      :spaces,
      :space_users,
      :repeat_space_users,
      :assignments,
      :phase_templates,
      :phases,
      :teams,
      :observation_lists, # do before :indented_lists as the :indented_lists auto-input may use observations to populated the list
      :indented_lists,
    ],
    find_model_to_model_id: [:institution, :user, :space, :space_type, :assignment, :phase, :team_set, :team],
    default_config: 'df/all'
  }

  def get_seed_options; PROCESS_OPTIONS; end

  def get_seed_options_model_to_model_id; get_seed_options[:find_model_to_model_id] || []; end

end
