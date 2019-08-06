import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'

export default ember.Object.extend
  # ### Properties
  title: null

  # ### Services
  builder: ember.inject.service()