import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/component'

export default base.extend

  init: ->
    @_super()
    model = @am.get_model()
    @room = @am.pubsub.room_for(model)

  track_users: null

  willInsertElement:  -> @am.pubsub.tracker_show(room: @room, source: @, callback: 'handle_tracker_show')
  willDestroyElement: -> @am.pubsub.tracker_show_leave(room: @room)

  # TODO: want to list active users or select users via team_users?
  # TODO: should authorize publish the tracker info or make a separate server request?
  # TODO: how get title information (superuser?) (needs to make ajax call to publish tracker)? e.g. make ajax call? parts of room auth?
  #       - title information should be moved to 'data' mixin so do not need ajax call each time
  #       - make sure match array ordered so will match correctly (e.g. assignment match last)

  emit_tracker_show: (options) -> @am.pubsub.emit_tracker_show(options)
  handle_tracker_show: (data)  -> @set_track_users(data)

  set_track_users: (data) ->
    console.info 'tracker show', data
    values = data.value or []
    hrefs  = values.mapBy 'href'
    @get_tracker_href_to_title(hrefs).then (href_to_titles) =>
      href_users  = {}
      for hash in values
        href           = hash.href
        date           = hash.date
        date           = if date then @am.format_time(date) else 'no-date'
        title          = (hash.resource or {}).title
        user           = hash.user
        user.date      = date
        user.username  = @get_username(user)
        item           = (href_users[href] ?= {})
        [order, title] = @get_href_title(href_to_titles, href)
        item.title     = title
        item.order     = order
        users          = (item.users ?= [])
        users.push(user)
      track_users = []
      for href, item of href_users
        title = item.title
        order = item.order
        users = item.users.sortBy 'username'
        track_users.push {href, order, title, users}
      @set 'track_users', track_users.sortBy 'order'

  get_href_title: (href_to_titles, href) ->
    for hash in href_to_titles
      match = hash.match
      return [hash.order, hash.title] if match and href.match(match)
    href

  get_tracker_href_to_title: (hrefs) ->
    new ember.RSVP.Promise (resolve, reject) =>
      href_to_title = []
      href_to_title.push {match: 'casespace/cases/1/phases/1', title: 'IRAT', order: 2}
      href_to_title.push {match: 'casespace/cases/1/phases/2', title: 'TRAT', order: 3}
      href_to_title.push {match: 'casespace/cases/1/phases/3', title: 'Overview', order: 4}
      href_to_title.push {match: 'casespace/cases/1',          title: 'Assignment', order: 1}
      resolve(href_to_title)
