module Thinkspace::Test; module Clone; module Clone
extend ActiveSupport::Concern
included do

  def clone_record(options={})
    options[:dictionary] = record.get_clone_dictionary
    options.reverse_merge!(ownerable: ownerable) if ownerable.present? && !options.has_key?(:ownerable)
    options.reverse_merge!(user: user)           if user.present? && !options.has_key?(:user)
    cloned_record = record.cyclone(options)
    print_options_dictionary_ids(options)  if self.respond_to?(:print_ids) && self.send(:print_ids) == true
    [cloned_record, options]
  end

  def get_dictionary(options={}); options[:dictionary]; end
  def is_full_clone?(options={}); options[:is_full_clone] == true; end

  def create_into_clone_space
    @_clone_space_count = (@_clone_space_count || 0) + 1
    space = space_class.create(title: 'Into Clone Space' + @_clone_route_count.to_s, state: :active)
    save_model(space) # ensure no validation errors
    space
  end

  def create_into_clone_assignment(space)
    @_clone_assignment_count = (@_clone_assignment_count || 0) + 1
    assignment = assignment_class.create(title: 'Into Clone Assignment' + @_clone_assignment_count.to_s, space_id: space.id, state: :active)
    save_model(assignment) # ensure no validation errors
    assignment
  end

end; end; end; end
