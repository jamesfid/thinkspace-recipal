class Thinkspace::Seed::Teams < Thinkspace::Seed::BaseHelper

  def config_keys; [:teams, :team_phases]; end

  def process(*args)
    super
    return unless process?
    process_config_teams
    process_config_team_phases  # allow 'team_phases' to be defined as a root key (e.g. using the existing space teams and don't have a 'teams:' key)
  end

  private

  def process_config_teams
    array = [config[:teams]].flatten.compact
    return if array.blank?
    array.each do |hash|
      add_team_sets(hash)
      add_team_set_teams(hash)
      add_teams_for_assignment(hash)
      add_teams_for_phase(hash)
      # add_team_viewers(hash)
    end
  end

  def process_config_team_phases
    array = [config[:team_phases]].flatten.compact
    return if array.blank?
    add_teams_for_phase({phase: array})
  end

  def add_team_sets(teams_hash)
    team_sets_hash = teams_hash[:team_sets]
    return if team_sets_hash.blank?
    space = nil
    user  = nil
    team_sets_hash.each_with_index do |hash, index|
      space = get_space(space, hash)
      config_error "Phase team set space has not been specified and is not inheritable. #{hash.inspect}", config  if space.blank?
      user = get_user(user, hash)
      config_error "Phase team set user has not been specified and is not inheritable. #{hash.inspect}", config  if user.blank?
      title   = hash[:title] || "generated_team_set_#{index + 1}"
      options = {
        space:          space,
        user:           user,
        title:          title,
        description:    hash[:description] || "description for #{title}",
        settings:       hash[:settings]    || Hash.new,
        state:          hash[:state],
        default:        hash[:default],
        find_or_create: true,
      }
      find_team_set(options)
    end
  end

  def add_team_set_teams(teams_hash)
    team_set_teams_hash = teams_hash[:team_set_teams]
    return if team_set_teams_hash.blank?
    space    = nil
    team_set = nil
    team_set_teams_hash.each_with_index do |hash, index|
      space = get_space(space, hash)
      seed_config_error "Team set teams space has not been specified and is not inheritable. #{hash.inspect}"  if space.blank?
      team_set = get_team_set(space, team_set, hash)
      seed_config_error "Team set has not been specified and is not inheritable. #{hash.inspect}"  if team_set.blank?
      title   = hash[:title] || "generated_team_set_#{index + 1}"
      options = {
        title:          title,
        description:    hash[:description] || "description for #{title}",
        color:          hash[:color],
        state:          hash[:state],
        authable:       space,
        team_set:       team_set,
        find_or_create: true,
      }
      team  = find_team(options)
      users = [hash[:users]].flatten.compact
      users.each do |username|
        user = find_user_by_name(username)
        seed_config_error "Team set user #{username.inspect} not found. #{hash.inspect}"  if user.blank?
        create_model(:team, :team_user, user: user, team: team)
      end
    end
  end

  def add_teams_for_assignment(teams_hash)
    array = [teams_hash[:assignment]].flatten.compact
    return if array.blank?
    space = nil
    array.each_with_index do |hash, index|
      space = get_space(space, hash)
      config_error "Assignment team space has not been specified and is not inheritable. #{hash.inspect}", config  if space.blank?
      title = hash[:title]
      config_error "Assignment title is blank for assignment team. #{hash.inspect}.", config  if title.blank?
      assignment = find_assignment(space: space, title:title)
      config_error "Assignment #{title.inspect} for assignment team not found. #{hash.inspect}", config  if assignment.blank?
      add_team_set_teamables(space, assignment, hash)
    end
  end

  def add_teams_for_phase(teams_hash)
    array = [teams_hash[:phase]].flatten.compact
    return if array.blank?
    space      = nil
    assignment = nil
    array.each_with_index do |hash, index|
      space = get_space(space, hash)
      config_error "Phase team space has not been specified and is not inheritable. #{hash.inspect}", config  if space.blank?
      assignment = get_assignment(space, assignment, hash)
      config_error "Phase team assignment has not been specified and is not inheritable. #{hash.inspect}", config  if assignment.blank?
      title = hash[:title]
      config_error "Phase title is blank for phase team. #{hash.inspect}.", config  if title.blank?
      phase = find_phase(assignment: assignment, title: title)
      config_error "Phase #{title.inspect} for phase team not found. #{hash.inspect}", config  if phase.blank?

      if (category = hash[:team_category]).present?
        team_category = find_team_category(category: category)
        config_error "Phase team category #{category.inspect} not found [phase: #{hash.inspect}].", config  if team_category.blank?
        if phase.team_category_id.present? && phase.team_category_id != team_category.id
          config_warn  "Phase #{title.inspect} team_category_id is being changed from #{phase.team_category_id.inspect} to #{team_category.id.inspect}: #{hash.inspect}].", config
        end
        if phase.team_category_id != team_category.id
          phase.team_category_id = team_category.id
          save_model(phase)
        end
      end

      config_error "Phase #{title.inspect} has teams but the team_category_id is blank.  Did you add a 'team_category:' key? #{hash.inspect}", config  if phase.team_category_id.blank?
      add_team_set_teamables(space, phase, hash)
    end
  end

  def add_team_set_teamables(space, teamable, hash)
    team_sets = [hash[:team_sets]].flatten.compact
    team_sets.each do |title|
      team_set = find_team_set(space: space, title: title)
      config_error "Team set #{title.inspect} for space #{space.title.inspect} not found.", config if team_set.blank?
      find_team_set_teamable(team_set: team_set, teamable: teamable, find_or_create: true)
    end
  end

  def get_space(space, hash)
    title = hash[:space]
    return space if title.blank?
    space = find_space(title: title)
    config_error "Phase team set space #{title.inspect} not found. #{hash.inspect}", config  if space.blank?
    space
  end

  def get_team_set(space, team_set, hash)
    title = hash[:team_set]
    return team_set if title.blank?
    team_set = find_team_set(title: title, space: space)
    config_error "Phase team set space #{title.inspect} not found. #{hash.inspect}", config  if team_set.blank?
    team_set
  end

  def get_assignment(space, assignment, hash)
    title = hash[:assignment]
    return assignment if title.blank?
    assignment = find_assignment(title: title, space: space)
    config_error "Phase team assignment #{title.inspect} not found. #{hash.inspect}", config  if assignment.blank?
    assignment
  end

  def get_user(user, hash)
    username = hash[:user]
    return user if username.blank?
    user = find_user_by_name(username)
    config_error "Phase team user #{username.inspect} not found. #{hash.inspect}", config  if user.blank?
    user
  end

  # # ###
  # # ### Team Viewers.
  # # ###
  #
  # def casespace_seed_config_add_team_viewers(teams_hash)
  #   viewers = teams_hash[:viewers]
  #   return if viewers.blank?
  #   space      = nil
  #   assignment = nil
  #   viewers.each do |hash|
  #     title = hash[:space]
  #     if title.present?
  #       space = find_casespace_space(title: title)
  #       seed_config_error "Team viewers space title #{title.inspect} not found." if space.blank?
  #     end
  #     seed_config_error "Assignment team space has not been specified and is not inheritable [#{hash.inspect}]."  if space.blank?
  #     titles = [hash[:team_sets]].flatten.compact
  #     seed_config_error "Viewer team set titles are blank [#{hash.inspect}]."  if titles.blank?
  #     team_set_ids = @seed.model_class(:team, :team_set).where(space_id: space.id, title: titles).map(&:id)
  #     seed_config_error "Some viewer team set titles not found [#{hash.inspect}]."  unless titles.length == team_set_ids.length
  #
  #     team_titles = [hash[:teams]].flatten.compact
  #     teams       = Array.new
  #     team_titles.each do |title|
  #       teams.push casespace_seed_config_get_team_sets_team(team_set_ids, title, hash)
  #     end
  #
  #     usernames = [hash[:users]].flatten.compact
  #     users     = get_common_users_from_first_names(usernames)
  #
  #     view       = [hash[:view]].flatten.compact
  #     view_teams = Array.new
  #     view.each do |title|
  #       view_teams.push casespace_seed_config_get_team_sets_team(team_set_ids, title, hash)
  #     end
  #
  #     view_teams.each do |team|
  #       casespace_seed_config_add_team_team_viewers(team, teams)
  #       casespace_seed_config_add_team_team_viewers(team, users)
  #     end
  #   end
  # end
  #
  # def casespace_seed_config_add_team_team_viewers(team, viewerables)
  #   return if viewerables.blank?
  #   viewerables.each do |viewerable|
  #     create_team_team_viewer(team: team, viewerable: viewerable)
  #   end
  # end
  #
  # def casespace_seed_config_get_team_sets_team(team_set_ids, title, hash)
  #   klass   = @seed.model_class(:team, :team)
  #   options = {team_set_id: team_set_ids, title: title}
  #   count   = klass.where(options).count
  #   seed_config_error "Viewer team title #{title.inspect} in more than one team set [#{hash.inspect}]."  if count > 1
  #   team = klass.find_by(options)
  #   seed_config_error "Viewer team title #{title.inspect} not found [#{hash.inspect}]."  if team.blank?
  #   team
  # end

end
