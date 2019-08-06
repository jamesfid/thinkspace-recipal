class Thinkspace::Seed::Resources < Thinkspace::Seed::BaseHelper

  def config_keys; [:resource_tags]; end

  def process(*args)
    super
    return unless process?
    process_config
  end

  private

  def process_config
    tags = config[:resource_tags]
    return if tags.blank?
    AutoInput.new(@seed, @configs).process(config, tags) # the 'resource_tags' key is like an auto-input (using class name AutoInput so ignored by @configs)
  end

  class AutoInput < ::Thinkspace::Seed::BaseHelper

    def process(config, tags)
      @config = config
      @tags   = [tags].flatten.compact
      @tags.each do |hash|
        case
        when hash[:assignment].present?   then add_assignment_resouces(hash)
        when hash[:phase].present?        then add_phase_resources(hash)
        else config_error "Resource tag [hash: #{hash.inspect}] requires an assignment or phase key.", config
        end
      end
    end

    def add_assignment_resouces(hash)
      title      = hash[:assignment]
      assignment = find_assignment(title: title)
      config_error "Resource tag assignment [title: #{title.inspect}] not found.", config  if assignment.blank?
      add_tags(assignment, hash)
    end

    def add_phase_resources(hash)
      title = hash[:phase]
      phase = find_phase(title: title)
      config_error "Resource tag phase [title: #{title.inspect}] not found.", config  if phase.blank?
      add_tags(phase, hash)
    end

    def add_tags(taggable, hash)
      name  = hash[:user]
      user  = find_user_by_name(name)
      tags  = [hash[:tags]].flatten.compact
      tags.each do |tag_hash|
        title = tag_hash[:title] || 'missing_resource_title'
        tag   = create_tag(title: title, taggable: taggable, user: user)
        files = [tag_hash[:files]].flatten.compact
        links = [tag_hash[:links]].flatten.compact
        add_files(taggable, tag, user, files) if files.present?
        add_links(taggable, tag, user, links) if links.present?
      end
    end

    def add_files(taggable, tag, user, files)
      files.each do |hash|
        dir      = hash[:dir]    || ''
        file     = hash[:source] || hash[:name]
        path     = dir.blank? ? find_file(file) : find_file(File.join(dir, file))
        options  = hash.merge(path: path, resourceable: taggable, tag: tag, user: user)
        resource = create_file(path, options)
        name     = options[:name]
        rename_paperclip_file(resource, name) if name.present? && name != file
      end
    end

    def add_links(taggable, tag, user, links)
      links.each do |hash|
        options = hash.merge(resourceable: taggable, tag: tag, user: user)
        create_link(options)
      end
    end

    def create_file(path, options)
      config_error "File path is blank.", config  if path.blank?
      config_error "File #{path.inspect} does not exist.", config  unless File.file?(path)
      file      = create_model(:resource, :file, options)
      file.file = File.open(path)
      save_model(file)
      create_file_tag(options.merge(file: file))  if options[:tag].present?
      file
    end

    def create_link(options)
      hash = options.compact
      link = create_model(:resource, :link, hash.reverse_merge(title: 'missing link title', url:'missing link url'))
      create_link_tag(hash.merge(link: link)) if options[:tag].present?
      link
    end

    def create_tag(options);      create_model(:resource, :tag, options); end
    def create_file_tag(options); create_model(:resource, :file_tag, options); end
    def create_link_tag(options); create_model(:resource, :link_tag, options); end

  end # AutoInput

end
