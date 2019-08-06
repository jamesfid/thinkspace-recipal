import ember          from 'ember'
import ns             from 'totem/ns'
import totem_scope    from 'totem/scope'
import ajax           from 'totem/ajax'

totem_image_module = ember.Object.extend

  cache: null

  init: -> @clear()

  clear: -> @cache = {}

  url: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      id    = options.id or (options.model and options.model.get('id'))
      query =
        verb:   'get'
        action: 'image_url'
        id:     id
      @get_image_url(query).then (url) =>
        resolve(url)
      , (error) =>
        reject(error)

  carry_forward_url: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      from_phase = options.from_phase
      is_expert  = options.is_expert || false
      action     = (is_expert and 'carry_forward_expert_image_url') or 'carry_forward_image_url'
      query =
        verb:      'post'
        action:    action
        is_expert: is_expert
        data:      {from_phase}
      @get_image_url(query).then (url) =>
        resolve(url)
      , (error) =>
        reject(error)

  revoke_url: (url)  ->
    return if ember.isBlank(url)
    cache = @get_cache()
    for key, cache_url of cache
      if cache_url == url
        delete(cache[key])

  revoke_phase_url: (options={}) ->
    cache     = @get_cache()
    cache_key = @get_phase_cache_key(options)
    url       = cache[cache_key]
    return if ember.isBlank(url)
    delete(cache[cache_key])

  # private

  get_image_url: (query) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query.data  ?= {}
      query.model ?= ns.to_p 'artifact', 'file'
      totem_scope.add_ownerable_to_query(query.data)
      totem_scope.add_authable_to_query(query.data)
      @get_query_image_phase_id(query).then (phase_id) =>
        return reject("Image phase 'id' is blank.") if ember.isBlank(phase_id)
        cache_key = @get_phase_cache_key(phase_id: phase_id, is_expert: query.is_expert)
        cache_url = @get_cache_url(cache_key)
        return resolve(cache_url) if ember.isPresent(cache_url)
        ajax.object(query).then (json) =>
          return resolve(null) if ember.isBlank(json)
          url = json.url
          return resolve(null) if ember.isBlank(url)
          @set_cache_url(cache_key, url)
          resolve(url)
        , (error) =>
          reject(error)
      , (error) =>
        reject(error)

  get_phase_cache_key: (options={}) ->
    cache_key =
      phase_id:       options.phase_id  or totem_scope.get_authable_id()
      is_expert:      options.is_expert or false
      ownerable_id:   totem_scope.get_ownerable_id()
      ownerable_type: totem_scope.get_ownerable_type()
    ajax.stringify(cache_key)

  get_query_image_phase_id: (query) ->
    new ember.RSVP.Promise (resolve, reject) =>
      authable_id = query.data.auth.authable_id
      if ember.isBlank(query.id)
        from_phase = query.data.from_phase
        return reject("Image carry forward 'from_phase' is blank.") if ember.isBlank(from_phase)
        switch
          when from_phase == 'prev'
            index = -1
          when from_phase.match(/^prev-\d+$/)
            index = Number(from_phase.split('-', 2)[1]) * -1
          when from_phase.match(/^\d+$/)
            return resolve(from_phase)
          else
            return reject("Image carry forward [from_phase: #{from_phase}] is unknown.")
        @tc.find_record(ns.to_p('phase'), authable_id).then (phase) =>
          assignment    = phase.get('assignment')
          phases        = assignment.get('phases')
          phases        = phases.filter (p) => p.get('is_not_archived') or !p.get('is_inactive')
          current_index = phases.indexOf(phase)
          find_index    = current_index + index
          cf_phase      = phases.objectAt(find_index)
          return reject("Image carry forward phase for [from_phase: #{from_phase}] is blank.") if ember.isBlank(cf_phase)
          id = cf_phase.get('id')
          query.data.from_phase = id
          resolve(id)
      else
        resolve(authable_id)

  get_cache_url: (key)      -> @get_cache()[key]
  set_cache_url: (key, url) -> @get_cache()[key] = url

  get_cache: -> @get('cache') || {}

export default totem_image_module
