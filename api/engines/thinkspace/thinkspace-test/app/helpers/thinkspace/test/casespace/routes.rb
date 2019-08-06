module Thinkspace::Test; module Casespace; module Routes
extend ActiveSupport::Concern

  module RouteConfigs

    def new_route_config_options(options=default_route_options); route_config_options_class.new(options); end

    def default_route_options
      {
        admin_match:           route_admin_matches,
        not_admin_match:       route_not_admin_matches,
        readers:               :read_1,
        updaters:              :update_1,
        owners:                :owner_1,
        unauthorized_readers:  :read_2,
        unauthorized_updaters: :update_2,
        unauthorized_owners:   :owner_2,
      }
    end


    def route_admin_matches
      [
        {controller: :assignments,      actions: [:roster, :view]},
        {controller: :peer_assessment,  actions: [:create, :view]},
        {controller: :contents,         actions: [:validate, :update]},
        :phase_states,
        :phase_scores,
      ]
    end

    def route_not_admin_matches
      [
        {controller: :spaces,      actions: [:create]},
        {controller: :users,       actions: [:create]},
        {controller: :invitations, actions: [:fetch_state]},
      ]
    end

  end # RouteConfigs

  class_methods do
    include RouteConfigs
  end

  included do
    include RouteConfigs
  end

end; end; end
