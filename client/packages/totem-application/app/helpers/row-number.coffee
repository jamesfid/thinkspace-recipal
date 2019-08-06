import ember from 'ember'
import util  from 'totem/util'

# Return the 'row_number + 1' property on the row_object
# and set the updated row number on the row_object.
# Useful for nested each loops to get a running row number.
# The 'row_object' is required as the first parameter.
# defaults: period=true
#         : length specified then pad='0'
# Example:
# = each user in users
#   = each team in user.teams
#     = row-number this                                       #=> '1.'
#     = row-number this 'myrow_number' length=3               #=> '001.'
#     = row-number this 'myrow_number' length=3 period=false  #=> '001'
#     = row-number this 'myrow_number' length=3 pad='x'       #=> 'xx1.'
export default ember.Handlebars.makeBoundHelper (row_object, row_prop, options) ->
  return '' unless row_object and row_object.set?
  unless options
    options  = row_prop
    row_prop = 'row_number'
  row    = row_object.get(row_prop) or 0
  row   += 1
  hash   = options.hash or {}
  length = hash.length
  period = hash.period
  row_object.set row_prop, row
  if period == false
    period = ''
  else
    period = '.'
  if length
    pad = hash.pad
    pad = (pad? and pad) or '0'
    util.rjust(row, length, "#{pad}") + period
  else
    row + period
