module Thinkspace; module Migrate; module ToComponents; module Inspect
  class PhaseTemplates < Totem::DbMigrate::BaseHelper
    require 'pp'

    def process
      collect = Array.new
      old_phase_class.all.each do |old_phase|
        tools = get_old_phase_tools_and_helpers(old_phase)
        lines = Array.new
        tools.each do |hash|
          hash.each do |section_name, section_tools|
            lines.push " section: #{section_name}  tools: #{section_tools.inspect.ljust(20)}"
          end
        end
        line = lines.join(' ').ljust(100)
        line += "submit: #{old_phase_has_submit?(old_phase).inspect.ljust(6)}"
        line += " phase_template: #{old_phase.phase_template_id}"
        collect.push(line)
      end
      total_count = 0
      puts "\n"
      puts "Phase Templates Required:"
      collect.uniq.sort.each_with_index do |line, index|
        count        = collect.count(line)
        total_count += count
        puts "#{(index+1).to_s.rjust(2)}. count: #{count.to_s.rjust(5)} ->" + line
      end
      puts "           -----"
      puts "total:     #{total_count.to_s.rjust(5)}"
    end

    def get_old_phase_tools_and_helpers(old_phase)
      phase_tools    = old_phase_tool_class.where(phase_id: old_phase.id)
      phase_tool_ids = phase_tools.map(&:id)
      phase_helpers  = old_phase_tool_helper_class.where(phase_tool_id: phase_tool_ids)
      all_sections   = Hash.new

      phase_tools.each do |record|
        section = old_phase_template_section_class.find_by(id: record.phase_template_section_id)
        puts "ERROR.....Missing tool section #{record.inspect}"  if section.blank?
        section_name  = get_section_name(section)
        section_order = section.template_section_order
        record_order  = record.template_section_order

        order_sections  = (all_sections[section_order]  ||= Hash.new)
        name_sections   = (order_sections[section_name] ||= Hash.new)
        puts "ERROR.....duplicate tool #{record.inspect}"  if name_sections.has_key?(record_order)
        name_sections[record_order] = record.toolable_type.demodulize.downcase.to_sym
      end

      phase_helpers.each do |record|
        section = old_phase_template_section_class.find_by(id: record.phase_template_section_id)
        puts "ERROR.....Missing helper section #{record.inspect}"  if section.blank?
        section_name  = get_section_name(section)
        section_order = section.template_section_order
        record_order  = record.template_section_order

        order_sections  = (all_sections[section_order]  ||= Hash.new)
        name_sections   = (order_sections[section_name] ||= Hash.new)
        puts "ERROR.....duplicate helper #{record.inspect}"  if name_sections.has_key?(record_order)
        name_sections[record_order] = record.helperable_type.demodulize.downcase.to_sym
      end

      ordered_sections = Array.new
      all_sections.keys.sort.each do |key|
        section_hash = all_sections[key]
        section_hash.each do |name, section_order_hash|
          tools = Array.new
          section_order_hash.keys.sort.each do |tool_order|
            tools.push section_order_hash[tool_order]
          end
          ordered_sections.push({name => tools})
        end
      end

      ordered_sections
    end

    def get_section_name(section); "#{section.id} #{section.section_name}"; end

    def old_phase_has_submit?(old_phase)
      configuration = get_old_configuration(old_phase)
      return true if configuration.blank?  # default to true
      configuration = configuration.attributes.with_indifferent_access
      settings      = configuration[:settings] || Hash.new
      submit        = settings[:submit] || Hash.new
      !(submit[:visible] == false)
    end

    def old_phase_tool_class;               get_old_model_class('thinkspace/wips/casespace/phase_tool'); end
    def old_phase_tool_helper_class;        get_old_model_class('thinkspace/wips/casespace/phase_tool_helper'); end
    def old_phase_tool_helper_embed_class;  get_old_model_class('thinkspace/wips/casespace/phase_tool_helper_embed'); end
    def old_phase_template_section_class;   get_old_model_class('thinkspace/wips/casespace/phase_template_section'); end

    def get_old_configuration(old_record)
      old_configuration_class.find_by(configurable_id: old_record.id, configurable_type: polymorphic_type(old_record))
    end

    def old_configuration_class;       get_old_model_class('thinkspace/common/configuration'); end
    def old_phase_class;               get_old_model_class('thinkspace/wips/casespace/phase'); end
    def old_phase_template_class;      get_old_model_class('thinkspace/wips/casespace/phase_template'); end

  end

end; end; end; end
