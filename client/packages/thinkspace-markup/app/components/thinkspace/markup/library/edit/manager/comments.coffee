import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  ## This component needed to enable scrolling for the comments in the library manager.
  comments:   null
  model:      null
  tagName:    ''
  remove_tag: null
  add_tag:    null

  ## Components
  c_library_comment: ns.to_p('markup', 'library', 'edit', 'manager', 'comment')

  actions: 
    remove_tag: (comment, tag) ->
      @sendAction('remove_tag', comment, tag)

    add_tag: (comment, tag) ->
      @sendAction('add_tag', comment, tag)