import ember from 'ember'

# Based on the ember-cli-i18n module's t.js handlebars helper.
class i18n

  constructor: ->
    @locale      = null
    @container   = null

  message: (options={}) ->
    @set_locale()
    template = @template(options)
    @format_message(template, options)

  format_message: (template, options) ->
    args    = ember.makeArray(options._i18n_args or [])
    message = template.fmt(args...)
    message = @humanize(message)  unless options.humanize == false
    message

  template:(options={}) ->
    path               = options.path
    template           = ember.get(@locale, path)  if path
    options._i18n_args = options.args             if template
    unless template
      default_path       = options.default_path
      template           = ember.get(@locale, default_path)  if default_path
      options._i18n_args = options.default_args              if template
    template = 'Missing i18n template'  unless template
    template

  humanize: (str) ->
    "#{str}".replace(/_/g, ' ').replace( /^\w/g, (s) -> s.toUpperCase() )

  set_locale: ->
    return if @locale?
    country_code  = @container.lookup('application:main').defaultLocale
    @locale       = @container.lookupFactory('locale:' + country_code)

  set_container: (container) -> @container = container

export default new i18n
