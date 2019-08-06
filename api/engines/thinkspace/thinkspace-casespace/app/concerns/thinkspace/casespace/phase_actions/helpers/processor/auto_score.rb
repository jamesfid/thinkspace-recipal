module Thinkspace; module Casespace; module PhaseActions; module Helpers; module Processor; module AutoScore

  def auto_score(ownerable, phase=current_phase)
    phase_score = get_phase_score(ownerable, phase)
    klass       = get_score_class
    debug "Score class #{klass.name.inspect}", ownerable  if debug?
    score = klass.new(self, ownerable, get_action_auto_score).process
    debug "Phase score=#{score.inspect}", ownerable if debug?
    phase_score.score = score
    raise SaveError, "Error saving phase score for phase [id: #{phase.id}] ownerable [id: #{ownerable.id} type: #{ownerable.class.name}]." unless phase_score.save
  end

  private

  def get_score_class
    return score_class if score_class.present?
    config = get_action_auto_score || Hash.new
    return if config == false
    score_with = config.is_a?(Hash) ? (config[:score_with] || :default) : :default
    class_name = score_with.to_s.match('/') ? score_with.to_s.camelize : self.class.name.deconstantize + "::Score::#{score_with.to_s.camelize}"
    klass = class_name.safe_constantize
    raise InvalidClassError, "Score class name #{class_name.inspect} cannot be constantized." if klass.blank?
    klass
  end

  class InvalidClassError < StandardError; end;
  class SaveError         < StandardError; end;

end; end; end; end; end; end
