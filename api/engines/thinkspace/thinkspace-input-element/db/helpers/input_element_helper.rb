require 'nokogiri'

def input_element_html_preprocessors(*args)
  options   = args.extract_options!
  attribute = options[:attribute] || 'html_content'
  paths     = Array.new
  paths.push [:input_element, :preprocessors, :responses]      if options[:responses] == true
  paths.push [:input_element, :preprocessors, :carry_forward]  if options[:carry_forward] == true
  [{attribute: attribute, paths: paths}]
end

def create_input_elements(*args)
  options        = args.extract_options!
  componentable  = args.shift
  content_column = args.shift
  content        = componentable.send content_column
  input_element_names(content).each do |hash|
    element               = @seed.new_model(:input_element, :element)
    element.name          = hash[:name]
    element.element_type  = hash[:element_type]
    element.componentable = componentable
    @seed.create_error(element) unless element.save
  end
end

def input_element_names(content)
  input_names = []
  radio_names = []
  html        = Nokogiri::HTML.fragment(content)
  inputs      = html.css('input')
  inputs.each do |input|
    type = input['type']
    name = input['name']
    if type == 'radio'
      next if radio_names.include?(name) # radio will have dup names (only add first one)
      radio_names.push(name)
    end
    input_names.push({name: name, element_type: type})
  end
  inputs      = html.css('textarea')
  inputs.each do |input|
    input_names.push({name: input['name'], element_type: 'textarea'})
  end
  input_names
end
