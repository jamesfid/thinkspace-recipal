module Thinkspace; module InputElement; module Exporters; class Element < Thinkspace::Common::Exporters::Base
  attr_reader :caller, :element, :ownerables
  
  def initialize(caller, element, ownerables)
    @caller     = caller
    @element    = element
    @ownerables = Array.wrap(ownerables)
  end

  def process
    element.thinkspace_input_element_responses.where(ownerable: ownerables).pluck(:value).join('|')
  end

end; end; end; end