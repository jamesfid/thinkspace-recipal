import ember from 'ember'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  casespace: ember.inject.service()
  session:   ember.inject.service()

  model: -> @get_index_spaces()

  setupController: (controller, model) -> controller.set 'model', model

  renderTemplate: ->
    if @get('session.is_original_user')
      @get('casespace').set_current_models().then => @render()
    else
      @totem_messages.invalidate_session()

  refresh_spaces: -> 
    return unless ember.isPresent(@controller)
    @controller.set 'model', @get_index_spaces()

  get_index_spaces: ->
    spaces = @store.all @ns.to_p('space')
    # Filter out any new spaces that aren't unloaded in time by the decativate hook in spaces#new route.
    spaces = spaces.filter (space) => !space.get('isNew')
    spaces.sortBy 'title'
