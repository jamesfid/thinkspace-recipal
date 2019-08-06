module Thinkspace; module Authorization; class AbilityEngine

  attr_reader :ability, :current_user

  def initialize(ability)
    @ability      = ability
    @current_user = ability.user
  end

  def process
    raise "Ability class #{self.class.name.inspect} did not implement the 'process' method."
  end

  private

  def get_class(class_name); class_name.safe_constantize; end

  def read_space_ids;  ability.read_space_ids; end
  def admin_space_ids; ability.admin_space_ids; end

  def admin?; ability.admin?; end

  def can(   actions, klass, hash={}); ability.can(actions, klass, hash); end
  def cannot(actions, klass, hash={}); ability.cannot(actions, klass, hash); end

  def alias_action(*args); ability.alias_action(*args); end

  def get_private_methods; self.private_methods(false); end

  def call_private_methods; get_private_methods.each {|method| self.send(method)}; end

end; end; end
