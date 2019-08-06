class Thinkspace::Seed::Assignments < Thinkspace::Seed::BaseHelper

  def config_keys; [:assignments]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    array = [config[:assignments]].flatten.compact
    return if array.blank?
    space = nil
    array.each do |hash|
      title = hash[:space]
      if title.present?
        space = find_space(title: title)
        config_error "Assignment space #{title.inspect} not found [assignment: #{hash.inspect}].", config  if space.blank?
      end
      config_error "Space assignment has not been specified and is not inheritable [assignment: #{hash.inspect}].", config  if space.blank?
      config_error "Assigment title is blank: #{hash.inspect}].", config  if hash[:title].blank?
      assignment = find_assignment(hash.merge(space: space, find_or_create: true))
      add_config_model(assignment)
    end
  end

end
