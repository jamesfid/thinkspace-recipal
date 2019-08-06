module Totem
  module Core
    class BaseSerializer < ActiveModel::Serializer
      embed :ids, include: true
    end
  end
end