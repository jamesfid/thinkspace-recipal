import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import valid from 'thinkspace-casespace/mixins/assignments/validity'

export default base.extend valid,
  model:        null # Assignment record
  hide_success: false
