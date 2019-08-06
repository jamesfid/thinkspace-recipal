import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from './base'

export default base_component.extend

  c_list_source_another: ns.to_p 'indented_list', 'list', 'source', 'another'

  validate_indented_list: (status) ->
    new ember.RSVP.Promise (resolve, reject) =>
      console.warn 'validating other indented list.....................', @, status
      status.set_is_valid(false)
      status.increment_invalid_count()
      status.set_status_messages ["Use all observations."]
      resolve()
    #   tvo      = @get('tvo')
    #   section  = @get('attributes.source')
    #   action   = 'itemables'
    #   messages = []
    #   status.set_is_valid(true)
    #   if tvo.section.has_action(section, action)
    #     tvo.section.call_action(section, action).then (itemables) =>
    #       itemables.forEach (item) =>
    #         unless item.get_is_used() == true
    #           status.increment_invalid_count()
    #           status.set_is_valid(false)
    #           # messages.push "Not used: #{item.get('value')}"
    #       messages.push "Use all observations."  unless status.get_is_valid()
    #       status.set_status_messages messages.uniq()
    #       resolve()
    #     , (error) => reject(error)
    # , (error) => reject(error)
