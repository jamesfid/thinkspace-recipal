# Javascript only utility functions
# DO NOT add functions that have dependencies on the ember application being created.

class UtilityJS

  # startsWith()/endsWith() not implemented in Chrome:
  # => https://code.google.com/p/chromium/issues/detail?id=372976
  starts_with: (string, prefix) ->
    (string or '').indexOf(prefix) == 0

  ends_with: (string, suffix) ->
    (string or '').match(suffix + '$') + '' == suffix

  rjust: (value, length, padding=' ') ->
    [pad, value] = @padding(value, length, padding)
    pad + value

  ljust: (value, length, padding=' ') ->
    [pad, value] = @padding(value, length, padding)
    value + pad

  padding: (value, length, padding) ->
    value = '' if not value and not value == false
    value = value.toString()
    return ['', value] if length and value.length >= length
    pad   = Array(length + 1 - value.length).join(padding)
    return [pad, value]

  flatten_array: (array) ->
    flattened = []
    for element in array
      if @is_array(element)
        flattened = flattened.concat @flatten_array element
      else
        flattened.push element
    flattened

  is_array: (obj) ->
    return false  unless obj
    return true   if (Array.isArray && Array.isArray(obj))
    return true   if ( (obj.length != undefined) && typeof(obj) == 'object' )
    return false

  current_date: -> new Date()

  mm_dd_yyyy: (d=@current_date()) ->
    mm   = @rjust(d.getMonth()+1,2,'0')
    dd   = @rjust(d.getDate(),2,'0')
    yyyy = d.getFullYear()
    "#{mm}/#{dd}/#{yyyy}"

  hh_ss_mm: (d=@current_date()) ->
    hh = @rjust(d.getHours(),2,'0')
    mm = @rjust(d.getMinutes(),2,'0')
    ss = @rjust(d.getSeconds(),2,'0')
    "#{hh}:#{mm}:#{ss}"

  date_time: (d=@current_date()) ->
    "#{@mm_dd_yyyy(d)} #{@hh_ss_mm(d)}"

  date_time_milliseconds: (d=@current_date()) ->
    "#{@date_time(d)}:#{@rjust(d.getMilliseconds(),3,'0')}"

  convert_time_string_to_milliseconds: (string) ->
    return null unless string and typeof(string) == 'string'
    [number_of, units] = string.split('.')
    return null if number_of.match(/\D/)
    switch units
      when 'seconds', 'second'
        number_of * 1000
      when 'minutes', 'minute'
        number_of * 60000
      when 'hours', 'hour'
        number_of * 3600000
      else
        null

  add_path_objects: (obj, route) ->
    path = null
    for name in route.split('.')
      if path? then path = path + '.' + name else path = name
      obj.set path, {} unless obj.get(path)?

  set_path_value: (obj, route, value) ->
    @add_path_objects(obj, route)
    obj.set(route, value)

  string_array_to_numbers: (array) ->
    array.forEach (string, index) => array[index] = parseInt(string)
    array

  string_to_color: (str) ->
    hash = 0
    i    = 0
    while i < str.length
      hash = str.charCodeAt(i) + (hash << 5) - hash
      i++
    color = '#'
    i     = 0
    while i < 3
      value = hash >> i * 8 & 0xFF
      color += ('00' + value.toString(16)).substr(-2)
      i++
    color



export default new UtilityJS
