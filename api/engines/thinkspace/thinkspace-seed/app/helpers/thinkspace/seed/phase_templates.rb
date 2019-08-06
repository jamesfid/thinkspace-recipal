class Thinkspace::Seed::PhaseTemplates < Thinkspace::Seed::BaseHelper

  def config_keys; [:phase_templates]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  def add_phase_components; add_phase_template_components; end

  private

  def process_config
    array = [config[:phase_templates]].flatten.compact
    return if array.blank?
    array.each do |hash|
      template = hash[:template]
      seed_config_error "Phase template does not have a template value [template: #{hash.inspect}].", config  if template.blank?
      template = template.gsub '#{casespace_phase_header}', casespace_phase_header
      template = template.gsub '#{casespace_phase_submit}', casespace_phase_submit
      create_model(:casespace, :phase_template, hash.merge(template: template))
    end
  end

  def casespace_phase_header
    html = <<-TEND
      <row><column><component section='header' title='casespace-phase-header'/></column></row>
    TEND
    html
  end

  def casespace_phase_submit
    html = <<-TEND
      <row><column><component section='submit' title='casespace-phase-submit'/></column></row>
    TEND
    html
  end

end
