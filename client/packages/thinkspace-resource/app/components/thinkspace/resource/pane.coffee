import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  t_pane_actions: ns.to_t 'resource', 'pane', 'actions'

  c_manage_files: ns.to_p 'resource', 'manage', 'files'
  c_manage_links: ns.to_p 'resource', 'manage', 'links'
  c_manage_tags:  ns.to_p 'resource', 'manage', 'tags'

  c_pane_file:    ns.to_p 'resource', 'pane', 'file'
  c_pane_link:    ns.to_p 'resource', 'pane', 'link'

  manage_files_expanded: false
  manage_links_expanded: false
  manage_tags_expanded:  false

  actions:
    close: -> @sendAction 'close'

    toggle_files_pane: ->
      if @toggleProperty('manage_files_expanded')
        @send 'close_links_pane'
        @send 'close_tags_pane'

    toggle_links_pane: ->
      if @toggleProperty('manage_links_expanded')
        @send 'close_files_pane'
        @send 'close_tags_pane'

    toggle_tags_pane: ->
      if @toggleProperty('manage_tags_expanded')
        @send 'close_files_pane'
        @send 'close_links_pane'

    close_files_pane: -> @set('manage_files_expanded', false)
    close_links_pane: -> @set('manage_links_expanded', false)
    close_tags_pane:  -> @set('manage_tags_expanded',  false)

