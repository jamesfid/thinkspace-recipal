import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend
  tagName:           'div'
  classNameBindings: ['no_errors::ts-ra_error']

  actions:
    select: (id) -> @sendAction 'select', id
