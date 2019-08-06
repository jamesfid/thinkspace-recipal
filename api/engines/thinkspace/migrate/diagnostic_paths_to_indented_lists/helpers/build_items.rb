module Thinkspace; module Migrate; module DiagnosticPathsToIndentedLists; module Helpers; class BuildItems

  attr_reader :path, :ownerable, :debug
  attr_reader :items_hash

  def initialize(path, ownerable, options={})
    @path      = path
    @ownerable = ownerable
    @pos_y     = 0
    @debug     = options[:debug] || false
  end

  def process
    validate_path_items
    get_ownerable_path_items
  end

  private

  def get_ownerable_path_items
    items = Array.new
    root_path_items = get_root_path_items
    root_path_items.each do |path_item|
      add_path_item_path_items(items, path_item)
    end
    if debug?
      print_debug(items)
      items = items.collect {|item| item.except(:debug)}
    end
    items
  end

  def add_path_item_path_items(items, path_item, x=0, max=30)
    raise_error "Maximum recursive path items reached (#{max}) ."  if x > max
    items.push convert_path_item_to_item_hash(path_item, x)
    path_items = get_path_item_path_items(path_item)
    if path_items.present?
      x += 1
      path_items.each do |item|
        add_path_item_path_items(items, item, x)
      end
    end
  end

  def convert_path_item_to_item_hash(path_item, pos_x)
    hash                       = Hash.new
    hash[:pos_y]               = @pos_y
    hash[:pos_x]               = pos_x
    hash[:itemable_id]         = path_item.path_itemable_id
    hash[:itemable_type]       = path_item.path_itemable_type
    hash[:itemable_value_path] = 'value'
    hash[:description]         = path_item.description
    hash[:category]            = path_item.category
    @pos_y += 1
    debug_path_item_hash(hash, path_item)  if debug?
    hash
  end

  # ###
  # ### Scopes.
  # ###

  def get_root_path_items; get_path_items.where(parent_id: nil); end

  def get_path_item_path_items(path_item); path_item.thinkspace_diagnostic_path_path_items.order(:position); end

  def get_path_items; path.thinkspace_diagnostic_path_path_items.where(ownerable: ownerable).order(:position); end

  # ###
  # ### Validation.
  # ###

   # All path_item.path_itemable exist.
  def validate_path_items
    items           = get_path_items
    blank_itemables = items.select {|p| p.path_itemable_id.present? && p.path_itemable.blank?}
    ids             = blank_itemables.map(&:id)
    raise_error "Path item ids #{ids} have a blank path_itemable"  if ids.present?
  end

  # ###
  # ### Debug.
  # ###

  def debug?; @debug.present?; end

  def debug_path_item_hash(hash, path_item)
    debug                = hash[:debug] = Hash.new
    debug[:id]           = path_item.id
    debug[:path_id]      = path_item.path_id
    debug[:parent_id]    = path_item.parent_id
    debug[:ownerable_id] = path_item.ownerable_id
  end

  def print_debug(items)
    puts '-'.ljust(80, '-')
    items.each do |item|
      puts "\n"  if item[:pos_x] == 0
      pad = '  ' * item[:pos_x]
      pad += '|'
      y   = item[:pos_y].to_s.rjust(4, '.')
      x   = item[:pos_x].to_s.rjust(4, '.')
      d   = item[:debug]
      id  = d[:id].to_s.rjust(4, '.')
      pid = d[:parent_id].blank? ? 'nil'.rjust(4, '.') : d[:parent_id].to_s.rjust(4, '.')
      h   = d.except(:id, :parent_id)
      p   = pad.ljust(12, '.')
      puts "  #{p} y#{y} x#{x}  id#{id} parent_id#{pid} -> #{h}"
    end
  end

  # ###
  # ### Errors.
  # ###

  def raise_error(message='')
    message = message + " for\n  Path: #{path.inspect}\n  Ownerable: #{ownerable.inspect}."
    raise BuildIndentedListError, message
  end

  class BuildIndentedListError < StandardError; end

end; end; end; end; end
