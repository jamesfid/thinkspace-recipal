import ember from 'ember'

export default ember.View.extend

  # DatePickerView options:
  #   - content : the record for the datepicker
  #   - property : the record's property that the datepicker is changing
  #   - hide_input = false : hides the input box for the datepicker
  #   - hide_button = false : hides the button for the datepicker
  #   - save_on_close = true : saves the record after setting the property
  classNames:    ['date-picker']
  is_open:       false
  hide_input:    false
  hide_button:   false
  time_picker:   false
  save_on_close: true
  current_time:  null
  current_date:  null

  time_picker_header: ''
  date_picker_header: ''
  placeholder:        ''

  didInsertElement: ->
    view          = @
    time_picker   = @get('time_picker')
    controller    = @get('controller')
    content       = @get('content')
    property      = @get('property')
    date          = content.get(property)
    date_type     = typeof date
    date          = new Date(date) if date_type == 'string' # handle ISOString()
    selected_time = moment(date).format('h:mm A') if date
    selected_time = '12:00 PM' unless selected_time
    @set('current_date', date.toDateString()) if date
    @set('current_time', selected_time) if selected_time

    if time_picker
      @set_and_initialize_time_picker(selected_time)
      @set_and_initialize_date_picker(date)
    else
      @set_and_initialize_date_picker(date)

  set_and_initialize_time_picker: (time) ->
    $input        = @$('.date-pick_time-picker-input')
    view          = @
    save_on_close = @get('save_on_close')

    $input.pickatime
      onSet: ->
        time_string = @get() # See http://amsul.ca/pickadate.js/api.htm#method-get
        view.set('current_time', time_string)
        view.set_content_property()
        view.save_content() if save_on_close

    time_picker = $input.pickatime('picker')
    time_picker.set('select', time)

  set_and_initialize_date_picker: (date) ->
    $input        = @$('.datepicker')
    content       = @get('content')
    view          = @
    save_on_close = @get('save_on_close')
    $input.pickadate
      onClose: ->
        date_string = @get() # See http://amsul.ca/pickadate.js/api.htm#method-get
        return if ember.isEmpty(date_string)
        view.set('current_date', date_string)
        view.set_content_property()
        view.save_content() if save_on_close

    date_picker = $input.pickadate('picker')
    date_picker.set('select', date)

  get_date: ->
    current_time = @get('current_time')
    current_date = @get('current_date')
    date_string  = "#{current_date} #{current_time}"
    date         = new Date(date_string)

  set_content_property: ->
    content  = @get('content')
    property = @get('property')
    return if not content and property
    date     = @get_date()
    content.set(property, date)

  save_content: ->
    content = @get('content')
    content.save()

  actions:
    toggle_date: ->
      $date_picker = @$('.datepicker').pickadate()
      date_picker = $date_picker.pickadate('picker')
      date_picker.open()
