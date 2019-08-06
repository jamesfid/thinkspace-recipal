class Thinkspace::Seed::HtmlSamples

  attr_reader :caller, :phase, :section_hash

  delegate :config_error, to: :caller

  def initialize(caller, seed, options)
    @caller       = caller
    @seed         = seed
    @phase        = options[:phase]
    @section_hash = options[:section_hash] || {}
    id            = (phase && phase.id) || 'no-id'
    @id           = "phase_#{id}"
    @tags         = {}
  end

  def html_methods(methods)
    content = section_title
    Array.wrap(methods).each do |method|
      config_error "HTML sample does not have method #{method.inspect}." unless self.respond_to?(method)
      content += self.send method
    end
    content
  end

  # ###
  # ### Html Methods.
  # ###

  def section_title
    title = section_hash[:title]
    title.blank? ? '' : "<h3>#{title}</h3>"
  end

  def inputs
    content = <<-TEND
      #{input}
      #{textarea}
      #{checkbox}
      #{radio}
    TEND
  end

  # ###
  # ### Individual Tags.
  # ###

  def input
    n       = tag_n(:input)
    name    = "input_#{@id}_n_#{n}"
    content = "<input name=\"#{name}\" type=\"text\"></input>"
    row_wrap content, "Input [#{name}]"
  end

  def checkbox
    n       = tag_n(:checkbox)
    name    = "checkbox_#{@id}_n_#{n}"
    content = "<input name=\"#{name}\" type=\"checkbox\"></input>"
    row_wrap content, "Checkbox [#{name}]"
  end

  def radio
    n      = tag_n(:radio)
    vals   = section_hash[:radio_n] || 4
    name   = "radio_#{@id}_n_#{n}"
    values = Array.new
    vals.times {|i| values.push("radio button #{i+1}")}
    content = ''
    values.each_with_index do |value, index|
      content += "<input name=\"#{name}\" type=\"radio\" value=\"#{value}\">#{value}</input>"
      content += '</br>' if (index + 1) < values.length
    end
    content = '<div style="margin-bottom: 1em;">' + content + '</div>'
    row_wrap content, "Radio [#{name}]"
  end

  def textarea
    n       = tag_n(:textarea)
    name    = "textarea_#{@id}_n_#{n}"
    content = "<textarea name=\"#{name}\"></textarea>"
    row_wrap content, "Textarea [#{name}]"
  end

  def label(label); "<h6>#{label || ''}</h6>"; end

  # ###
  # ### Carry Forward.
  # ###

  def carry_forward_expert_image
    carry_forward_image section_hash.merge(expert: true)
  end

  def carry_forward_image(hash=section_hash)
    # ### The client tag pre-processor defaults are phase='prev', file_type='image' and expert='false'. ### #
    phase_title = hash[:carry_forward] # the carry_forward phase-title to get the phase.id (overrides the phase: value)
    phase       = hash[:phase]         # relative phase value e.g. 'prev'|'previous'
    file_type   = hash[:file_type]
    expert      = hash[:expert]
    if phase_title.present?
      from_phase = @seed.model_class(:casespace, :phase).find_by(title: phase_title)
      @seed.error "Carry forward image from phase #{phase_title.inspect} not found." if from_phase.blank?
      phase = from_phase.id
    end
    tag  = "<thinkspace type=\"carry_forward_image\""
    tag += " phase=\"#{phase}\""         if phase.present?
    tag += " file_type=\"#{file_type}\"" if file_type.present?
    tag += " expert=\"#{expert}\""       if expert.present?
    "#{tag}></thinkspace>"
  end

  def carry_forward
    title = section_hash[:carry_forward]
    return if title.blank?
    from_phase = @seed.model_class(:casespace, :phase).find_by(title: title)
    elements   = input_elements_for_phases(from_phase)
    carry_forward_tags(elements)
  end

  def carry_forward_all
    assignment = @seed.get_association(phase, :casespace, :assignment)
    phases     = @seed.get_association(assignment, :casespace, :phases)
    elements   = input_elements_for_phases(phases)
    carry_forward_tags(elements)
  end

  def carry_forward_tags(elements)
    content  = '<table style="table-layout: auto; width: auto;">'
    content += '<thead><th>Element Type</th><th>Carry Forward Tag</th><th>Carry Forward Value</th></thead><tbody>'
    elements.each do |element|
      name     = element.name
      type     = element.element_type
      tag      = "<thinkspace type=\"carry_forward\" name=\"#{name}\"></thinkspace>"
      etag     = escape_html(tag)
      content += "<tr><td>#{type}</td><td style=\"padding-right: 2em;\">#{etag}</td><td style=\"font-weight: 500;\">#{tag}</td></tr>"
    end
    content += '</tbody></table>'
    row_wrap(content)
  end

  def input_elements_for_phases(phases)
    phases         = [phases].flatten.compact
    content_class  = @seed.model_class(:html, :content)
    element_class  = @seed.model_class(:input_element, :element)
    components     = @seed.model_class(:casespace, :phase_component).where(phase_id: phases.map(&:id), componentable_type: content_class.name)
    componentables = components.map(&:componentable)
    element_class.where(componentable: componentables).order(:id)
  end

  # ###
  # ### Helpers.
  # ###

  def tag_n(tag)
    @tags[tag] = @tags[tag].blank? ? 1 : @tags[tag] + 1
  end

  def format_content(content)
    return '' if content.blank?
    content.gsub(/\s\s+/, ' ').gsub("\n", ' ')
  end

  def escape_html(html); ERB::Util.html_escape(html); end

  def row_wrap(html, label=nil)
    content = '<div class="ts-grid_row"><div class="ts-grid_columns small-12">'
    content += label(label)  if label.present? && section_hash[:labels] != false
    content += html
    content += '</div></div>'
    content
  end

  # ###
  # ### Text.
  # ###

  def thinkspace; text; end

  def text
    content = <<-TEND
      ThinkSpace is a growing constellation of innovative learning applications each supported
      by a passionate community of users.  Join us to provide transformative learning experiences
      for your own students in an exciting, collaborative, online environment.
      <br><br>
      Our hub has a variety of effective learning applications with ready-to-use cases that can be
      used to enhance your teaching or simply embed the tools from the app into your own custom case.
    TEND
    row_wrap(content)
  end

  def lorem_all
    content = <<-TEND
      #{lorem}<br>
      #{lorem_1}<br>
      #{lorem_2}<br>
      #{lorem_3}
    TEND
    content
  end

  # ### From: https://www.lipsum.com/

  def lorem
    content = <<-TEND
      Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
      Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
      Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
      Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    TEND
    row_wrap(content)
  end

  def lorem_1
    content = <<-TEND
      Lorem Ipsum is simply dummy text of the printing and typesetting industry.
      Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
      when an unknown printer took a galley of type and scrambled it to make a type specimen book.
      It has survived not only five centuries, but also the leap into electronic typesetting,
      remaining essentially unchanged.
      It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages,
      and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
    TEND
    row_wrap(content)
  end

  def lorem_2
    content = <<-TEND
      Contrary to popular belief, Lorem Ipsum is not simply random text.
      It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old.
      Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia,
      looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage,
      and going through the cites of the word in classical literature, discovered the undoubtable source.
      Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of \"de Finibus Bonorum et Malorum\"
      (The Extremes of Good and Evil) by Cicero, written in 45 BC.
      This book is a treatise on the theory of ethics, very popular during the Renaissance.
      The first line of Lorem Ipsum, \"Lorem ipsum dolor sit amet..\", comes from a line in section 1.10.32.
    TEND
    row_wrap(content)
  end

  def lorem_3
    content = <<-TEND
      It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.
      The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters,
      as opposed to using 'Content here, content here', making it look like readable English.
      Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text,
      and a search for 'lorem ipsum' will uncover many web sites still in their infancy.
      Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).
    TEND
    row_wrap(content)
  end

end
