def create_observation_list(*args)
  options = args.extract_options!
  helper  = @seed.new_model(:observation_list, :list, options)
  @seed.create_error(helper) unless helper.save
  helper
end

def create_observation_list_group(*args)
  options  = args.extract_options!
  options[:title] ||= 'no title'
  group = @seed.new_model(:observation_list, :group, options)
  @seed.create_error(group)  unless group.save
  group
end

def create_observation_list_group_lists(group, lists)
  group_lists = Array.new
  [lists].flatten.compact.each do |list|
    group_list = @seed.new_model(:observation_list, :group_list, group: group, list: list)
    @seed.create_error(group_list)  unless group_list.save
    group_lists.push group_list
  end
  group_lists
end
