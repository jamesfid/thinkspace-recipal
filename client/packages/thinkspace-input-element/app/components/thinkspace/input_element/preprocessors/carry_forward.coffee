import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import totem_scope from 'totem/scope'

# Process carry forward tags e.g. <thinkspace type="carry_forward" name="some_input_tag_name"></thinkspace>
# @tvo is set when this preprocessor is created by the totem-template-manager.
export default ember.Object.extend

  process: (componentable, template) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(template) unless (componentable and template)
      @process_carry_forward_tags(componentable, template).then (template) =>
        @process_carry_forward_image_tags(componentable, template).then (template) =>
          resolve(template)

  process_carry_forward_tags: (componentable, template) ->
    new ember.RSVP.Promise (resolve, reject) =>
      $content = ember.$('<div/>').html(template)
      $tags    = $content.find('thinkspace[type=carry_forward]')
      return resolve(template)  if $tags.length < 1

      type  = ns.to_p 'response'
      names = ($tags.map (index, tag) -> $(tag).attr('name')).toArray()

      @get_carry_forward_responses_from_server(names).then (payload) =>
        response_json  = payload[ns.to_p 'responses']
        norm_responses = componentable.store.normalize(type, response_json)
        responses      = componentable.store.pushMany(type, norm_responses)

        c_path   = ns.to_p 'input_element', 'elements', 'carry_forward'
        name_map = payload['element_map'] or {}

        $tags.each (index, tag) =>
          $tag          = $(tag)
          name          = $tag.attr('name')
          comp_name     = $tag.attr('title') or 'standard'
          ids           = name_map[name] or []
          tag_responses = responses.filter (response) => ids.contains parseInt(response.get 'id')

          hash =
            component:    c_path + "/#{comp_name}"
            responses:    tag_responses
            element_name: name

          value_path = @tvo.value.set_value hash

          html = '{{ component'
          html += " tvo.#{value_path}.component"
          html += " responses=tvo.#{value_path}.responses"
          html += " element_name=tvo.#{value_path}.element_name"
          html += ' }}'

          $tag.replaceWith(html)

        resolve $content.html()

      , (error) => reject(error)

  get_carry_forward_responses_from_server: (names) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        verb:   'post'
        action: 'carry_forward'
        model:  ns.to_p 'response'
        data:
          element_names: names
      totem_scope.add_ownerable_to_query(query.data)
      totem_scope.add_authable_to_query(query.data)
      ajax.object(query).then (payload) =>
        resolve(payload)
      , (error) => reject(error)

  # ###
  # ### Carry Forward Image.
  # ###

  # Process carry forward image tags e.g. <thinkspace type="carry_forward_image" phase="prev|id|prev-#" expert="true|false" file_type="image"></thinkspace>
  process_carry_forward_image_tags: (componentable, template) ->
    new ember.RSVP.Promise (resolve, reject) =>
      $content = ember.$('<div/>').html(template)
      $tags    = $content.find('thinkspace[type=carry_forward_image]')
      return resolve(template)  if $tags.length < 1

      $tags.each (index, tag) =>
        $tag      = $(tag)
        file_type = $tag.attr('file_type') || 'image'
        component = ns.to_p 'artifact', 'bucket', 'file', file_type, 'carry_forward', 'wrapper'

        tag_attrs  = @get_tag_attributes(tag)
        hash       = {component, tag_attrs}
        value_path = @tvo.value.set_value(hash)

        html = '{{ component'
        html += " tvo.#{value_path}.component"
        html += " tag_attrs=tvo.#{value_path}.tag_attrs"
        html += ' }}'
        $tag.replaceWith(html)

      resolve $content.html()

  get_tag_attributes: (tag) ->
    node_map = tag.attributes
    lasti    = node_map.length - 1
    return {} unless lasti >= 0
    attrs = {}
    for i in [0..lasti]
      attrs[node_map[i].name] = node_map[i].value
    attrs
