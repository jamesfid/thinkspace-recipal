import gc from 'thinkspace-casespace/generic_container'

initializer = 
  name:       'thinkspace-casespace-register'
  initialize: (container, app) ->

    app.register 'view:template_manager_view_container', gc

export default initializer
