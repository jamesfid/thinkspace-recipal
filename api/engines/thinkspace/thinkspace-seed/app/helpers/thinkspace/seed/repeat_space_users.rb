class Thinkspace::Seed::RepeatSpaceUsers < Thinkspace::Seed::BaseHelper

  def config_keys; [:repeat_space_users]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    array = [config[:repeat_space_users]].flatten.compact
    return if array.blank?
    array.each do |hash|
      repeat       = hash[:repeat] || 1
      start_number = hash[:start_number] || 1
      first_name   = hash[:first_name] || 'Jane'
      last_name    = hash[:last_name]  || 'Doe'
      zero_fill    = hash[:zero_fill] == false ? 1 : (repeat + start_number).to_s.length
      role         = hash[:role]
      spaces       = [hash[:spaces]].flatten.compact
      spaces.each do |title|
        space = find_space(title: title)
        config_error "Space users space #{title.inspect} not found [space_users: #{hash.inspect}].", config  if space.blank?
        repeat.times do
          id         = start_number.to_s.rjust(zero_fill, '0')
          user_first = "#{first_name}.#{id}"
          user_last  = "#{last_name}.#{id}"
          email      = "#{first_name.downcase}.#{last_name.downcase}.#{id}@sixthedge.com"
          user       = find_user(first_name: user_first, last_name: user_last, email: email, find_or_create: true)
          find_space_user(hash.merge(space: space, user: user, role: role, find_or_create: true))
          start_number += 1
        end
      end
    end
  end

end
