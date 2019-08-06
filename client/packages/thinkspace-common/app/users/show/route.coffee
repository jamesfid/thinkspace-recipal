import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/base/route'

export default base.extend
  model: (params) -> @store.find(ns.to_p('user'), params.user_id)

  renderTemplate: -> @render(ns.to_p('users', 'show'))