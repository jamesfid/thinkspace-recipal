def create_lab_chart(*args)
  options = args.extract_options!
  chart   = @seed.new_model(:lab, :chart, options)
  @seed.create_error(chart)  unless chart.save
  chart
end

def create_lab_category(*args)
  options  = args.extract_options!
  category = @seed.new_model(:lab, :category, options)
  @seed.create_error(category)  unless category.save
  category
end

def create_lab_result(*args)
  options = args.extract_options!
  result  = @seed.new_model(:lab, :result, options)
  @seed.create_error(result)  unless result.save
  result
end

def find_lab_chart(*args)
  options = args.extract_options!
  @seed.model_class(:lab, :chart).find_by(options)
end
