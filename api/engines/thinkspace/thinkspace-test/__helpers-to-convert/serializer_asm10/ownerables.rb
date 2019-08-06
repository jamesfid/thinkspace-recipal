module Thinkspace::Test; module SerializerAsm10; module Ownerables
extend ActiveSupport::Concern
included do

  def read_1;   @_read_1   ||= get_user(:serializer_read_1); end
  def update_1; @_update_1 ||= get_user(:serializer_update_1); end

end; end; end; end
