class Thinkspace::Seed::SpaceUsers < Thinkspace::Seed::BaseHelper

  def config_keys; [:space_users]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    array = [config[:space_users]].flatten.compact
    return if array.blank?
    array.each do |hash|
      spaces = [hash[:spaces]].flatten.compact
      next  if spaces.blank?
      users = [hash[:users]].flatten.compact
      next  if users.blank?
      spaces.each do |title|
        space = find_space(title: title)
        config_error "Space users space #{title.inspect} not found [space_users: #{hash.inspect}].", config  if space.blank?
        users.each do |user_hash|
          roles  = [user_hash[:role] || :read].flatten.compact
          roles.each do |role|
            user = find_user(user_hash.except(:role).merge(find_or_create: true))
            next if user.superuser?  # do not add a space user record for a superuser
            find_space_user(space: space, user: user, role: role, find_or_create: true)
          end
        end
      end
    end
  end

end
