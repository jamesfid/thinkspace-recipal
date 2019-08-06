import ember from 'ember'

export default ember.Mixin.create
  # ### Properties
  tse_threshold_height:    500
  tse_scrollable_class:    'tse-scrollable'
  tse_scrollable_selector: ember.computed 'tse_scrollable_class', -> ".#{@get('tse_scrollable_class')}"

  # ### Events
  didInsertElement: ->
    #ember.run.schedule 'afterRender', @, =>
      #$(@get('tse_scrollable_selector')).TrackpadScrollEmulator()

  # ### Helpers
  set_scrollable_height: (element, threshold=500) ->
    #height = if element.height() < threshold then element.height() else threshold
    #$scrollable = element.closest(@get('tse_scrollable_selector'))
    #$scrollable.css('height', "#{height}px")
    #@tse_recalculate()

  get_tse_scrollables: ->  #$(@get('tse_scrollable_selector'))
  tse_recalculate:     ->  
    #$scrollables = @get_tse_scrollables()
    #$scrollables.TrackpadScrollEmulator('recalculate') if ember.isPresent($scrollables)
  tse_run_next_recalculate: -> #ember.run.next @, => @tse_recalculate()
  tse_scroll_to_top:   -> 
    #$scrollables = @get_tse_scrollables()
    #$scrollables.TrackpadScrollEmulator('scroll', 'top') if ember.isPresent($scrollables)
  tse_resize: ->  #@set_scrollable_height(@$(), @get('tse_threshold_height'))
