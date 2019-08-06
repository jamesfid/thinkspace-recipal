import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-readiness-assurance/base/admin/component'

export default base.extend

  admin_message_rooms: ember.computed -> @am.ra.get_admin_room()

