import ember          from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  actions:
    new: -> @get('response_manager').new_top()
