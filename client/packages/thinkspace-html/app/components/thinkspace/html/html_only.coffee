import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-html/components/base'

export default base.extend

  html: ember.computed -> @get('model.html_content').htmlSafe()