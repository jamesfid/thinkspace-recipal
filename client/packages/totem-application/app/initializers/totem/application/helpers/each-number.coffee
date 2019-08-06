import ember from 'ember'
import util  from 'totem/util'

initializer = 
  name:  'totem-application-helpers-each-number'
  after: ['totem']
  initialize: (container, app) ->

    # Return the 'index + 1' for a template's 'current' each loop.
    # See 'row-number' if have nested 'each' loops.
    # Options:  
    #   length: right pad the row number to length
    #   pad:    pad character (default '0')
    #   period: [true|false]  (default true)
    # e.g. = row-number length=3, pad='0', period=false  #=> 001
    ember.Handlebars.registerHelper 'each-number', (options) ->
      row    = ember.get options, 'data.view.contentIndex'
      row    = (row? and row + 1) or 0
      hash   = options.hash or {}
      length = hash.length
      period = hash.period
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


export default initializer
