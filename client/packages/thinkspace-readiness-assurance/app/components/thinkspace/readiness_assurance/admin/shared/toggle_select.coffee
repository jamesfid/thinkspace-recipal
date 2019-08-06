import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/component'

export default base.extend

  actions:
    toggle: -> @toggleProperty('rad.show_select'); return
