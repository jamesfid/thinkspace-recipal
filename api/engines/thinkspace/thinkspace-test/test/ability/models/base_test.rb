require 'ability/test_helper'

module Test; module Ability; module Models; class Base < ActiveSupport::TestCase

  include ::Thinkspace::Test::Casespace::Models
  include ::Totem::Test::Ability::All

  models         = [get_space(:ability_space_1), get_assignment(:ability_assignment_1_1), get_phase(:ability_phase_1_1_A)]
  read_actions   = alias_read_actions
  modify_actions = [:update]

  describe 'can read' do
    users = get_users :read_1, :update_1, :owner_1
    run_ability_can_tests(models, read_actions, users)
  end

  describe 'can update' do
    users = get_users :update_1, :owner_1
    run_ability_can_tests(models, modify_actions, users)
  end

  describe 'cannot read' do
    users = get_users :read_2, :update_2, :owner_2
    run_ability_cannot_tests(models, read_actions, users)
  end

  describe 'cannot update' do
    users = get_users :read_1, :read_2, :update_2, :owner_2
    run_ability_cannot_tests(models, modify_actions, users)
  end

end; end; end; end
