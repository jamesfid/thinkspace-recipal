import ember  from 'ember'
import config from 'totem/config'
import reqm   from 'totem/config/require_modules'

class TotemLocales

  process: (container) ->
    locales = config.locales
    @error "No ember application locals defined in environment 'totem.locals'."  if ember.isBlank(locales)
    for code in locales
      base = @base_local_for_code(code)
      @error "No base local exists for code '#{code}'."  if ember.isBlank(base)
      regex = reqm.config_regex("locales/#{code}")
      mods  = reqm.filter_by(regex)
      for mod in mods
        hash = reqm.require_module(mod)
        @error "Module '#{mod}' is not a hash."  unless reqm.is_hash(hash)
        # Using jquery deep merge of addon into base locale instead of a ember.merge.
        # Allows adding totem locales in the addon and suppress ember-cli-i18n
        # test error unless the addon has a 'totem' key.
        $.extend(true, base, hash)

  base_local_for_code: (code) -> reqm.require_module(reqm.app_path "locales/#{code}")

  error: (message='') -> reqm.error(@, message)

  toString: -> 'TotemLocales'

export default new TotemLocales
