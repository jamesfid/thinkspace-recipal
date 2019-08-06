import locales from 'totem/config/locales'

initializer = 
  name: 'totem-config-locales'

  initialize: (container, app) -> locales.process()

export default initializer
