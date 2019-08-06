import ember from 'ember'
import ns from 'totem/ns'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'


export default base.extend auth_mixin,
  titleToken: 'Edit'
  
  model: (params) ->
    @store.find(ns.to_p('library'), params.library_id)