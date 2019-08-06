import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  classNames: ['ts-builder_toolbar']

  # ### Components
  c_builder_toolbar: ember.computed.reads 'builder.c_builder_toolbar'