module Totem; module Core; module Controllers; module ApiRender; module Paginate

  extend ::ActiveSupport::Concern

  included do
    def controller_paginated?; params.has_key?(:page); end
  end

  # Return paginated JSON format.
  def controller_paginated_json(records, options={})
    controller_as_paginated_json(records, options)
  end

  def controller_as_paginated_json(records, options)
    records = controller_paginate(records, options)
    json    = controller_as_json(records, options)
    json    = controller_add_pagination_to_json(records, json)
    json
  end

  def controller_paginate(records, options)
    number = controller_pagination_get_number
    count  = controller_pagination_get_count 
    records.page(number).per(count)
  end

  def controller_pagination_links_key; 'links'; end
  def controller_pagination_meta_key; 'meta'; end

  def controller_pagination_get_number; params[:page][:number].to_i || 0; end
  def controller_pagination_get_count;  params[:page][:count].to_i  || 25; end

  def controller_add_pagination_to_json(records, json)
    total_pages   = records.total_pages
    total_records = records.total_count
    url           = request.base_url + request.path
    links         = controller_pagination_links_key
    json          = add_pagination_information(json, total_pages, total_records)
    json
  end

  def controller_paginate_and_render_json(json, options={})
    options              = options.with_indifferent_access
    path                 = options[:path]

    if controller_paginated?
      if json[path].present?
        records           = Array.wrap(json[path])
        total_records     = records.length
        total_pages       = (records.length.to_f / controller_pagination_get_count).ceil
        paginatable_array = Kaminari.paginate_array(records)
        records           = paginatable_array.page(controller_pagination_get_number).per(controller_pagination_get_count)
        json[path]        = records
      else
        total_pages = 0
      end

      json = add_pagination_information(json, total_pages, total_records)
    end

    controller_render_json(json)
  end

  def add_pagination_information(json, total_pages, total_records)
    url         = request.base_url + request.path
    links       = controller_pagination_links_key

    # Add the `links` key
    ['first', 'last', 'next', 'prev'].each do |type|
      link = controller_pagination_link_for_type(type, total_pages)

      json[links] ||= {}
      link[:page][:number].present? ? full_url = url + "?#{link.to_query}" : full_url = nil
      json[links][type] = full_url
    end

    # Add the `meta` key.
    meta = controller_pagination_meta_key
    json[meta]                  ||= {}
    json[meta][:total]          = total_records
    json[meta][:page]           ||= {}
    json[meta][:page][:total]   = total_pages
    total_pages == 0 ? current_page = 0 : current_page = controller_pagination_get_number
    json[meta][:page][:current] = current_page

    json
  end

  def controller_pagination_link_for_type(type, total_pages)
    link   = {}
    page   = {count: controller_pagination_get_count}
    number = controller_pagination_get_number
    case type
      when 'first'
        page[:number] = 1
      when 'last'
        page[:number] = total_pages
      when 'next'
        next_page     = number + 1
        next_page     = nil if next_page > total_pages
        page[:number] = next_page
      when 'prev'
        prev_page     = number - 1
        prev_page     = nil if prev_page <= 0
        page[:number] = prev_page
    end
    link[:page]    = page
    link[:sort]    = params[:sort]   if params.has_key?(:sort)
    link[:filter]  = params[:filter] if params.has_key?(:filter)
    link
  end

end; end; end; end; end
