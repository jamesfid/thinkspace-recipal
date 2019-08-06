import ember  from 'ember'
import config from 'totem/config'
import ns     from 'totem/ns'

export default ember.Object.extend
  # ### Properties
  connection:  null # The Socket connection to subscribe to channels with, etc.
  channel_map: null

  # ### Services
  thinkspace: ember.inject.service()

  # ### Helpers
  initialize: ->
    unless typeof(window.Pusher) == 'object'
      # console.warn 'No Pusher object found - is internet connection good?'
      return

    @connect()
    @subscribe_all()

  subscribe_all: -> 
    @subscribe('global')

  connect:        -> 
    return console.warn "No Pusher object found - is internet connection good?" unless ember.isPresent(Pusher)
    @set 'connection', new Pusher(config.pusher_app_key) 
  get_connection: -> @get 'connection'

  get_channel: (name) ->
    map     = @get 'channel_map'
    channel = map.get name
    if ember.isPresent(channel) then return channel else null

  get_channel_map: -> 
    map  = @get 'channel_map'
    @set 'channel_map', ember.Object.create() unless ember.isPresent(map)
    @get 'channel_map'

  subscribe: (name) -> 
    channel = @get_connection().subscribe(name)
    @add_to_channel_map(name, channel)
    fn = @["events_#{name}"]
    if fn? then @["events_#{name}"]() else null # Do not call fn() otherwise you lose `this` (unless you call correctly)

  add_to_channel_map: (name, channel) ->
    map = @get_channel_map()
    map.set name, channel

  # ### Event handlers
  # ### Automatically called by subscribe via `events_#{name_of_channel}`
  warn_no_channel: (name) -> console.warn "[sockets] No channel found for name: [#{name}]"

  events_global: ->
    name    = 'global'
    channel = @get_channel(name)
    return @warn_no_channel(name) unless ember.isPresent(channel)

    channel.bind 'notify', (data) =>
      message = data.message
      type    = data.type or 'info'
      return unless ember.isPresent(message)
      @get('thinkspace').add_system_notification(type, message)


