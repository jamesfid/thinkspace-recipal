class Thinkspace::Seed::MarkupLibrary < Thinkspace::Seed::BaseHelper

  def process(*args)
    super
    process_auto_input if auto_input?
  end

  private

  def process_auto_input
    array = [auto_input[:markup_library]].flatten.compact
    return if array.blank?
    array.each do |options|
      AutoInput.new(@seed, @configs).process(config, options)
    end
  end

  class AutoInput < ::Thinkspace::Seed::BaseHelper
    include ::Thinkspace::Seed::AutoInput

    def process(config, options)
      @config = config
      set_options(options)
      process_spaces
    end

    def set_options(options)
      super
      @comments = options[:comments] || 3
      @lib_tags = options[:tags] || []
    end

    def process_spaces
      @include_spaces.each do |title|
        space = space_class.find_by(title: title)
        config_error "Markup library space #{title.inspect} not found." if space.blank?
        users = find_space_users(space)
        process_users(space, users)
      end
    end

    def process_users(space, users)
      users.each do |user|
        next if skip_user?(user)
        lib      = process_library(space, user)
        lib_coms = process_comments(space, lib, user)
      end
    end

    def process_library(space, user)
      lib = find_model(:markup, :library, user_id: user.id)
      return lib if lib.present?
      lib  = create_model(:markup, :library, user: user)
      tags = @lib_tags.deep_dup
      tags += ['Tag X']  if @comments > tags.length  # add default if more comments than tags
      add_tags(lib, tags)
      save_model(lib)
      lib
    end

    def process_comments(space, lib, user)
      lib_coms = @seed.model_class(:markup, :library_comment).where(user_id: user.id)
      return lib_coms if lib_coms.present?
      lib_coms = Array.new
      tags     = @lib_tags.deep_dup
      @comments.times do |i|
        tag     = tags.shift || 'Tag X'
        comment = "[#{user.first_name}] Comment #{i+1}."
        lib_com = create_model(:markup, :library_comment, library: lib, user: user, comment: comment)
        add_tags(lib_com, tag)
        save_model(lib_com)
        lib_coms.push(lib_com)
      end
      lib_coms
    end

    def add_tags(record, tags)
      all_tags = [tags].flatten.compact.sort.uniq
      all_tags.each do |tag|
        record.tag_list.add(tag)
      end
    end

  end # AutoInput

end
