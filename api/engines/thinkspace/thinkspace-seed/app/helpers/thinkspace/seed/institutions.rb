class Thinkspace::Seed::Institutions < Thinkspace::Seed::BaseHelper

  def config_keys; [:institutions]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    array = [config[:institutions]].flatten.compact
    return if array.blank?
    array.each do |hash|
      title = hash[:title]
      config_error "Space institution title #{title.inspect} is blank.", config if title.blank?
      find_institution(hash.merge(find_or_create: true))
    end
  end

end
