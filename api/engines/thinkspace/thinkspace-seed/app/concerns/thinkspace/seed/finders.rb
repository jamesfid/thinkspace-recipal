module Thinkspace::Seed::Finders
  include Totem::Seed::FinderHelpers

  def find_user_by_name(name);          find_user(first_name: name); end
  def find_user(options);               find_model(:common, :user, options, [:first_name], domain: true); end
  def find_institution(options);        find_model(:common, :institution, options); end
  def find_institution_user(options);   find_model(:common, :institution_user, options, [:institution, :user]); end
  def find_space(options);              find_model(:common, :space, options); end
  def find_space_type(options);         find_model(:common, :space_type, options); end
  def find_space_space_type(options);   find_model(:common, :space_space_type, options, [:space, :space_type]); end
  def find_space_user(options);         find_model(:common, :space_user, options, [:space, :user]); end
  def find_assignment(options);         find_model(:casespace, :assignment, options, [:title, :space]); end
  def find_phase(options);              find_model(:casespace, :phase, options, [:title, :assignment]); end
  def find_phase_template(options);     find_model(:casespace, :phase_template, options); end
  def find_phase_component(options);    find_model(:casespace, :phase_component, options); end
  def find_team(options);               find_model(:team, :team, options, [:title, :authable, :team_set]); end
  def find_team_category(options);      find_model(:team, :team_category, options); end
  def find_team_set(options);           find_model(:team, :team_set, options, [:title, :space]); end
  def find_team_set_teamable(options);  find_model(:team, :team_set_teamable, options, [:team_set, :teamable]); end
  def find_common_component(options);   find_model(:common, :component, options); end

  def find_casespace_space_type;    find_space_type(title: 'Casespace'); end

  def find_phase_ownerables(phase, options={})
    phase.team_ownerable? ? find_phase_teams(phase, options) : find_phase_users(phase, options)
  end

  def find_phase_teams(phase, options={})
    teams      = [options[:teams]].flatten.compact
    assignment = @seed.get_association(phase, :casespace, :assignment)
    all_teams  = find_teams_for_teamables(phase, assignment)
    teams.blank? ? all_teams : all_teams.select {|t| teams.include?(t.title)}
  end

  def find_teams_for_teamables(*args)
    teams = Array.new
    [args].flatten.each do |teamable|
      ids = @seed.model_class(:team, :team_set_teamable).where(teamable: teamable).pluck(:team_set_id)
      teams.push @seed.model_class(:team, :team).where(team_set_id: ids)
    end
    [teams].flatten.uniq
  end

  def find_phase_users(phase, options={})
    space = phase.get_space()
    find_space_users(space, options)
  end

  def find_space_users(space, options={})
    roles       = options[:roles]
    users       = options[:users]
    space_users = @seed.get_association(space, :common, :space_users)
    space_users = space_users.where(role: roles)  if roles.present?
    if users.present?
      users    = [users].flatten.compact
      user_ids = users.map {|u| find_casespace_user(first_name: u)}.map(&:id)
      @seed.error "Space users for users #{users.inspect} not found."  if user_ids.blank?
      space_users = space_users.where(user_id: user_ids)
    end
    user_ids = space_users.pluck(:user_id)
    @seed.model_class(:common, :user).where(id: user_ids).order(:id)
  end

  # ### Override the totem method so can create a timetable.
  def create_model(ns, model_name, options)
    model = super  # create the model with defaulted model options
    create_timetable(model, options) if options[:create_timetable] == true
    model
  end

  def create_timetable(model, options)
    return if model.blank? || (options[:release_at].blank? && options[:due_at].blank?)
    ttmodel = @seed.new_model(:common, :timetable, options.merge(timeable: model))
    @seed.create_error(ttmodel)  unless ttmodel.save
    @models.add(config, ttmodel)
    ttmodel
  end

  def find_phase_component_for_phase(phase, ns, model_name)
    model = @seed.model_class(ns, model_name)
    @seed.get_association(phase, :casespace, :phase_components).where(componentable_type: model.name).first
  end

end
