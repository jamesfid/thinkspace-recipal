module Thinkspace; module IndentedList; module Concerns; module SerializerOptions; module Responses

  def create(serializer_options)
    common_serializer_options(serializer_options)
  end

  def show(serializer_options)
    common_serializer_options(serializer_options)
  end

  def update(serializer_options)
    common_serializer_options(serializer_options)
  end

  def common_serializer_options(serializer_options)
    serializer_options.remove_association  :ownerable
    serializer_options.remove_association  :thinkspace_common_user
  end

end; end; end; end; end
