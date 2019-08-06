require 'ability/test_helper'

module Test; module AbilityRules; class Print < ActiveSupport::TestCase

  include ::Totem::Test::Ability::All
  include ::Thinkspace::Test::Casespace::All


  # describe 'ability'  do
  #
  #   let (:owner)     {get_user(:owner_1)}
  #   let (:updater)   {get_user(:update_1)}
  #   let (:reader)    {get_user(:read_1)}
  #   let (:superuser) {get_user(:superuser)}
  #
  #   # describe 'rules' do
  #   #   it "print" do
  #   #     print_ability_rules(reader)
  #   #   end
  #   # end
  #
  #   # describe 'cancan rule objects' do
  #   #   it "print" do
  #   #     print_cancan_rules(phase_class, superuser, reader, updater, owner)
  #   #   end
  #   # end
  #
  # end


end; end; end
