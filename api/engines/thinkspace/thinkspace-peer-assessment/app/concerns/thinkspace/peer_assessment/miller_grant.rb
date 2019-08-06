module Thinkspace; module PeerAssessment; class MillerGrant
  attr_reader :sheets, :book

  def initialize(options={})
    @master = options[:master] || false
    @debug  = options[:debug]  || true
    @book   = Spreadsheet::Workbook.new
    set_sheets
  end

  def set_sheets
    @sheets = []
    types   = %w{spaces space_users users assessments phases assignments teams team_users categories balance both aggregate}
    types.each do |type|
      path  = "Thinkspace::PeerAssessment::Sheets::#{type.camelize}"
      puts "[initialize_sheets] Processing path [#{path}]" if is_debug?
      klass = path.safe_constantize
      next unless klass
      @sheets.push(klass.new(self))
    end
  end

  # # Processing
  def process
    process_sheets
    process_book
    write_files
  end

  def process_sheets
    @sheets.each { |s| s.process }
  end
  
  def process_book
    @sheets.each { |s| s.add_worksheet(@book) if s.respond_to?(:add_worksheet) }
  end

  # # Output
  def write_files
    path      = File.join(Rails.root, 'spreadsheets')
    filename  = Time.now.strftime('%Y-%m-%d_%H-%M-%S') + '.xls'
    full_path = "#{path}/#{filename}"
    @book.write full_path
  end

  # # Helpers
  def is_master?; @master; end
  def is_debug?;  @debug;  end
  def sheet_by_name(name); @sheets.find { |s| s.name == name }; end

end; end; end
