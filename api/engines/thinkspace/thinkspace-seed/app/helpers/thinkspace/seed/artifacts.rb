class Thinkspace::Seed::Artifacts < Thinkspace::Seed::BaseHelper

  attr_reader :markup_discussionables

  def common_component_titles; [:artifact]; end

  def process(*args)
    super
    process_config
    process_auto_input if auto_input?
  end

  private

  def process_config
    @buckets = Array.new
    assignment_phase_components_by_config_for_titles.each do |assignment, phase_components|
      phase_components.each do |phase_component|
        phase        = @seed.get_association(phase_component, :casespace, :phase)
        section_hash = phase_section_value(phase_component) || {}
        instructions = section_hash[:instructions] || 'No instructions.'
        bucket       = create_model(:artifact, :bucket, authable: phase, instructions: instructions)
        save_phase_component(phase_component, bucket)
        @buckets.push(bucket)
      end
    end
  end

  def process_auto_input
    array = auto_input[:artifacts]
    return if array.blank?
    array.each do |options|
      @markup_discussionables = AutoInput.new(@seed, @configs).process(config, @buckets, options)  # if comments, populates @discussionables
    end
  end

  class AutoInput < ::Thinkspace::Seed::BaseHelper
    include ::Thinkspace::Seed::AutoInput

    # Auto input example:
    #   artifacts:
    #     - phases:         only do for phase titles e.g. phase_a
    #       users:          [read_1, read_2, read_3] (or teams)
    #       files:          file.pdf
    #       rename:         true      #=> prepend user's first name to file name (done only when paperclip storage is 'filesystem') e.g. read_1-file.pdf
    #       comments:       2         #=> number of markup comments to auto-generate
    #       comment_values:           #=> coordinates of comments; markup_comments will try to prevent overlaps (defaults to x=0, y=0, page=1)
    #         - {x:         384, y: 144, page: 1}
    #         - {x:         384, y: 244, page: 1}
    #       # 'dir' only needed if files are not in 'thinkspace-seed/db/seed_data/files'
    #       dir: '../../../seed_files'  #=> file path relative to 'Rails.root'
    #       dir: staging                #=> file path relative to 'thinkspace-seed/db/seed_data'

    def process(config, buckets, options)
      @config  = config
      @buckets = buckets
      set_options(options)
      @discussionables
    end

    def set_options(options)
      super
      @files           = [options[:files]].flatten.compact
      @dir             = options[:dir]
      @rename          = options[:rename]   || false
      @comments        = options[:comments] || false # number of comments when present
      @discussionables = Array.new
      add_artifacts
    end

    def add_artifacts
      @buckets.each do |bucket|
        phase = bucket.authable
        next if skip_phase?(phase)
        ownerables = find_phase_ownerables(phase)
        ownerables.each do |ownerable|
          next if skip_ownerable?(ownerable)
          add_artifact_files(phase, ownerable, bucket)
        end
      end
    end

    def add_artifact_files(phase, ownerable, bucket)
      @files.each do |file|
        path                = @dir.blank? ? find_file(file) : find_file(File.join(dir, file))
        artifact            = create_model(:artifact, :file, bucket: bucket, user: ownerable, ownerable: ownerable)
        artifact.attachment = File.open(path)
        save_model(artifact)
        if rename?
          name = "#{ownerable_text(ownerable)}-#{file}"
          rename_paperclip_file(artifact, name, :attachment)
        end
        @discussionables.push(artifact) if @comments
      end
    end

    def rename?; @rename == true && paperclip_local_storage?; end

  end # AutoInput

end
