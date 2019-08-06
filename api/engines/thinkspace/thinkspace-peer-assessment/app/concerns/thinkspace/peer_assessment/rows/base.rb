module Thinkspace; module PeerAssessment; module Rows; class Base
  include Thinkspace::PeerAssessment::Shared::Helpers

  attr_reader :record, :sheet, :rows
  alias_attribute :model, :record

  def initialize(sheet, model)
    @record = model
    @sheet  = sheet
    @rows   = {}
  end

  def serialize
    serialized = {}
    @sheet.headers.each { |h| serialized[h] = property(h) }
    serialized
  end

  def serialize_to_array
    headers    = @sheet.headers
    serialized = []
    temp       = serialize
    headers.each { |h| serialized.push(temp.with_indifferent_access[h]) }
    serialized
  end

  def property(prop)
    return @record.send(prop) if @record.respond_to?(prop)
    self.send(prop)
  end

end; end; end; end
