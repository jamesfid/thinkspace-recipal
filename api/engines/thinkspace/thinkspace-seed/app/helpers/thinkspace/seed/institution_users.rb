class Thinkspace::Seed::InstitutionUsers < Thinkspace::Seed::BaseHelper

  def config_keys; [:institution_users]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    array = [config[:institution_users]].flatten.compact
    return if array.blank?
    array.each do |hash|
      institutions = [hash[:institutions]].flatten.compact
      next if institutions.blank?
      users = [hash[:users]].flatten.compact
      next  if users.blank?
      state = hash[:state]
      role  = hash[:role]
      institutions.each do |title|
        institution = find_institution(title: title)
        seed_config_error "Institution users institution #{title.inspect} not found [institution_users: #{hash.inspect}].", config  if institution.blank?
        users.each do |user_hash|
          user = find_user(user_hash.except(:role).merge(find_or_create: true))
          next if user.superuser?  # do not add a space user record for a superuser
          find_institution_user(institution: institution, user: user, role: role, state: state, find_or_create: true)
        end
      end
    end
  end

end
