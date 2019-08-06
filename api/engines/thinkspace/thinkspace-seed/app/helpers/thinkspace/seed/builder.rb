class Thinkspace::Seed::Builder < Thinkspace::Seed::BaseHelper

  def process(*args); end # do nothing during processing and suppress processing message

  def post_process
    super
    post_process_builder
  end

  private

  # Currently create a template for all assignment and phases.
  # Could add a flag in the config to determine whether to add to the builder templates.
  def post_process_builder
    spaces      = space_class.all
    assignments = assignment_class.all
    phases      = phase_class.all
    @seed.message color(">>Builder post process templates [spaces: #{spaces.length}, assignments: #{assignments.length}, phases: #{phases.length}].", :cyan, :bold)
    spaces.each { |record| create_builder_template(record) }
    assignments.each { |record| create_builder_template(record) }
    phases.each { |record| create_builder_template(record) }
  end

  def create_builder_template(record)
    title   = (record.title || 'no_title').humanize
    options = {
      templateable: record,
      title:        title,
      description:  'Description ' + title,
    }
    create_model(:builder, :template, options)
  end

end
