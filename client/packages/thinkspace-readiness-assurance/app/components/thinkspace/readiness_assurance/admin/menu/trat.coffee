import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/menu'

export default base.extend

  menu: ember.computed.reads 'am.trat_menu'
