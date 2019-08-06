import ember from 'ember'

export default ember.View.extend
  classNames: ['totem_message_outlet-view']

  # Clicking anywhere in the view div (other than a item with a class of 'sign_out')
  # is like clicking continue.
  mouseDown: (event) ->
    controller = @get('controller')
    if (event.target and ember.$(event.target).hasClass('sign-out'))
      controller.sign_out_user()
    else
      controller.hide_session_timeout_warning()
      controller.reset_session_timer(stay_alive: true)
