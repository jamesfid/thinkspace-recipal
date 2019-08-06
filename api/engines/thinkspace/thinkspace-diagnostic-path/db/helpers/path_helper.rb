def create_diagnostic_path_path(*args)
  options    = args.extract_options!
  path       = @seed.new_model(:diagnostic_path, :path, options)
  path.title ||= 'Diagnostic Test Path [generated]'
  @seed.create_error(path)  unless path.save
  path
end

def create_diagnostic_path_path_item(*args)
  options    = args.extract_options!
  item       = @seed.new_model(:diagnostic_path, :path_item, options)
  @seed.create_error(item)  unless item.save
  item
end
