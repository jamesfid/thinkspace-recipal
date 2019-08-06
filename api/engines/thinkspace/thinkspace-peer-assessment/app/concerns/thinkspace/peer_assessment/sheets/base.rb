module Thinkspace; module PeerAssessment; module Sheets; class Base
  include Thinkspace::PeerAssessment::Shared::Helpers
  
  attr_reader :caller, :worksheet, :rows

  def initialize(caller)
    @caller    = caller
    @worksheet = nil
    @rows      = {}
  end

  def name; self.class.name.split('::').pop.camelize; end
  def headers; []; end
  def process; puts "[WARN] No process method for [#{self.class}]"; end

  # # Worksheet
  def add_worksheet(book)
    @worksheet = book.create_worksheet name: name
    add_worksheet_headers
    add_worksheet_rows
  end

  def add_worksheet_headers
    @worksheet.update_row 0, *headers
    headers.each_with_index { |h, i| @worksheet.row(0).set_format(i, header_format) }
  end

  def add_worksheet_rows; puts "[WARN] No add_worksheet_rows for [#{self.class}]"; end

  def header_format; Spreadsheet::Format.new weight: :bold; end

end; end; end; end
