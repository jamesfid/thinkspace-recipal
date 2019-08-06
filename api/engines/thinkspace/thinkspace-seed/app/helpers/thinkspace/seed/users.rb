class Thinkspace::Seed::Users < Thinkspace::Seed::BaseHelper

  def config_keys; [:users]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    array = [config[:users]].flatten.compact
    return if array.blank?
    array.each do |hash|
      user = find_user(hash.merge(find_or_create: true))
    end
  end

end
