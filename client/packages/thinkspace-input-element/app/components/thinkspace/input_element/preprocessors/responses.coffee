import ember  from 'ember'
import ns     from 'totem/ns'
import logger from 'totem/logger'
import totem_scope from 'totem/scope'

# Process input and textarea tags and replace with components.
# @tvo is set when this preprocessor is created by the totem-template-manager.
export default ember.Object.extend

  process: (componentable, template) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(template) unless (componentable and template)
      componentable.get(ns.to_p 'elements').then (elements) =>
        return resolve(template)  if ember.isBlank(elements)
        $content         = ember.$('<div/>').html(template)
        status_path      = @tvo.status.set_value('elements')  # get or create an 'elements' status object and return the tvo path
        show_errors_path = @tvo.hash.get_path('show_errors')

        @tvo.helper.ownerable_view_association_records_each(componentable, elements, each: 'response').then (responses) =>

          # The html content contains a html string with input tags.  This view generator
          # replaces the input tags with handlebars 'componet' for the responses.
          elements.forEach (element, index) =>
            response   = responses.objectAt(index)
            input_name = element.get 'name'

            return reject("Componentable id [#{componentable.get('id')}] input element id [#{element.get('id')}] is blank") unless input_name

            # Specify input possibilities here otherwise collision with carry forward is possible.
            $input = $content.find("input[name=#{input_name}]")
            $input = $content.find("textarea[name=#{input_name}]") unless ember.isPresent($input)
            return resolve() unless $input
            return reject("Componentable id [#{componentable.get('id')}] tool_content is missing input element name [#{input_name}]") unless $input.length > 0

            tag_kind   = @tvo.tag_kind($input)
            tag_type   = @tvo.tag_type($input)
            attributes = @tvo.tag_attribute_hash($input)

            if @is_checkbox(tag_type)
              attributes.disabled = true  if totem_scope.get('is_view_only')
            else
              attributes.disabled = true  if totem_scope.get('is_disabled')
              attributes.readonly = true  if totem_scope.get('is_read_only')

            unless response
              response  = element.store.createRecord ns.to_p('response'), value: null
              response.set ns.to_p('element'), element
              totem_scope.set_record_ownerable_attributes(response)
              response.didLoad()

            hash             = {}
            hash.component   = ns.to_p('elements', @get_input_component_name(tag_kind, tag_type))
            hash.model       = response
            hash.tattrs      = attributes
            hash.validations = @get_validations(tag_type) if @tvo.hash.get_value('process_validations')

            path = @tvo.value.set_value_for element, hash

            html = []
            html.push "tvo.#{path}.component"
            html.push @tvo.component_bind_properties(path, hash)
            html.push "show_errors=tvo.#{show_errors_path}"
            html.push "status=tvo.#{status_path}"

            attribute_query   = "#{tag_kind}[name='#{input_name}']"
            attribute_matches = $content.find(attribute_query)
            logger.error "No attribute match found for find on #{attribute_query} against: #{$content.html()}"         if attribute_matches.length == 0

            if @is_radio(tag_type)
              group_guid = @tvo.generate_guid()
              html.push "status_group_guid='#{group_guid}'"
              attribute_matches.each (index, input_match) =>
                $radio = $(input_match)
                value  = $radio.attr('value')
                if value?
                  comp = ["radio_value='#{value}'"]
                  $radio.replaceWith @get_component_html(html.concat comp)
                else
                  logger.error "Radio button #{input_match} does not have a value attribute."
            else
              logger.warn  "Possible mass-replacement of an InputElement due to multiple matches for #{attribute_query}" if attribute_matches.length > 1
              attribute_matches.replaceWith @get_component_html(html)

          resolve $content.html()

  get_component_html: (html) -> '{{ component ' + html.join(' ') + ' }}'

  is_radio: (tag_type)    -> tag_type == 'radio'
  is_checkbox: (tag_type) -> tag_type == 'checkbox'

  get_input_component_name: (tag_kind, tag_type) ->
    switch tag_kind
      when 'input'
        switch
          when @is_checkbox(tag_type)
            'standard_checkbox'
          when @is_radio(tag_type)
            'standard_radio'
          else
            'standard_input'
      when 'textarea'
        'standard_textarea'
      else
        null

  # Hard coded validation rules - need a way to persist the appropriate values per input element.
  # Validations are added to the actual model (e.g. user response).
  get_validations: (tag_type) ->
    return {} if @is_checkbox(tag_type)
    input_value:
      presence:
        message: 'You must enter a response'
