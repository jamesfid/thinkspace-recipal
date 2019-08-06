# Set the container in some modules.
# Register/inject modules.

import ds    from 'ember-data'
import ns    from 'totem/ns'
import ts    from 'totem/scope'
import te    from 'totem/error'
import tc    from 'totem/cache'
import ajax  from 'totem/ajax'
import i18n  from 'totem/i18n'

initializer = 
  name:       'totem'
  initialize: (container, app) ->
    # Add totem scope to base ember-data model for filtering on path_ids.
    ds.Model.reopen
      totem_scope: ts

    # totem/error
    app.register('totem:error', new te, instantiate: false)
    app.inject('controller', 'totem_error', 'totem:error')
    app.inject('route', 'totem_error', 'totem:error')
    app.inject('component', 'totem_error', 'totem:error')

    # totem/scope
    ts.set_container(container)  # set the container in totem scope
    app.register('totem:scope', ts, instantiate: false)
    app.inject('controller', 'totem_scope', 'totem:scope')
    app.inject('route', 'totem_scope', 'totem:scope')
    app.inject('component', 'totem_scope', 'totem:scope')

    # totem/ns
    app.register('totem:namespace', ns, instantiate: false)
    app.inject('controller', 'ns', 'totem:namespace')
    app.inject('route', 'ns', 'totem:namespace')
    app.inject('component', 'ns', 'totem:namespace')

    # totem/cache
    tc.set_container(container)
    app.register('totem:cache', tc, instantiate: false)
    app.inject('controller', 'tc', 'totem:cache')
    app.inject('route', 'tc', 'totem:cache')
    app.inject('component', 'tc', 'totem:cache')

    # totem/ajax
    ajax.set_container(container)  # set the container in totem ajax

    # totem/i18n
    i18n.set_container(container)  # set the container in totem i18n

    # totem/scope service
    app.register('service:totem_scope', ts, instantiate: false)


export default initializer
