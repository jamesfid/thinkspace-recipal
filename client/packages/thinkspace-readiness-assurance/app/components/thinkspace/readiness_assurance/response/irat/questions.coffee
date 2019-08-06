import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend

  question_managers: ember.computed ->
    managers = []
    @rm.question_manager_map.forEach (qm) => managers.push(qm)
    managers
