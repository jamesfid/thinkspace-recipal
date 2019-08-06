import ember from 'ember'

export default ember.Handlebars.makeBoundHelper (duration_in_seconds, options) ->
  minutes = Math.floor(duration_in_seconds / 60)
  if minutes > 59
    hours = Math.floor(minutes / 60)
    minutes = minutes % 60
    minutes = if minutes < 10 then "0#{minutes}"
  seconds = duration_in_seconds % 60
  seconds = if seconds < 10 then "0#{seconds}" else seconds
  if hours then return "#{hours}:#{minutes}:#{seconds}" else return "#{minutes}:#{seconds}"