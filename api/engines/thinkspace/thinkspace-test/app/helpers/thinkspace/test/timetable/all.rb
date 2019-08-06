module Thinkspace::Test; module Timetable; module All
extend ActiveSupport::Concern
included do

  include ::Totem::Test::Models::ModelSave
  include ::Thinkspace::Test::Casespace::Models
  include ::Thinkspace::Test::Timetable::Models
  include ::Thinkspace::Test::Timetable::Assert

 end; end; end; end
