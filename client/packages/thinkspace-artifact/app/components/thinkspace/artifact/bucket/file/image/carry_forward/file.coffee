import ember  from 'ember'
import ns     from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Properties
  image_url:   null
  is_expert:   false
  is_loading:  false
  missing_msg: 'Image is not available.'

  # ### Components
  c_loader: ns.to_p 'common', 'loader'

  didInsertElement: -> @load_and_show_image()

  load_and_show_image: ->
    from_phase = @get('tag_attrs.phase') || 'prev'
    is_expert  = @get('is_expert')
    @set 'is_loading', true
    @tc.image.carry_forward_url({from_phase, is_expert}).then (url) =>
      @set 'is_loading', false
      return if ember.isBlank(url) # no image uploaded for the from_phase
      @set 'image_url', url
      @totem_messages.api_success(source: @, action: 'carry_forward_url', i18n_path: ns.to_o('artifact', 'file', 'image_loaded'))
    , (error) =>
      @set 'is_loading', false
