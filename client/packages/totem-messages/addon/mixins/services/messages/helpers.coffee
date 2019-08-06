import ember from 'ember'

export default ember.Mixin.create

  date_to_hh_mm: (date) -> @ttz.format(date, format: 'h:mm a')

  date_from_now: (date) ->
    zdate = @ttz.format(date, {})
    moment(zdate).fromNow()
  
  minutes_from_now: (date) ->
    r = Math.floor ( ( (+date) - (+new Date()) ) / 60000 )
    r + ' minute' + (if r==1 then '' else 's')

  is_string: (obj) -> obj and typeof(obj) == 'string'
  
  is_function: (obj) -> obj and typeof(obj) == 'function'
