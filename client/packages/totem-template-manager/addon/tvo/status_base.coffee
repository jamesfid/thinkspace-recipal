import ember from 'ember'

export default ember.Object.extend

  init_status_values: ->
    @set 'is_valid', false
    @set 'valid_count', 0
    @set 'invalid_count', 0
    @set 'status_messages', []

  get_is_valid:          -> @get 'is_valid'
  set_is_valid: (value)  -> @set 'is_valid', value

  get_status_messages:                   -> @get('status_messages')
  set_status_messages: (status_messages) -> @set 'status_messages', ember.makeArray(status_messages)

  get_valid_count:         -> @get 'valid_count'
  set_valid_count: (num)   -> @set 'valid_count', num

  get_invalid_count:       -> @get 'invalid_count'
  set_invalid_count: (num) -> @set 'invalid_count', num
          
  set_status_values: (status_instances) ->
    new ember.RSVP.Promise (resolve, reject) =>

      status_messages = []
      promises        = []
      valid_count     = 0
      invalid_count   = 0
      is_valid        = true

      status_instances.forEach (status) => promises.push status.set_status_values()

      ember.RSVP.allSettled(promises).then =>
        status_instances.forEach (status) =>
          if status.get_is_valid()
            valid_count += status.get_valid_count()
          else
            is_valid       = false
            invalid_count += status.get_invalid_count()
          status_messages = status_messages.concat status.get_status_messages()

        @set_is_valid(is_valid)
        @set_valid_count(valid_count)
        @set_invalid_count(invalid_count)
        @set_status_messages(status_messages)
        resolve({is_valid: is_valid, status_messages: status_messages})

  toString: -> 'TvoStatusBase'
