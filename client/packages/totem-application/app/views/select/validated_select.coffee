import ember from 'ember'
import validations_mixin from 'totem-application/mixins/validated_field'

export default ember.View.extend validations_mixin,
  templateName:      'select/validated_select'