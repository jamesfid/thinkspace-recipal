module Thinkspace; module Html; module Exporters; class Content < Thinkspace::Common::Exporters::Base
  attr_reader :caller, :componentable, :elements, :phase, :ownerables, :ownerable_type
  attr_reader :exporters_element_class

  def initialize(caller, componentable, phase, ownerables)
    @caller                  = caller
    @componentable           = componentable
    @elements                = componentable.thinkspace_input_element_elements if componentable.present?
    @phase                   = phase
    @ownerables              = Array.wrap(ownerables)
    @ownerable_type          = @ownerables.first.class.name if @ownerables.first || nil
    @exporters_element_class = Thinkspace::InputElement::Exporters::Element
  end

  def process
    return if elements.empty?
    data            = Hash.new
    data[:values]   = Hash.new
    ownerables.each do |ownerable|
      data[:values][ownerable] ||= Array.new
      elements.each do |element|
        element_data = @exporters_element_class.new(self, element, ownerable).process
        data[:values][ownerable].push element_data
      end
    end
    add_element_headers
    add_data_to_sheet(data)
  end

  # ### Data additions
  def add_element_headers
    book  = caller.get_book_for_record(phase)
    sheet = caller.find_or_create_worksheet_for_phase(book, phase, get_sheet_name)
    names = Array.new
    elements.each { |element| names.push get_sheet_header_for_element(element) }
    caller.add_header_to_sheet(sheet, *(get_sheet_header_identifiers), *names)
  end

  def add_data_to_sheet(data)
    book  = caller.get_book_for_record(phase)
    sheet = caller.find_or_create_worksheet_for_phase(book, phase, get_sheet_name)
    data[:values].each_with_index do |(ownerable, values), index|
      row_number = index + 1
      sheet.update_row row_number, *(get_ownerable_identifiers(ownerable)), *values
    end
  end

  # ### Sheet name/header helpers
  def get_sheet_name
    componentable.class.name.split('::').last
  end

  def get_sheet_header_for_element(element)
    "#{element.name}"
  end

  def get_sheet_header_identifiers; caller.get_sheet_header_identifiers(@ownerable_type); end
  def get_ownerable_identifiers(ownerable); caller.get_ownerable_identifiers(ownerable); end

end; end; end; end
