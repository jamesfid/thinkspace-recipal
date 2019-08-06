import ember   from 'ember'
import tc      from 'totem/cache'
import ns      from 'totem/ns'
import config  from 'totem/config'


export default ember.Mixin.create
  tos_link: ember.computed -> config.tos_link
  pn_link:  ember.computed -> config.pn_link

  get_latest_terms: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        action: 'latest_for'
        verb:   'GET'
        data:   
          doc_type: 'terms_of_service'

      @tc.query(ns.to_p('agreement'), query, single: true).then (tos) =>
        resolve(tos)

  tos: null
  
  has_terms: ember.computed.notEmpty 'tos'
