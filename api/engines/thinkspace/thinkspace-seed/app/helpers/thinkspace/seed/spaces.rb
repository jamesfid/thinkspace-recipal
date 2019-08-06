class Thinkspace::Seed::Spaces < Thinkspace::Seed::BaseHelper

  def config_keys; [:spaces]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    array = [config[:spaces]].flatten.compact
    return if array.blank?
    institution = nil
    array.each do |hash|
      type_title = hash[:space_type] || 'Casespace'
      space_type = find_space_type(title: type_title)
      config_error "Space type title #{type_title.inspect} not found.", config if space_type.blank?
      title = hash[:institution]
      if title.present?
        institution = find_institution(title: title)
        config_error "Space institution title #{title.inspect} not found.", config if institution.blank?
      end
      # TODO: Is an instituion required?
      # config_error "Space institution has not been specified and is not inheritable [space: #{hash.inspect}].", config  if institution.blank?
      space = find_space(hash.merge(institution: institution, find_or_create: true))
      add_config_model(space)
      find_space_space_type(space: space, space_type: space_type, find_or_create: true)
      if hash[:is_sandbox] == true
        space.sandbox_space_id = space.id
        save_model(space)
      end
    end
  end

end
