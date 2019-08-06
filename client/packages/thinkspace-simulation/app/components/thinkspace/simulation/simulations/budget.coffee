import ember from 'ember'
import ds from 'ember-data'
import ns from 'totem/ns'
import default_prop_mixin from 'totem-application/mixins/default_property_settings'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend default_prop_mixin,
  
  budget_game:               null
  update_counter:             0

  bubble_update:              0
  next_bubble:                240

  hrs_elapsed:                0
  no_of_hrs:                  24

  sounds_complete: 0
  sound_count:     1
  volume_bar:      null
  muted:           false

  images_loaded: false
  sounds_loaded: false

  simulation_started:         false
  simulation_loaded:          false
  simulation_paused:          false
  simulation_concluded:       false
  sim_fps:                    60

  water_level:                20
  rate_of_inflow:             0
  rate_of_outflow:            1
  inflow:                     0
  max_inflow:                 10
  min_inflow:                 0

  listeners:                  []
  game_tick_listener:         null
  graph_update_listener:      null
  load_listener:              null
  load_update_counter:        0

  fill_class:                 'ts-rangeslider_fill'
  handle_class:               'ts-rangeslider_handle'
  range_class:                'ts-rangeslider'
  slider_background_template: "<div class='ts-rangeslider_background' />"

  water_start_x:              99
  water_start_y:              396
  water_full_y:               396
  water_empty_y:              636
  water_scale_x:              0.995
  water_size_coefficient:     null

  slider_step_size:           1.0

  image_preloader:            new createjs.LoadQueue(false)
  #load_image_preloader:       new createjs.LoadQueue(false)

  level_chart:                null
  rate_chart:                 null
  level_chart_data:           []
  rate_chart_data:            []
  default_level_chart_data:   [{"time":0,"full":20}]
  default_rate_chart_data:    [{"time":0,"inflow":0,"outflow":1}]

  inflow_controllable: ember.computed 'hrs_elapsed', ->
    @get('hrs_elapsed') < 7 and @get('hrs_elapsed') > 18

  default_property_settings: {
    level_chart:          null,
    rate_chart:           null,
    update_counter:       0,
    bubble_update:        0,
    next_bubble:          240,
    hrs_elapsed:          0,
    simulation_concluded: false,
    simulation_started:   false,
    water_level:          20,
    rate_of_inflow:       0,
    rate_of_outflow:      1,
    base_inflow:          0,
    load_listener:        null,
    level_chart_data:     {type:'array'},
    rate_chart_data:      {type:'array'},
    listeners:            {type:'array'}
  }

  muted_obs: ember.observer 'muted', ->
    if @get('muted')
      createjs.Sound.volume = 0
    else
      createjs.Sound.volume = @get('volume_bar').scaleY

  simulation_auto_pause: ember.observer 'simulation_paused', ->
    graph_update_listener = @get('graph_update_listener')
    budget_game = @get('budget_game')

    if @get('simulation_paused')
      createjs.Ticker.removeEventListener("tick", graph_update_listener)
    else
      createjs.Ticker.addEventListener("tick", graph_update_listener)

  hrs_elapsed_obs: ember.observer 'hrs_elapsed', ->
    hrs_elapsed = @get('hrs_elapsed')

    if hrs_elapsed == 6
      @set('simulation_paused', true)

    if hrs_elapsed == 24
      @set('simulation_concluded', true)
      @set('simulation_paused', true)

      createjs.Ticker.removeEventListener("tick", @get('graph_update_listener'))

  inflow_obs: ember.observer 'inflow', 'hrs_elapsed', ->
    inflow      = parseInt(@get('inflow'))
    hrs_elapsed = @get('hrs_elapsed')

    if hrs_elapsed < 6 or hrs_elapsed >= 18
      @set('rate_of_inflow', 0)
    else
      @set('rate_of_inflow', inflow)

  net_flow: ember.computed 'rate_of_inflow', 'rate_of_outflow', ->
    @get('rate_of_outflow') - @get('rate_of_inflow')

  slider_obs: ember.observer 'inflow', ->
    @$('input[id="inflow_slider"]').val(@get('inflow')).change()

  willDestroyElement: ->
    game_tick_listener = @get('game_tick_listener')

    budget_game     = @get('budget_game')
    image_preloader = @get('image_preloader')

    image_preloader.removeAllEventListeners()
    budget_game.removeAllEventListeners()
    @reset_properties_to_default()

    listeners = @get('listeners')
    listeners.forEach (listener) =>
      createjs.Ticker.removeEventListener("tick", listener)

    createjs.Ticker.removeAllEventListeners()
    createjs.Tween.removeAllTweens()

  handle_load: (event) ->
    @get('image_preloader').removeAllEventListeners()
    #@get('load_image_preloader').removeAllEventListeners()
    createjs.Ticker.removeEventListener("tick", @get('load_listener'))

    @set('images_loaded', true)


  sim_final_load: ember.observer 'sounds_loaded', 'images_loaded', ->
    if @get('sounds_loaded') and @get('images_loaded')
      load_text_container = @get('load_text_container')
      budget_game        = @get('budget_game')

      createjs.Tween.removeTweens(load_text_container)
      budget_game.removeChild(load_text_container)
      budget_game.alpha = 0

      @initialize_simulation()
      @set('simulation_loaded', true)

  timed_load: (event) ->
    load_update_counter = @get('load_update_counter')
    
    if load_update_counter == @get('sim_fps')
      image_queue   = @get('image_preloader')
      load_listener = @get('load_listener')

      createjs.Sound.alternateExtensions = ['mp3']
      createjs.Sound.registerPlugins([createjs.HTMLAudioPlugin])
      createjs.Sound.on('fileload', ((event) -> @handle_sound_load(event)).bind(@)) 


      ## Needed to ensure that if the sound is already preloaded we register the sim as loaded.
      if createjs.Sound.loadComplete('https://s3.amazonaws.com/thinkspace-prod/sounds/stream.mp3')
        @handle_sound_load('https://s3.amazonaws.com/thinkspace-prod/sounds/stream.mp3')

      createjs.Sound.registerSound('https://s3.amazonaws.com/thinkspace-prod/sounds/stream.mp3', 'water')

      image_queue.on("complete", ((event) -> @handle_load(event)).bind(@))

      image_queue.loadFile(new createjs.LoadItem().set({id: 'background',           src:'/assets/images/simulations/budget/fluidity-background.png',      crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'vat_outline',          src:'/assets/images/simulations/budget/fluidity-vat-outline_2.png',   crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'vat_base',             src:'/assets/images/simulations/budget/fluidity-vat-base.png',        crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'vat_background',       src:'/assets/images/simulations/budget/fluidity-vat-background.png',  crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'water_background',     src:'/assets/images/simulations/budget/fluidity-water-3.png',         crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'water_bubbles_light',  src:'/assets/images/simulations/budget/fluidity-bubbles-1.png',       crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'water_bubbles_dark',   src:'/assets/images/simulations/budget/fluidity-bubbles-2.png',       crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'vat_ticks',            src:'/assets/images/simulations/budget/fluidity_measuring-scale.png', crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'speaker',              src:'/assets/images/simulations/speaker.png',                         crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'speaker_mute',         src:'/assets/images/simulations/speaker-mute.png',                    crossOrigin: true}))
      image_queue.load()

      createjs.Ticker.removeEventListener("tick", load_listener)

    @set('load_update_counter', load_update_counter + 1)

  handle_sound_load: (event) ->
    sounds_complete = @get('sounds_complete') + 1
    if sounds_complete == @get('sound_count')
      createjs.Sound.removeAllEventListeners()
      @set('sounds_loaded', true)

    @set('sounds_complete', sounds_complete)

  initialize_load_screen: ->
    budget_game = @get('budget_game')
    budget_game.setBounds(0,0,700,400)

    load_text_container = new createjs.Container()

    #spaceship = new createjs.Bitmap(@get('load_image_preloader').getResult('spaceship'))
    dark_text = new createjs.Text('Arriving shortly!', '24px omnes-pro', '#63b4d6')
    dark_text.textAlign = 'center'

    #load_text_container.addChild(spaceship)
    load_text_container.addChild(dark_text)

    #dark_text.y = spaceship.getBounds().height + 10
    dark_text.x = load_text_container.getBounds().width / 2

    load_text_container.regY = load_text_container.getBounds().height / 2
    load_text_container.regX = load_text_container.getBounds().width / 2
    load_text_container.y = budget_game.getBounds().height / 2
    load_text_container.x = budget_game.getBounds().width / 2

    budget_game.addChild(load_text_container)

    createjs.Tween.get(load_text_container, {loop:true})
      .to({alpha: 0}, 1000)
      .to({alpha: 1}, 1000)

    @set('load_text_container', load_text_container)

    ## Listener for general stage updates.
    game_tick_listener = createjs.Ticker.addEventListener("tick", budget_game)
    @set('game_tick_listener', game_tick_listener)
    ## Listener for load.
    load_listener = createjs.Ticker.addEventListener("tick", ((event) -> @timed_load(event)).bind(@))
    @set('load_listener', load_listener)
    
    @initialize_graph()

    @$('input[id="inflow_slider"]').rangeslider
      polyfill:    false
      rangeClass:  @get 'range_class'
      fillClass:   @get 'fill_class'
      handleClass: @get 'handle_class'
      onInit: => @init_template()
      onSlideEnd:  (position, value) =>
        @set('inflow', value)
      onSlide: (position, value) =>
        @set('inflow', value)


  init_template: ->
    range_class = @get('range_class')
    template    = @get 'slider_background_template'
    $background = $(template)

    @$(".#{range_class}").prepend($background)

  didInsertElement: ->
    ## Need to set up the stage here so we can associate it with our template's canvas element
    @set('budget_game', new createjs.Stage('budget-sim-canvas'))

    createjs.Ticker.setFPS(@get('sim_fps'))
    createjs.Ticker.addEventListener('tick', createjs.Tween)

    canvas = document.getElementById('budget-sim-canvas')
    canvas.width = 700
    canvas.height = 400

    #load_image_preloader = @get('load_image_preloader')
    #load_image_preloader.on('complete', ((event) -> @initialize_load_screen()).bind(@))
    #load_image_preloader.loadFile(new createjs.LoadItem().set({id: 'spaceship',     crossOrigin: true, src:'/assets/images/loading-ship.png'}))
    
    #load_image_preloader.load()
    @initialize_load_screen()

  graph_update: (event) ->
    level_chart_data = @get('level_chart_data')
    rate_chart_data  = @get('rate_chart_data')
    rate_chart       = @get('rate_chart')
    level_chart      = @get('level_chart')
    budget_game      = @get('budget_game')
    rate_of_inflow   = @get('rate_of_inflow')
    rate_of_outflow  = @get('rate_of_outflow')
    water_level      = @get('water_level')
    update_counter   = @get('update_counter')

    ## We want the graph data points to be updated once every second...normalized against tick timing by event.delta
    if update_counter == @get('sim_fps')

      hrs_elapsed = @get('hrs_elapsed') + 1

      rate_chart_data.find(
        ((element) ->
          if element.time == hrs_elapsed
            element['inflow'] = rate_of_inflow
            rate_chart.validateData()
        )
      )

      level_chart_data.find(
        ((element) ->
          if element.time == hrs_elapsed
            element['full'] = @calculate_water_level()
            level_chart.validateData()
        ).bind(@)
      )

      water_level = @get('water_level')
      @add_translate_tween(budget_game.water, @get('net_flow'))

      createjs.Sound.play('water')

      update_counter = 0

    update_counter += 1

    @set('update_counter', update_counter)


  animate_bubbles: (event) ->
    water_bubbles_light = @get('water_bubbles_light')
    budget_game        = @get('budget_game')
    water_obj           = budget_game.water
    bubble_update       = @get('bubble_update')
    next_bubble         = @get('next_bubble')

    if bubble_update == next_bubble
      bubble_selector = Math.floor((Math.random() * 2) + 1)
      if bubble_selector == 1
        bubble = @get('water_bubbles_light')
      else
        bubble = @get('water_bubbles_dark')
      bubble.y = water_obj.y
      bubble.x = Math.floor((Math.random() * 200) + 200)
      bubble.alpha = .8

      createjs.Tween.get(bubble)
        .to({y:water_obj.y - (water_obj.getBounds().height - bubble.getBounds().height - Math.floor((Math.random() * 10) + 15))}, 2000)
        .to({alpha: 0}, 250)

      bubble_update = 0

      @set('next_bubble', Math.floor((Math.random() * 180) + 180))

    bubble_update += 1

    @set('bubble_update', bubble_update)

  increment_hrs: ->
    @set('hrs_elapsed', @get('hrs_elapsed') + 1)

  calculate_water_level: ->
    water_level     = @get('water_level')
    rate_of_inflow  = @get('rate_of_inflow')
    rate_of_outflow = @get('rate_of_outflow')
    net_flow        = @get('net_flow')

    water_level = water_level - net_flow
    
    if water_level < 0
      water_level = 0
    else if water_level > 100
      water_level = 100
    
    @set('water_level', water_level)

    water_level

  initialize_simulation: (is_reset) ->
    budget_game    = @get('budget_game')
    water_start_x   = @get('water_start_x')
    water_start_y   = @get('water_start_y')
    water_scale_x   = @get('water_scale_x')
    listeners       = @get('listeners')
    image_preloader = @get('image_preloader')

    water_full_y  = @get('water_full_y')
    water_empty_y = @get('water_empty_y')

    if is_reset == false
      bubble_animation_listener = createjs.Ticker.addEventListener("tick", ((event) -> @animate_bubbles(event)).bind(@))

      listeners.pushObject(bubble_animation_listener)

    vat_container = new createjs.Container()


    background          = new createjs.Bitmap(image_preloader.getResult('background'))
    vat_base            = new createjs.Bitmap(image_preloader.getResult('vat_base'))
    vat_background      = new createjs.Bitmap(image_preloader.getResult('vat_background'))
    vat_outline         = new createjs.Bitmap(image_preloader.getResult('vat_outline'))
    vat_ticks           = new createjs.Bitmap(image_preloader.getResult('vat_ticks'))
    water_background    = new createjs.Bitmap(image_preloader.getResult('water_background'))
    water_bubbles_light = new createjs.Bitmap(image_preloader.getResult('water_bubbles_light'))
    water_bubbles_dark  = new createjs.Bitmap(image_preloader.getResult('water_bubbles_dark'))

    water_bubbles_light.alpha = 0
    water_bubbles_dark.alpha  = 0

    vat_container.addChild(vat_background)
    vat_container.addChild(vat_outline)

    vat_container.regX = vat_container.getBounds().width / 2
    vat_container.regY = vat_container.getBounds().height / 2

    water_background_height = water_background.getBounds().height
    water_background.regY   = water_background_height
    water_background.scaleX = water_scale_x
    water_background.x      = water_start_x
    water_size_coefficient  = (water_empty_y - water_full_y) / 100

    water_background.y = water_start_y + (80 * water_size_coefficient)

    @set('water_size_coefficient', water_size_coefficient)

    vat_container.x = 350
    vat_container.y = 220

    vat_container.cache(0,0, vat_container.getBounds().width, vat_container.getBounds().height)
    background.cache(0,0,background.getBounds().width, background.getBounds().height)

    vat_ticks.regX = vat_ticks.getBounds().width
    vat_ticks.x    = 500
    vat_ticks.y    = 88

    vat_base.x = 88
    vat_base.y = 347

    @set('water_bubbles_light', water_bubbles_light)
    @set('water_bubbles_dark', water_bubbles_dark)

    budget_game.water = water_background

    budget_game.addChild(background)
    budget_game.addChild(vat_container)
    budget_game.addChild(water_background)
    budget_game.addChild(water_bubbles_light)
    budget_game.addChild(water_bubbles_dark)
    budget_game.addChild(vat_base)
    budget_game.addChild(vat_ticks)

    ## Need to initialize our mute button and volume bar. Bool is horizontal:true | vertical:false.
    @initialize_sound(budget_game, false)

    createjs.Tween.get(budget_game)
      .to({alpha: 1}, 1000)

  initialize_sound: (game, horizontal) ->
    game.enableMouseOver(10)

    sound_bar_container     = new createjs.Container()
    speaker_image_container = new createjs.Container()

    speaker_image            = new createjs.Bitmap(@get('image_preloader').getResult('speaker'))
    speaker_mute_image       = new createjs.Bitmap(@get('image_preloader').getResult('speaker_mute'))
    speaker_mute_image.alpha = 0
    speaker_mute_image.x     = -6

    background_graphic = new createjs.Graphics().beginFill("#000000").drawRect(0,0,10,100)
    foreground_graphic = new createjs.Graphics().beginFill("#FFFFFF").drawRect(0,0,10,100)

    background_bar = new createjs.Shape(background_graphic)
    foreground_bar = new createjs.Shape(foreground_graphic)

    background_bar.alpha = .7

    background_bar.regX = 10 / 2
    foreground_bar.regX = 10 / 2
    background_bar.regY = 100
    foreground_bar.regY = 100
    background_bar.x    = 13
    foreground_bar.x    = 13
    background_bar.y    = speaker_image.y - 10
    foreground_bar.y    = speaker_image.y - 10

    if horizontal?
      if horizontal
        background_bar.rotation = 90
        foreground_bar.rotation = 90

    speaker_image_container.addChild(speaker_image)
    speaker_image_container.addChild(speaker_mute_image)

    sound_bar_container.addChild(speaker_image_container)
    sound_bar_container.addChild(background_bar)
    sound_bar_container.addChild(foreground_bar)

    #game.addChild(hit_area)
    game.addChild(sound_bar_container)

    #hit_area.x = game.getBounds.width - (sound_bar_container.getBounds().width + 15)
    #hit_area.y = game.getBounds().height - (sound_bar_container.getBounds().height + 15)

    sound_bar_container.x = game.getBounds().width - (sound_bar_container.getBounds().width + 15)
    sound_bar_container.y = game.getBounds().height - (sound_bar_container.getBounds().height + 15)
    #sound_bar_container.hitArea = hit_area

    speaker_image_container.addEventListener('click', ((event) -> 
      @toggleProperty('muted')
      if @get('muted')
        speaker_image.alpha      = 0
        speaker_mute_image.alpha = 1
      else
        speaker_image.alpha      = 1
        speaker_mute_image.alpha = 0
    ).bind(@))

    sound_bar_container.addEventListener('rollover', ((event) ->
      createjs.Tween.get(sound_bar_container)
        .to({alpha: 0.9}, 250)
    ))

    sound_bar_container.addEventListener('rollout', ((event) ->
      createjs.Tween.get(sound_bar_container)
        .to({alpha: 0.3}, 250)
    ))

    foreground_bar.addEventListener('pressmove', ((event) ->
      foreground_top    = sound_bar_container.y
      foreground_bottom = sound_bar_container.y - 100

      foreground_bar.scaleY = (100 - (event.stageY - foreground_bottom)) / 100
      if foreground_bar.scaleY > 1
        foreground_bar.scaleY = 1

      if @get('muted') == false
        createjs.Sound.volume = foreground_bar.scaleY
    ).bind(@))

    background_bar.addEventListener('pressmove', ((event) ->
      foreground_top    = sound_bar_container.y
      foreground_bottom = sound_bar_container.y - 100

      foreground_bar.scaleY = (100 - (event.stageY - foreground_bottom)) / 100
      if foreground_bar.scaleY > 1
        foreground_bar.scaleY = 1

      if @get('muted') == false
        createjs.Sound.volume = foreground_bar.scaleY
    ).bind(@))

    foreground_bar.addEventListener('mousedown', ((event) ->
      foreground_top    = sound_bar_container.y
      foreground_bottom = sound_bar_container.y - 100

      foreground_bar.scaleY = (100 - (event.stageY - foreground_bottom)) / 100
      if foreground_bar.scaleY > 1
        foreground_bar.scaleY = 1

      if @get('muted') == false
        createjs.Sound.volume = foreground_bar.scaleY
    ).bind(@))

    background_bar.addEventListener('mousedown', ((event) ->
      foreground_top    = sound_bar_container.y
      foreground_bottom = sound_bar_container.y - 100
      foreground_bar.scaleY = (100 - (event.stageY - foreground_bottom)) / 100
      if foreground_bar.scaleY > 1
        foreground_bar.scaleY = 1

      if @get('muted') == false
        createjs.Sound.volume = foreground_bar.scaleY
    ).bind(@))

    sound_bar_container.alpha = .3
    @set('volume_bar', foreground_bar)

  initialize_graph: ->
    no_of_hrs        = @get('no_of_hrs')

    ## Need to slice in order to get value, not reference of array.
    default_rate_chart_data = @get('default_rate_chart_data').slice()
    default_level_chart_data = @get('default_level_chart_data').slice()

    @set('rate_chart_data', default_rate_chart_data)
    @set('level_chart_data', default_level_chart_data)

    rate_chart_data  = @get('rate_chart_data')
    level_chart_data = @get('level_chart_data')

    [1..no_of_hrs].forEach (number) =>
      new_rate_point  = {'time':number,'outflow': 1}
      new_level_point = {'time':number}

      rate_chart_data.pushObject(new_rate_point)
      level_chart_data.pushObject(new_level_point)

    level_chart = new AmCharts.AmSerialChart()
    rate_chart  = new AmCharts.AmSerialChart()

    level_chart.dataProvider    = level_chart_data
    level_chart.categoryField   = 'time'
    level_chart.categoryAxis    = {'title':'Time Elapsed (hrs)','titleFontSize': 14, 'titleBold': false,'autoGridCount':false,'gridCount':12, 'tickPosition':true,'startOnAxis':true}
    level_chart.valueAxes       = [{'id':'y-axis', 'titleFontSize': 14, 'titleBold': false,'title':'Water Level (L)', 'maximum':100, 'minimum':0, 'autoGridCount':false,'gridCount':10}]
    level_chart.fontFamily      = 'omnes-pro'
    level_chart.creditsPosition = 'top-left'

    rate_chart.dataProvider    = rate_chart_data
    rate_chart.categoryField   = 'time'
    rate_chart.categoryAxis    = {'title':'Time Elapsed (hrs)', 'titleFontSize': 14, 'titleBold': false,'tickPosition':true,'startOnAxis':true, 'autoGridCount':false,'gridCount':12}
    rate_chart.valueAxes       = [{'id':'y-axis', 'titleFontSize': 14, 'titleBold': false,'title': 'Flow Rate (L/hr)', 'maximum':10, 'minimum':0, 'autoGridCount':false, 'gridCount':10}]
    rate_chart.fontFamily      = 'omnes-pro'
    rate_chart.creditsPosition = 'top-left'

    level_graph = new AmCharts.AmGraph()
    rate_graph  = new AmCharts.AmGraph()
    drain_graph = new AmCharts.AmGraph()

    level_graph.type        = 'line'
    level_graph.valueField  = 'full'
    level_graph.bullet      = 'round'
    level_graph.balloonText = "[[category]] hrs, [[value]]L"
    level_graph.bulletSize  = 5
    level_graph.lineColor   = "#63b4d6"

    rate_graph.type         = 'line'
    rate_graph.valueField   = 'inflow'
    rate_graph.bullet       = 'round'
    rate_graph.bulletSize   = 5
    rate_graph.title        = 'Inflow'
    rate_graph.balloonText  = "[[value]]L/hr"
    rate_graph.lineColor    = "#63b4d6"

    drain_graph.type        = 'line'
    drain_graph.valueField  = 'outflow'
    drain_graph.title       = 'Outflow'
    drain_graph.lineColor   = '#dc0303'

    level_chart.addGraph(level_graph)
    rate_chart.addGraph(rate_graph)
    rate_chart.addGraph(drain_graph)

    @set('level_chart', level_chart)
    @set('rate_chart', rate_chart)

    level_chart.write('chart-column1')
    rate_chart.write('chart-column2')

  add_translate_tween: (budget_game_object, net_flow) ->
    water_start_y          = @get('water_start_y')
    water_empty_y          = @get('water_empty_y')
    water_size_coefficient = @get('water_size_coefficient')
    new_y                  = budget_game_object.y + (net_flow * water_size_coefficient)

    if new_y < water_start_y
      createjs.Tween.get(budget_game_object)
        .to({y:water_start_y}, 250)
    else if new_y > water_empty_y
      createjs.Tween.get(budget_game_object)
        .to({y:water_empty_y}, 250)
    else
      createjs.Tween.get(budget_game_object)
        .to({y:new_y}, 500)

    @increment_hrs()

  actions:
    step_slider: (bool) ->
      slider_step_size = @get('slider_step_size')
      inflow = @get('inflow')

      if bool
        max_inflow = @get('max_inflow')

        if inflow < max_inflow
          @set('inflow', inflow + slider_step_size)
      else
        min_inflow = @get('min_inflow')

        if inflow > min_inflow
          @set('inflow', inflow - slider_step_size)

    pause_simulation: ->
      if @get('simulation_concluded') == false
        @set('simulation_paused', true)

    resume_simulation: ->
      if @get('simulation_concluded') == false
        @set('simulation_paused', false)

    hour_forward: ->
      if @get('simulation_loaded')
        if @get('simulation_concluded') == false
          if @get('simulation_paused')
            @set('update_counter', @get('sim_fps'))

            @graph_update()

    start_simulation: ->
      simulation_loaded = @get('simulation_loaded')
      listeners         = @get('listeners')

      if simulation_loaded
        graph_update_listener = createjs.Ticker.addEventListener("tick", ((event) -> @graph_update(event)).bind(@))
        @set('graph_update_listener', graph_update_listener)
        listeners.pushObject(graph_update_listener)

        @set('simulation_started', true)

    reset_simulation: ->
      first_rate_point  = @get('default_rate_chart')
      first_level_point = @get('default_level_chart')
      simulation_loaded = @get('simulation_loaded')

      if simulation_loaded
        @reset_properties_to_default()

        rate_chart_data  = @get('rate_chart_data')
        level_chart_data = @get('level_chart_data')
        rate_chart       = @get('rate_chart')
        level_chart      = @get('level_chart')

        rate_chart_data.pushObject(first_rate_point)
        level_chart_data.pushObject(first_level_point)

        @initialize_simulation(true)
        @initialize_graph()