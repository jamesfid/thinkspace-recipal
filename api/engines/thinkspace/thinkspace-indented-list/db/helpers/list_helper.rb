def create_indented_list_list(*args)
  options = args.extract_options!
  list    = @seed.new_model(:indented_list, :list, options)
  @seed.create_error(list)  unless list.save
  list
end

def create_indented_list_response(*args)
  options  = args.extract_options!
  response = @seed.new_model(:indented_list, :response, options)
  @seed.create_error(response)  unless response.save
  response
end

def create_indented_list_expert_response(*args)
  options  = args.extract_options!
  response = @seed.new_model(:indented_list, :expert_response, options)
  @seed.create_error(response)  unless response.save
  response
end
