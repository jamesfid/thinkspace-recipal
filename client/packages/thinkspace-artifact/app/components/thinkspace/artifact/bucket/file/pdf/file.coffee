import ember   from 'ember'
import config  from 'totem/config'
import {env}   from 'totem/config'
import ns      from 'totem/ns'
import ta      from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  tvo:    ember.inject.service()
  markup: ember.inject.service ns.to_p('markup', 'manager')

  # ### Properties
  rendered_canvases: []

  # ### Computed properties
  pdf_worker_src:    ember.computed -> "#{config.pdfjs.worker_src}"
  is_loading:        ember.computed.reads 'markup.is_pdf_loading'

  discussions: ember.computed 'totem_scope.ownerable_record', ->
    promise  = new ember.RSVP.Promise (resolve, reject) => 
      model  = @get 'model'
      markup = @get 'markup'
      discussions = @container.lookup('store:main').filter ns.to_p('markup', 'discussion'), (discussion) => 
        markup.discussion_has_discussionable(discussion, model) and markup.discussion_has_ownerable(discussion)
      resolve(discussions)
    ta.PromiseArray.create promise: promise

  discussions_sort_by: ['sort_by']
  sorted_discussions: ember.computed.sort 'discussions', 'discussions_sort_by'

  # Default the URL so that development can refer to the API host's file storage.
  defaulted_file_url: ember.computed 'file_url', ->
    url = @get('file_url')
    if env.environment == 'development'
      if url.includes('public/') # Relative asset path
        url = url.replace('public/', '')
        "#{config.api_host}/#{url}"
      else
        url
    else
      url
  
  # ### Observer
  show_file_change:  ember.observer 'show_file', -> @load_and_show_pdf()

  # ### Components
  c_loader:                            ns.to_p 'common', 'loader'
  c_markup_discussion_markers_default: ns.to_p 'markup', 'discussion', 'markers', 'default'

  didInsertElement:   -> @load_and_show_pdf()  # in case show_file is initially set as true (e.g. auto show files)
  willDestroyElement: -> @get('markup').reset_is_pdf()
  init: -> @_super(); console.log '[pdf:file] File component: ', @

  click: (e) ->
    # e.offsetX, e.offsetY is relative to each page of the PDF.
    # e.target is the <canvas> tag that is clicked.
    markup          = @get 'markup'
    return unless markup.get_is_comments_open()
    target    = e.target
    if target.tagName != 'CANVAS'
      @totem_messages.error 'You cannot create a new discussion on top of an existing discussion.'
      return
    page            = parseInt   e.target.getAttribute('page')
    value           = {position: {x: e.offsetX, y: e.offsetY, page: page}}
    discussionable  = @get 'model'
    library_comment = markup.get_selected_library_comment()
    discussionable.get('authable').then (authable) =>
      options = 
        value:          value
        authable:       authable
        ownerable:      @totem_scope.get_ownerable_record()
        creatorable:    @totem_scope.get_current_user()
        discussionable: discussionable
      options.save = true if library_comment # We want to persist the discussion since there will be no explicit comment save.
      markup.add_discussion(options).then (discussion) =>
        if library_comment
          options = 
            commenterable: @totem_scope.get_current_user()
            library_comment: library_comment
          markup.reset_selected_library_comment()
          markup.add_comment_to_discussion(discussion, options)
        else
          options = {commenterable: @totem_scope.get_current_user()}
          markup.add_comment_to_discussion_and_edit(discussion, options)


  get_$file_container: ->
    container_id = @get 'file_container_id'
    $('#' + container_id)

  load_and_show_pdf: ->
    return unless @get 'show_file'
    return if     @get 'is_loaded'
    model = @get 'model'
    # ID used to identify the container in the format of: artifact-file-pdf-container-#{artifact-model.id}
    # Get the div rendered by the template which is a container for the PDF renderer.
    $container = @get_$file_container()
    return if $container.length < 1  # if show_file is initially true, the show_file observer will call before the container is rendered (didInsertElement will re-call)
    width            = 960  # could set different if 'comment_section' is null
    PDFJS.disableWorker = true if env.environment == 'development' # Do not load worker for development, must be on same domain (e.g. included via Brocfile)
    PDFJS.workerSrc     = @get('pdf_worker_src')
    PDFJS.cMapUrl       = 'cmaps/'
    PDFJS.cMapPacked    = true
    
    @get('markup').set_is_pdf_loading()
    PDFJS.getDocument(@get 'defaulted_file_url').then (pdf) =>
      # Get the first page and setup rendering options.
      pdf.getPage(1).then (page) =>
        options =
          pdf:              pdf
          num_pages:        pdf.numPages
          num_current_page: 1
          container:        $container
          scale:            1
          width:            width
        @render_page(page, options)

  render_page: (page, options) ->
    # Create a canvas element and append it to the PDF container.
    # => Then, call this function again for each page.
    scale     = options.scale
    container = options.container
    num_pages = options.num_pages
    pdf       = options.pdf
    width     = options.width
    # Scale width to a given pixel size if specified.
    if width?
      viewport = page.getViewport(1)
      scale    = width / viewport.width
    viewport       = page.getViewport(scale)
    canvas         = $('<canvas></canvas>').attr('height', viewport.height).attr('width', viewport.width).attr('page', options.num_current_page)
    context        = canvas.get(0).getContext('2d') # getContext is a DOM object function, not a jQuery function.
    render_context = 
      canvasContext: context
      viewport:      viewport
    page.render(render_context)
    container.append(canvas)
    @get('rendered_canvases').pushObject(canvas)
    options.num_current_page += 1
    num_current_page          = options.num_current_page
    if num_current_page <= num_pages and pdf
      pdf.getPage(num_current_page).then (page) =>
        @render_page(page, options)
    else
      markup = @get 'markup'
      model  = @get 'model'
      markup.set_is_pdf()
      markup.set_is_pdf_loaded()
