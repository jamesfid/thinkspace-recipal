import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  model:               null # Ember `tbl:overview` model
  calculated_overview: null # Server-generated anonymized overview object
  assessment:          null

  # ### Templates
  t_qualitative: ns.to_t 'tbl:overview', 'type', 'shared', 'qualitative'

  has_comments:                          ember.computed.or 'has_qualitative_constructive_comments', 'has_qualitative_positive_comments'
  has_qualitative_positive_comments:     ember.computed.notEmpty 'calculated_overview.qualitative.positive'
  has_qualitative_constructive_comments: ember.computed.notEmpty 'calculated_overview.qualitative.constructive'