module Thinkspace; module Migrate; module Assignments; module Helpers
  module Parse

    attr_reader :root_path
    attr_reader :current_assignment_path
    attr_reader :current_assignment_node
    attr_reader :space
    attr_reader :user
    attr_reader :image_prefix
    attr_reader :process_ids
    attr_reader :timeline_nodes

    attr_reader :verbose
    attr_reader :debug
    attr_reader :test_overrides

    def set_root_path(args)
      @root_path = File.join(Dir.pwd, args)
      stop_run "Assignments xml path is not a directory #{root_path.inspect}."  unless File.directory?(root_path)
    end

    def set_current_assignment_path(xml_id)
      @current_assignment_path = File.join(root_path, xml_id)
      raise_error "XML assignment id #{xml_id} directory #{current_assignment_path.inspect} does not exist."  unless File.directory?(current_assignment_path)
    end

    def set_timeline_nodes
      filename = 'timeline.xml'
      path     = File.expand_path("../#{filename}", root_path)
      raise_error "#{filename.inspect} at #{path.inspect} does not exist."  unless File.file?(path)
      doc   = parse_xml File.read(path)
      nodes = doc.css('timeline')
      raise_error "No timeline found in #{path.inspect}."  if nodes.blank?
      @timeline_nodes = nodes
    end

    def get_timeline_node_by_id(id)
      node = timeline_nodes.css("event[_id='#{id.to_s}']")
      node.present? ? node : raise_error("Timeline node id #{id} not found.")
    end

    def get_assignment_title(id); get_timeline_node_by_id(id).css('title').text; end

    def get_assignment_nodes
      filename = 'assignments.xml'
      path     = File.expand_path(filename, root_path)
      raise_error "#{filename.inspect} at #{path.inspect} does not exist."  unless File.file?(path)
      doc   = parse_xml File.read(path)
      nodes = doc.css('assignment')
      raise_error "No assignments found in #{path.inspect}."  if nodes.blank?
      nodes
    end

    def get_assignment_item_type_nodes
      filename = 'itemtypes.xml'
      path     = File.join(current_assignment_path, filename)
      raise_error "#{filename.inspect} at path #{path.inspect} does not exist."  unless File.file?(path)
      doc   = parse_xml File.read(path)
      nodes = doc.css('itemtype')
      raise_error "No item types found in #{path.inspect}."  if nodes.blank?
      nodes.blank? ? [] : nodes
    end

    def get_assignment_phase_nodes
      filename = 'multiphase.xml'
      path     = File.join(current_assignment_path, filename)
      raise_error "#{filename.inspect} at path #{path.inspect} does not exist."  unless File.file?(path)
      doc   = parse_xml File.read(path)
      nodes = doc.css('phase')
      raise_error "No phases found in #{path.inspect}."  if nodes.blank?
      nodes
    end

    def get_assignment_diagnosis_nodes
      filename = 'diagnosis.xml'
      path     = File.join(current_assignment_path, filename)
      raise_error "#{filename.inspect} at path #{path.inspect} does not exist."  unless File.file?(path)
      nodes = parse_xml File.read(path)
      raise_error "No item types found in #{path.inspect}."  if nodes.blank?
      nodes
    end

    def get_phase_node(id)
      filename = "phase#{id}.xml"
      path     = File.join(current_assignment_path, filename)
      raise_error "#{filename.inspect} at path #{path.inspect} does not exist."  unless File.file?(path)
      doc  = parse_xml File.read(path)
      node = doc.css('phase')
      raise_error "No phase node in path #{path.inspect}."  if node.blank?
      node
    end

    def get_item_type_category(item_type)
      raise_error "Item type is blank."  if item_type.blank?
      type = assignment_item_types.find {|it| it.type == item_type}
      raise_error "Item type #{item_type.inspect} not found."  if type.blank?
      type.category
    end

    # ###
    # ### Parse Helpers.
    # ###

    def parse_html(content)
      Nokogiri::HTML.fragment(content) do |config|
        config.nonet
      end
    end

    def parse_xml(xml)
      Nokogiri.XML(xml) do |config|
        config.nonet
      end
    end

    # ###
    # ### Helpers.
    # ###

    def timestamp_title(title)
      Time.now.to_s(:id) + ' ' + title
    end

    def verbose?;         verbose.present?; end
    def debug?;           debug.present?; end
    def test_overrides?;  test_overrides.present?; end

    def print_message(message='')
      puts '[ts-migrate] ' + message
    end

    def print_debug(message='', options={})
      return unless debug?
      message = '[debug]----: ' + message
      if options.blank?
        message = message + "\n" + debug_message_ids + "\n" + debug_message_nodes
      else
        message += ' '  + debug_message_ids     if options[:ids] == true
        message += "\n" + debug_message_nodes   if options[:node] == true
      end
      puts message
    end

    def debug_message_ids
      ids = ''
      ids += "[assignment XML id: #{get_node_id(current_assignment_node)}]"   if current_assignment_node.present?
      ids += "[phase XML id: #{get_node_id(current_phase_node)}]"             if current_phase_node.present?
      ids
    end

    def debug_message_nodes
      nodes = ''
      nodes += current_assignment_node.to_s + "\n"  if current_assignment_node.present?
      nodes += current_phase_node.to_s + "\n"       if current_phase_node.present?
      nodes
    end

    def debug_message(message='')
      message + "\n" + debug_message_ids + "\n" + debug_message_nodes
    end

    def stop_run(message='')
      print_message "\n"
      print_message message
      print_message "Run stopped."
      print_message "\n"
      exit
    end

    def raise_error(message='')
      message = debug_message(message)  if debug?
      raise XMLError, message
    end

    class XMLError  < StandardError; end

    class ItemType
      attr_reader :node
      def initialize(node); @node = node; end
      def attribute(name); node && node.attribute(name.to_s) && node.attribute(name.to_s).text; end
      def icon;   attribute(:icon); end
      def label;  attribute(:label); end
      def name;   attribute(:name); end
      def style;  attribute(:style); end
      def type;   name; end
      def category
        hash         = Hash.new
        hash[:icon]  = icon
        hash[:label] = label
        hash[:name]  = name
        hash[:style] = style
        hash
      end
    end

    # ###
    # ### Space, User, Space User helpers (need these?).
    # ###

    def set_space
      space_class = Thinkspace::Common::Space
      space_id = ENV['SPACE_ID']
      if space_id.present?
        @space = space_class.find_by(id: space_id)
        raise_error "Space id #{space_id} not found."  if space.blank?
      else
        create_space(space_class)
      end
    end

    def create_space(space_class)
      space_type = Thinkspace::Common::SpaceType.first
      @space     = space_class.create(title: timestamp_title('Migrate Assignments Test'))
      Thinkspace::Common::SpaceSpaceType.create(space_id: space.id, space_type_id: space_type.id)
    end

    def set_user
      user_class = Thinkspace::Common::User
      user_id = ENV['USER_ID']
      if user_id.present?
        @user = user_class.find_by(id: user_id)
        raise_error "User id #{user_id} not found."  if user.blank?
      else
        create_users(user_class)
      end
    end

    def create_users(user_class)
      owner      = {email: "owner_1@sixthedge.com",  first_name: 'owner_1',  last_name: 'Doe'}
      reader     = {email: "read_1@sixthedge.com",   first_name: 'read_1',  last_name: 'Doe'}
      if (@user = user_class.find_by(owner)).blank?
        @user  = user_class.create(owner)
      end
      if (reader_user = user_class.find_by(reader)).blank?
        reader_user  = user_class.create(reader)
      end
      create_space_user(user, :owner)
      create_space_user(reader_user, :read)
    end

    def create_space_user(u, role, s=space)
      Thinkspace::Common::SpaceUser.create(
        space_id: s.id,
        user_id:  u.id,
        role:     role.to_s,
      )
    end

    # ###
    # ### Additional options (IMAGE_PREFIX)
    # ###

    def set_image_prefix
      image_prefix  = ENV['IMAGE_PREFIX']
      return unless image_prefix.present?
      image_prefix.chop! if image_prefix.end_with?('/')
      @image_prefix = image_prefix
    end

    def set_remove_observation_links
      remove_observation_links = ENV['REMOVE_OBSERVATION_LINKS']
      return unless remove_observation_links.present?
      @remove_observation_links = remove_observation_links == 'true' ? true : false
    end

    def set_process_ids
      ids = ENV['PROCESS_IDS']
      return if ids.blank?
      @process_ids = ids.split(',')
      # @process_ids    = ['1', '2', '10' ,'13']
    end

  end # module

end; end; end; end
