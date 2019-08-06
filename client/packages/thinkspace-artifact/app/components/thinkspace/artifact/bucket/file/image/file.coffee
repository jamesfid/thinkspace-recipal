import ember  from 'ember'
import ns     from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Properties
  image_url:   null
  is_loading:  false
  missing_msg: 'Image is not available.'

  # ### Observer
  show_file_change: ember.observer 'show_file', -> @load_and_show_image()

  # ### Components
  c_loader: ns.to_p 'common', 'loader'

  didInsertElement: -> @load_and_show_image()  # in case show_file is initially set as true (e.g. auto show files)

  load_and_show_image: ->
    return unless @get 'show_file'
    model = @get('model')
    return if ember.isBlank(model)
    @set 'is_loading', true
    @tc.image.url({model}).then (url) =>
      @set 'is_loading', false
      return if ember.isBlank(url) # no image uploaded for the from_phase
      @set 'image_url', url
      @totem_messages.api_success(source: @, action: 'image_url', i18n_path: ns.to_o('artifact', 'file', 'image_loaded'))
    , (error) =>
      @set 'is_loading', false
