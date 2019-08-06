import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'

export default ember.Mixin.create

  send_tracker: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @get_auth_query @get_tracker_url('tracker'), {}
      ajax.object(query).then =>
        resolve()

  get_tracker_url: (action) -> ns.to_p('readiness_assurance', 'tracker', action)

# add to data so don't re-get each time.
#  publish data:           
#    user_id:      instructor user id
#    user_ids:     space user ids
#    href_matches: [match: model-path, title: model-title]
