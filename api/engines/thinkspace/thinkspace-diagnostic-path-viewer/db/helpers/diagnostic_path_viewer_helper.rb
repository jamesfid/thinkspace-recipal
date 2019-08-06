def create_diagnostic_path_viewer_viewer(*args)
  options = args.extract_options!
  viewer  = @seed.new_model(:diagnostic_path_viewer, :viewer, options)
  @seed.create_error(viewer) unless viewer.save
  viewer
end