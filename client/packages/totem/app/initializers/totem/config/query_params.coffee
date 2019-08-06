import qp from 'totem/config/query_params'

initializer = 
  name: 'totem-config-query-params'

  initialize: (container, app) -> qp.process(container)

export default initializer
