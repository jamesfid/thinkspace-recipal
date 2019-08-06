import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/component'

export default base.extend

  select: 'select'
  done:   'done'

  actions:
    clear: -> @sendAction 'clear'

    done: (config) -> @sendAction 'done', config

    select: (config) -> @sendAction 'select', config
