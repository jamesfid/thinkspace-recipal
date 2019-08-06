module Totem; module Core; module Controllers; module ApiRender; module Metadata

  def controller_metadata_model_path; (controller_ability_class_name.deconstantize + '::metadata').underscore.pluralize; end

  def controller_metadata_add_to_json(json)
    controller_metadata_set_in_json(json, controller_metadata_json)
  end

  def controller_metadata_set_in_json(json, metadata_json)
    (json[controller_metadata_model_path] ||= Array.new).push(*metadata_json)  if metadata_json.present?
    serializer_options.clear_collect_metadata
  end

  def controller_metadata_json
    ownerable      = serializer_options.collect_data_ownerable
    ownerable_id   = ownerable.id
    ownerable_type = ownerable.class.name.underscore
    json           = Array.new
    serializer_options.collect_metadata_data.each do |hash|
      id  = hash[:type].present? ? "#{hash[:type]}.#{hash[:id]}" : "#{hash[:id]}"
      id += "::#{ownerable_type}.#{ownerable_id}"
      json.push(id: id, metadata: hash[:data])
    end
    json
  end

end; end; end; end; end
