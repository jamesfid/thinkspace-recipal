def create_simulation_simulation(*args)
  options = args.extract_options!
  simulation = @seed.new_model(:simulation, :simulation, options)
  @seed.create_error(simulation) unless simulation.save
  simulation
end