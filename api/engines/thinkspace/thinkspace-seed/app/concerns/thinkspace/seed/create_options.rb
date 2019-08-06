module Thinkspace::Seed::CreateOptions

  # ###
  # ### Set Model Defaults when 'find_or_create = true'.
  # ###

  def institution_create_options(options)
    title = options[:title] || ''
    options.compact!
    options.reverse_merge!(
      description: "Description for #{title}",
      info:        Hash.new,
      state:       'active',
    )
  end

  def institution_user_create_options(options)
    options.compact!
    options.reverse_merge!(
      role:  'iadmin',
      state: 'active',
    )
  end

  def space_create_options(options)
    options.compact!
    options.reverse_merge!(
      sandbox_space_id: sandbox_space_id(options),
      state:            'active',
    )
  end

  def space_user_create_options(options)
    options.compact!
    options.reverse_merge!(
      role:  'read',
      state: 'active',
    )
  end

  def user_create_options(options)
    options.compact!
    options.reverse_merge!(
      first_name: 'Jane',
      last_name:  'Doe',
      email:      "#{options[:first_name].downcase}@sixthedge.com",
      state:      'active',
      superuser:  false,
    )
  end

  def assignment_create_options(options)
    title = options[:title] || ''
    options.compact!
    options.reverse_merge!(
      description:      "Description for #{title}",
      instructions:     "Instructions for #{title}.",
      bundle_type:      'casespace',
      state:            'active',
      settings:         Hash.new,
      release_at:       datetime_value(options[:release_at]),
      due_at:           datetime_value(options[:due_at], 7),
      create_timetable: true,
    )
  end

  def phase_create_options(options)
    title = options[:title] || ''
    options.compact!
    options.reverse_merge!(
      description:   "Descriptions for #{title}",
      default_state: 'unlocked',
      settings:      phase_settings(options),
      state:         'active',
    )
  end

  def phase_settings(options)
    settings = (options[:settings] || {}).deep_dup
    settings.reverse_merge!(
      validation: {validate: true},
      phase_score_validation: {
        numericality: {
          allow_blank:              false,
          greater_than_or_equal_to: 1,
          less_than_or_equal_to:    1000,
          decimals:                 0,
        },
      }
    )
    settings
  end

  def sandbox_space_id(options)
    title = options[:sandbox]
    return nil if title.blank?
    space = find_space(title: title)
    space.blank? ? nil : space.id
  end

end
