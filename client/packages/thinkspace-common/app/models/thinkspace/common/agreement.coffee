import ember from 'ember'
import ta    from 'totem/ds/associations'
import ns    from 'totem/ns'

export default ta.Model.extend
  doc_type: ta.attr('string')
  link:     ta.attr('string')