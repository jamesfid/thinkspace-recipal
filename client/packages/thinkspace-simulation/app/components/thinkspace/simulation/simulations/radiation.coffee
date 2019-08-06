import ember from 'ember'
import ds from 'ember-data'
import ns from 'totem/ns'
import default_prop_mixin from 'totem-application/mixins/default_property_settings'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend default_prop_mixin,
  
  c_list_btn: ember.computed ->
    ns.to_p('simulation', 'simulations', 'radiation', 'list-btn')

  radiation_game:       null

  plot_chart:           null
  plot_data:            []
  default_plot_data:    []

  update_counter:       0

  simulation_paused:    false
  simulation_concluded: false
  simulation_loaded:    false

  cur_surface:          'sand'
  cur_time_of_day:      'day'
  height_partitions:    20
  balloon_height_data:  []
  load_update_counter:  0
  load_text_container:  null
  cur_height:           null
  sim_ground_level:     350

  sim_fps: 60

  balloon_animate_counter: 0

  initial_plot_state:   null

  snow_day_obj:         null
  grass_day_obj:        null
  plowed_day_obj:       null
  sand_day_obj:         null
  snow_night_obj:       null
  plowed_night_obj:     null
  sand_night_obj:       null
  grass_night_obj:      null
  night_overlay_obj:    null
  balloon_obj:          null
  balloon_label_obj:    null

  snow_day_graph:     null
  snow_night_graph:   null
  grass_day_graph:    null
  grass_night_graph:  null
  sand_day_graph:     null
  sand_night_graph:   null
  plowed_day_graph:   null
  plowed_night_graph: null


  balloon_start_x:      250
  balloon_start_y:      305
  image_preloader:      new createjs.LoadQueue(false)
  #load_image_preloader: new createjs.LoadQueue(false)

  all_data: [ {pressure:1000,height:0,      sand_day:285,  plowed_day:283,  grass_day:281,  snow_day:273,  sand_night:278.4,plowed_night:276.4,grass_night:274.4,snow_night:268},
              {pressure:990, height:80.97,  sand_day:284.2,plowed_day:282.2,grass_day:280.2,snow_day:273.2,sand_night:278.5,plowed_night:276.5,grass_night:274.5,snow_night:270},
              {pressure:980, height:162.85, sand_day:283.4,plowed_day:281.4,grass_day:279.4,snow_day:273.4,sand_night:278.7,plowed_night:276.7,grass_night:274.7,snow_night:271.8},
              {pressure:970, height:245.69, sand_day:282.5,plowed_day:280.5,grass_day:278.6,snow_day:273.7,sand_night:278.8,plowed_night:276.8,grass_night:274.9,snow_night:273.2},
              {pressure:960, height:329.49, sand_day:281.7,plowed_day:279.7,grass_day:277.7,snow_day:274.6,sand_night:279.5,plowed_night:277.5,grass_night:275.5,snow_night:274.6},
              {pressure:950, height:414.25, sand_day:280.9,plowed_day:278.9,grass_day:276.9,snow_day:275.9,sand_night:280.1,plowed_night:278.1,grass_night:276.1,snow_night:275.9},
              {pressure:940, height:500,    sand_day:280,  plowed_day:278,  grass_day:276.8,snow_day:276.8,sand_night:280,  plowed_night:278,  grass_night:276.8,snow_night:276.8},
              {pressure:930, height:586.76, sand_day:279.2,plowed_day:277.2,grass_day:277.2,snow_day:277.2,sand_night:279.2,plowed_night:277.2,grass_night:277.2,snow_night:277.2},
              {pressure:920, height:674.49, sand_day:278.3,plowed_day:277,  grass_day:277,  snow_day:277,  sand_night:278.3,plowed_night:277,  grass_night:277,  snow_night:277},
              {pressure:910, height:763.12, sand_day:277.4,plowed_day:276.8,grass_day:276.8,snow_day:276.8,sand_night:277.4,plowed_night:276.8,grass_night:276.8,snow_night:276.8},
              {pressure:900, height:852.64, sand_day:276.5,plowed_day:276.5,grass_day:276.5,snow_day:276.5,sand_night:276.5,plowed_night:276.5,grass_night:276.5,snow_night:276.5},
              {pressure:890, height:942.95, sand_day:275.5,plowed_day:275.5,grass_day:275.5,snow_day:275.5,sand_night:275.2,plowed_night:276.2,grass_night:275.2,snow_night:275.5},
              {pressure:880, height:1034,   sand_day:274.8,plowed_day:274.8,grass_day:274.8,snow_day:274.8,sand_night:274.8,plowed_night:274.8,grass_night:274.8,snow_night:274.8},
              {pressure:870, height:1125.85,sand_day:274,  plowed_day:274,  grass_day:274,  snow_day:274,  sand_night:274,  plowed_night:274,  grass_night:274,  snow_night:274},
              {pressure:860, height:1218.44,sand_day:273,  plowed_day:273,  grass_day:273,  snow_day:273,  sand_night:273,  plowed_night:273,  grass_night:273,  snow_night:273},
              {pressure:850, height:1311.82,sand_day:272.2,plowed_day:272.2,grass_day:272.2,snow_day:272.2,sand_night:272.2,plowed_night:272.2,grass_night:272.2,snow_night:272.2},
              {pressure:840, height:1406,   sand_day:271.3,plowed_day:271.3,grass_day:271.3,snow_day:271.3,sand_night:271.3,plowed_night:271.3,grass_night:271.3,snow_night:271.3}]

  ## Original non-rounded heights.
  # height:0,
  # height:80.9705308,
  # height:162.852307,
  # height:245.694059,
  # height:329.485335,
  # height:414.246019,
  # height:499.996631,
  # height:586.758344,
  # height:674.4897,
  # height:763.115875,
  # height:852.640464,
  # height:942.952656,
  # height:1034.00407,
  # height:1125.84507,
  # height:1218.44313,
  # height:1311.81595,
  # height:1405.99922,

  default_property_settings: {
    update_counter:       null,
    simulation_paused:    false,
    simulation_concluded: false,
    default_plot_data:    {type:'array'}
  }

  balloon_text_update: ember.observer 'cur_height', ->
    cur_height    = @get('cur_height')
    balloon_label = @get('balloon_label_obj')

    balloon_label.text = cur_height.rounded_height + 'm'

  transition_obs: ember.observer 'cur_surface', 'cur_time_of_day', ->
    cur_surface     = @get('cur_surface')
    cur_time_of_day = @get('cur_time_of_day')

    old_background = @get('cur_background')
    cur_background = @get("#{cur_surface}_#{cur_time_of_day}_obj")

    @transition_background(old_background, cur_background)
    @set('cur_background', cur_background)

  willDestroyElement: ->
    @get('radiation_game').removeAllEventListeners()
    createjs.Ticker.removeAllEventListeners()
    createjs.Tween.removeAllTweens()

  didInsertElement: ->
    @set('radiation_game', new createjs.Stage('radiation-sim-canvas'))

    createjs.Ticker.setFPS(@get('sim_fps'))

    createjs.Ticker.addEventListener('tick', createjs.Tween)

    canvas = document.getElementById('radiation-sim-canvas')
    canvas.width = 700
    canvas.height = 400

    #load_image_preloader = @get('load_image_preloader')
    #load_image_preloader.on('complete', ((event) -> @initialize_load_screen()).bind(@))
    #load_image_preloader.loadFile(new createjs.LoadItem().set({id: 'spaceship',     crossOrigin: true, src:'/assets/images/loading-ship.png'}))
    
    #load_image_preloader.load()

    @initialize_load_screen()

  initialize_graph: ->
    plot_data = @get('default_plot_data').slice()
    all_data = @get('all_data')

    plot_chart = new AmCharts.AmXYChart()

    all_data.forEach (data_point) =>
      new_point = {'height':data_point.height}
      plot_data.pushObject(new_point)

    plot_data.reverse()

    ## Store the initial state of the graph, in order to make clearing plotted points easy.
    @set('initial_plot_state', plot_data)

    plot_chart.dataProvider          = plot_data
    plot_chart.valueAxes             = [{'id':'x-axis', 'titleFontSize': 14, 'titleBold': false,'position':'bottom','title':'Temperature (°F)', 'maximum':60, 'minimum':0, 'autoGridCount':false,'gridCount':10},
                                        {'id':'y-axis','titleFontSize': 14, 'titleBold': false,'title':'Altitude (m)','autoGridCount':false,'maximum':1500,'minimum':0,'gridCount':15}]
    plot_chart.fontFamily            = 'omnes-pro'
    plot_chart.creditsPosition       = 'top-left'
    plot_chart.legend                = {'useGraphSettings':true, 'position':'right'}
    plot_chart.mouseWheelZoomEnabled = true

    snow_day_graph     = new AmCharts.AmGraph()
    snow_night_graph   = new AmCharts.AmGraph()
    plowed_day_graph   = new AmCharts.AmGraph()
    plowed_night_graph = new AmCharts.AmGraph()
    sand_day_graph     = new AmCharts.AmGraph()
    sand_night_graph   = new AmCharts.AmGraph()
    grass_day_graph    = new AmCharts.AmGraph()
    grass_night_graph  = new AmCharts.AmGraph()

    sand_day_graph.type            = 'line'
    sand_day_graph.xField          = 'sand_day'
    sand_day_graph.yField          = 'height'
    sand_day_graph.bullet          = 'round'
    sand_day_graph.title           = 'Sand (Day)'
    sand_day_graph.balloonText     = "[[sand_day]] °F at [[height]]m"
    sand_day_graph.lineColor       = "#FF00FF"

    sand_night_graph.type          = 'line'
    sand_night_graph.xField        = 'sand_night'
    sand_night_graph.yField        = 'height'
    sand_night_graph.bullet        = 'square'
    sand_night_graph.title         = 'Sand (Night)'
    sand_night_graph.balloonText   = "[[sand_night]] °F at [[height]]m"
    sand_night_graph.lineColor     = "#FF0000"

    plowed_day_graph.type          = 'line'
    plowed_day_graph.xField        = 'plowed_day'
    plowed_day_graph.yField        = 'height'
    plowed_day_graph.bullet        = 'round'
    plowed_day_graph.title         = 'Plowed (Day)'
    plowed_day_graph.balloonText   = "[[plowed_day]] °F at [[height]]m"
    plowed_day_graph.lineColor     = "#FFBE82"

    plowed_night_graph.type        = 'line'
    plowed_night_graph.xField      = 'plowed_night'
    plowed_night_graph.yField      = 'height'
    plowed_night_graph.bullet      = 'square'
    plowed_night_graph.title       = 'Plowed (Night)'
    plowed_night_graph.balloonText = "[[plowed_night]] °F at [[height]]m"
    plowed_night_graph.lineColor   = "#A05000"

    grass_day_graph.type           = 'line'
    grass_day_graph.xField         = 'grass_day'
    grass_day_graph.yField         = 'height'
    grass_day_graph.bullet         = 'round'
    grass_day_graph.title          = 'Grass (Day)'
    grass_day_graph.balloonText    = "[[grass_day]] °F at [[height]]m"
    grass_day_graph.lineColor      = "#00FF00"

    grass_night_graph.type         = 'line'
    grass_night_graph.xField       = 'grass_night'
    grass_night_graph.yField       = 'height'
    grass_night_graph.bullet       = 'square'
    grass_night_graph.title        = 'Grass (Night)'
    grass_night_graph.balloonText  = "[[grass_night]] °F at [[height]]m"
    grass_night_graph.lineColor    = "#019646"

    snow_day_graph.type            = 'line'
    snow_day_graph.xField          = 'snow_day'
    snow_day_graph.yField          = 'height'
    snow_day_graph.bullet          = 'round'
    snow_day_graph.title           = 'Snow (Day)'
    snow_day_graph.balloonText     = "[[snow_day]] °F at [[height]]m"
    snow_day_graph.lineColor       = "#00FFFF"

    snow_night_graph.type          = 'line'
    snow_night_graph.xField        = 'snow_night'
    snow_night_graph.yField        = 'height'
    snow_night_graph.bullet        = 'square'
    snow_night_graph.title         = 'Snow (Night)'
    snow_night_graph.balloonText   = "[[snow_night]] °F at [[height]]m"
    snow_night_graph.lineColor     = "#0000FF"

    @set('sand_day_graph',     sand_day_graph)
    @set('sand_night_graph',   sand_night_graph)
    @set('plowed_day_graph',   plowed_day_graph)
    @set('plowed_night_graph', plowed_night_graph)
    @set('grass_day_graph',    grass_day_graph)
    @set('grass_night_graph',  grass_night_graph)
    @set('snow_day_graph',     snow_day_graph)
    @set('snow_night_graph',   snow_night_graph)
    
    plot_chart.addGraph(sand_day_graph)
    plot_chart.addGraph(sand_night_graph)
    plot_chart.addGraph(plowed_day_graph)
    plot_chart.addGraph(plowed_night_graph)
    plot_chart.addGraph(grass_day_graph)
    plot_chart.addGraph(grass_night_graph)
    plot_chart.addGraph(snow_day_graph)
    plot_chart.addGraph(snow_night_graph)

    @set('plot_data', plot_data)
    @set('plot_chart', plot_chart)

    plot_chart.write('chart-div')

  initialize_simulation: ->
    radiation_game      = @get('radiation_game')

    plot_data           = @get('plot_data')
    all_data            = @get('all_data')

    balloon_height_data = @get('balloon_height_data')
    balloon_start_y     = @get('balloon_start_y')
    balloon_start_x     = @get('balloon_start_x')
    cur_height          = @get('cur_height')

    image_preloader     = @get('image_preloader')

    sand_background         = new createjs.Bitmap(image_preloader.getResult('sand_day'))
    grass_background        = new createjs.Bitmap(image_preloader.getResult('grass_day'))
    plowed_background       = new createjs.Bitmap(image_preloader.getResult('plowed_day'))
    snow_background         = new createjs.Bitmap(image_preloader.getResult('snow_day'))
    sand_night_background   = new createjs.Bitmap(image_preloader.getResult('sand_night'))
    grass_night_background  = new createjs.Bitmap(image_preloader.getResult('grass_night'))
    plowed_night_background = new createjs.Bitmap(image_preloader.getResult('plowed_night'))
    snow_night_background   = new createjs.Bitmap(image_preloader.getResult('snow_night'))

    night_background = new createjs.Shape()
    
    sand_background.alpha         = 0
    night_background.alpha        = 0
    grass_background.alpha        = 0
    plowed_background.alpha       = 0
    snow_background.alpha         = 0
    grass_night_background.alpha  = 0
    plowed_night_background.alpha = 0
    snow_night_background.alpha   = 0
    sand_night_background.alpha   = 0
    
    balloon_container = new createjs.Container()

    balloon_text           = new createjs.Text('Height', '11px omnes-pro', '#FFFFFF')
    balloon_text.textAlign = 'center'
    balloon_text.y         = -15

    balloon      = new createjs.Bitmap(image_preloader.getResult('balloon'))
    balloon.regX = balloon.getBounds().width / 2
    balloon.regY = balloon.getBounds().height / 2

    balloon_container.addChild(balloon, balloon_text)
    balloon_container.on("pressmove", ((event) -> @translate_balloon(event)).bind(@))
    balloon_container.on("pressup", ((event) -> @balloon_release(event)).bind(@))
    #balloon_container.on("mousedown", ((event) -> @balloon_click(event)).bind(@))
    balloon_container.x = balloon_start_x
    balloon_container.y = balloon_start_y
    
    @set('balloon_obj', balloon_container)
    @set('balloon_label_obj', balloon_text)

    @set('sand_day_obj',     sand_background)
    @set('grass_day_obj',    grass_background)
    @set('plowed_day_obj',   plowed_background)
    @set('snow_day_obj',     snow_background)
    @set('sand_night_obj',   sand_night_background)
    @set('grass_night_obj',  grass_night_background)
    @set('plowed_night_obj', plowed_night_background)
    @set('snow_night_obj',   snow_night_background)

    radiation_game.addChild(sand_background)
    radiation_game.addChild(grass_background)
    radiation_game.addChild(plowed_background)
    radiation_game.addChild(snow_background)
    radiation_game.addChild(sand_night_background)
    radiation_game.addChild(plowed_night_background)
    radiation_game.addChild(snow_night_background)
    radiation_game.addChild(grass_night_background)

    radiation_game.addChild(balloon_container)

    ## Associate heights with a rounded height and a range of simulation y-coordinates
    canvas_height    = radiation_game.getBounds().height
    sim_ground_level = @get('sim_ground_level')

    range_value = canvas_height - (canvas_height - sim_ground_level + balloon_container.getBounds().height / 2)
    range_size  = range_value / @get('height_partitions')

    ## Need to associate the heights in all_data with a pixel range on our canvas element.
    all_data.forEach (data_point) =>
      new_data_point = {}
      new_data_point['height'] = data_point['height']
      if data_point['height'] - Math.floor(data_point['height']) < 0.5
        new_data_point['rounded_height'] = Math.floor(data_point['height'])
      else
        new_data_point['rounded_height'] = Math.ceil(data_point['height'])
      new_data_point['range_max'] = range_value
      range_value -= range_size
      new_data_point['range_min'] = range_value
      balloon_height_data.pushObject(new_data_point)

    balloon_height_data.find(
      ((element) ->
        if  balloon_start_y >= element['range_min'] and balloon_start_y < element['range_max']
          cur_height = element
      )
    )

    @set('cur_height', cur_height)

    ## Should allow us to make sure that any clicking done during load won't break the system.
    ## TODO: Add a disabled feature to our radio buttons.
    starting_surface     = @get('cur_surface')
    starting_time_of_day = @get('cur_time_of_day')

    start_background = @get("#{starting_surface}_#{starting_time_of_day}_obj")
    start_background.alpha = 1

    @set('cur_background', start_background)

    createjs.Tween.get(radiation_game)
      .to({alpha: 1}, 1000)

  ######## LOAD FUNCTIONS ########
  ## Called from didInsertElement hook. Uses 'image_preloader' to ensure simulation image assets are loaded, and animates via tween until load finishes.
  ## => initialize_load_screen()
  ## ===> Initializes canvas element loading animation, and creates 'tick' listener for timed_load
  ## => timed_load()
  ## ===> Waits for 120 ticks (~2 seconds at 60FPS) before starting load operation. Creates listener for load completion.
  ## => handle_load()
  ## ===> Cleans up load-related tweens and listeners, before calling 'initialize_simulation()'

  initialize_load_screen: ->
    radiation_game = @get('radiation_game')
    radiation_game.setBounds(0,0,700,400)

    load_text_container = new createjs.Container()

    #spaceship = new createjs.Bitmap(@get('load_image_preloader').getResult('spaceship'))
    dark_text = new createjs.Text('Arriving shortly!', '24px omnes-pro', '#63b4d6')
    dark_text.textAlign = 'center'

    #dark_text.regX = dark_text.getBounds().width / 2

    #load_text_container.addChild(spaceship)
    load_text_container.addChild(dark_text)
    
    #spaceship.regX = spaceship.getBounds().width / 2

    #dark_text.y = spaceship.getBounds().height + 10
    dark_text.x = load_text_container.getBounds().width / 2

    load_text_container.regY = load_text_container.getBounds().height / 2
    load_text_container.regX = load_text_container.getBounds().width / 2
    load_text_container.y    = radiation_game.getBounds().height / 2
    load_text_container.x    = radiation_game.getBounds().width / 2

    radiation_game.addChild(load_text_container)

    createjs.Tween.get(load_text_container, {loop:true})
      .to({alpha: 0}, 1000)
      .to({alpha: 1}, 1000)

    @set('load_text_container', load_text_container)

    ## Listener for general stage updates.
    game_tick_listener = createjs.Ticker.addEventListener("tick", radiation_game)
    @set('game_tick_listener', game_tick_listener)
    ## Listener for load.
    load_listener = createjs.Ticker.addEventListener("tick", ((event) -> @timed_load(event)).bind(@))
    @set('load_listener', load_listener)
    
    @initialize_graph()

  timed_load: (event) ->
    load_update_counter = @get('load_update_counter')

    if load_update_counter == @get('sim_fps')
      image_queue    = @get('image_preloader')
      load_listener  = @get('load_listener')

      image_queue.on("complete", ((event) -> @handle_load(event)).bind(@))

      image_queue.loadFile(new createjs.LoadItem().set({id: 'sand_day',     src: '/assets/images/simulations/radiation/sand-day.png',    crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'sand_night',   src: '/assets/images/simulations/radiation/sand-night.png',  crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'plowed_day',   src: '/assets/images/simulations/radiation/plow-day.png',    crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'plowed_night', src: '/assets/images/simulations/radiation/plow-night.png',  crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'grass_day',    src: '/assets/images/simulations/radiation/grass-day.png',   crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'grass_night',  src: '/assets/images/simulations/radiation/grass-night.png', crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'snow_day',     src: '/assets/images/simulations/radiation/snow-day.png',    crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'snow_night',   src: '/assets/images/simulations/radiation/snow-night.png',  crossOrigin: true}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'balloon',      src: '/assets/images/simulations/radiation/balloon.png',     crossOrigin: true}))
      
      image_queue.load()

      createjs.Ticker.removeEventListener("tick", load_listener)

    @set('load_update_counter', load_update_counter + 1)

  handle_load: (event) ->
    load_text_container  = @get('load_text_container')
    radiation_game       = @get('radiation_game')
    image_preloader      = @get('image_preloader')
    #load_image_preloader = @get('load_image_preloader')

    image_preloader.removeAllEventListeners()
    #load_image_preloader.removeAllEventListeners()

    createjs.Tween.removeTweens(load_text_container)
    createjs.Ticker.removeEventListener("tick", @get('load_listener'))

    radiation_game.removeChild(load_text_container)
    radiation_game.alpha = 0

    @initialize_simulation()
    @set('simulation_loaded', true)

  ######## END LOAD FUNCTIONS ########

  balloon_release: (event) ->
    balloon_obj = @get('balloon_obj')

    if @get('cur_height').height != 0
      balloon_tick_listener = balloon_obj.addEventListener('tick', ((event) -> @animate_balloon(event)).bind(@))
      @set('balloon_tick_listener', balloon_tick_listener)

  animate_balloon: (event) ->
    balloon_animate_counter = @get('balloon_animate_counter')

    if balloon_animate_counter == @get('sim_fps')
      createjs.Tween.get(event.target, {loop:true})
        .to({y:event.target.y + 5}, 1000)
        .to({y:event.target.y}, 1000)
        .to({y:event.target.y - 5}, 1000)
        .to({y:event.target.y}, 1000)

      @set('balloon_animate_counter', balloon_animate_counter + 1)

    if balloon_animate_counter < @get('sim_fps')
      balloon_animate_counter += 1

      @set('balloon_animate_counter', balloon_animate_counter)

  translate_balloon: (event) ->
    radiation_game      = @get('radiation_game')
    balloon             = @get('balloon_obj')
    cur_height          = @get('cur_height')
    balloon_height_data = @get('balloon_height_data')
    balloon_label       = @get('balloon_label_obj')
    sim_ground_level    = @get('sim_ground_level')

    if @get('balloon_tick_listener')
      @set('balloon_animate_counter', 0)
      balloon.removeEventListener('tick', @get('balloon_tick_listener'))
      createjs.Tween.removeTweens(balloon)

    if event.currentTarget.y > sim_ground_level
      event.currentTarget.y = sim_ground_level
    else
      event.currentTarget.y = event.stageY

      if balloon.y < cur_height['range_min'] or balloon.y >= cur_height['range_max']
        balloon_height_data.find(
          ((element) ->
            if balloon.y >= element.range_min and balloon.y < element.range_max
              cur_height = element
          )
        )

      @set('cur_height', cur_height)

  transition_background: (old_background, background) ->

    if old_background == background
      return false
    else
      createjs.Tween.get(old_background)
        .to({alpha:0}, 250)
        .call(->
          createjs.Tween.get(background)
            .to({alpha:1}, 250)
        )

  calculate_fahrenheit: (kelvin_temp) ->
    fahrenheit = (kelvin_temp * 1.8) - 459.67
    fahrenheit = parseFloat(fahrenheit.toFixed(2))
    return fahrenheit

  actions:
    reset_simulation: ->
      @initialize_simulation()
      @initialize_graph()

    select_time_of_day: (time_of_day) ->
      if time_of_day?
        @set('cur_time_of_day', time_of_day)

    select_background: (background) ->
      if background?
        @set('cur_surface', background)

    clear_graph: ->
      if @get('simulation_loaded')
        @set('plot_data', [])

        @initialize_graph()

    plot_point: ->
      if @get('simulation_loaded')
        plot_chart      = @get('plot_chart')
        cur_time_of_day = @get('cur_time_of_day')
        cur_surface     = @get('cur_surface')
        cur_height      = @get('cur_height')
        plot_data       = @get('plot_data')
        all_data        = @get('all_data')

        relevant_point = all_data.find(
          ((element) ->
            if cur_height.height == element.height
              return element
          )
        )

        switch cur_time_of_day
          when 'day'
            switch cur_surface
              when 'snow'
                plot_data.forEach (plot_point) =>
                  if plot_point.height == relevant_point.height
                    graph = @get('snow_day_graph')
                    #if plot_chart.graphs.get('lastObject') != graph
                    plot_chart.removeGraph(graph)
                    plot_chart.addGraph(graph)
                    plot_point['snow_day'] = @calculate_fahrenheit(relevant_point.snow_day)
                    plot_chart.validateData()
          
              when 'plowed'
                plot_data.forEach (plot_point) =>
                  if plot_point.height == relevant_point.height
                    graph = @get('plowed_day_graph')
                    #if plot_chart.graphs.get('lastObject') != graph
                    plot_chart.removeGraph(graph)
                    plot_chart.addGraph(graph)
                    plot_point['plowed_day'] = @calculate_fahrenheit(relevant_point.plowed_day)
                    plot_chart.validateData()
                
              when 'sand'
                plot_data.forEach (plot_point) =>
                  if plot_point.height == relevant_point.height
                    graph = @get('sand_day_graph')
                    #if plot_chart.graphs.get('lastObject') != graph
                    plot_chart.removeGraph(graph)
                    plot_chart.addGraph(graph)
                    plot_point['sand_day'] = @calculate_fahrenheit(relevant_point.sand_day)
                    plot_chart.validateData()
                
              when 'grass'
                plot_data.forEach (plot_point) =>
                  if plot_point.height == relevant_point.height
                    graph = @get('grass_day_graph')
                    #if plot_chart.graphs.get('lastObject') != graph
                    plot_chart.removeGraph(graph)
                    plot_chart.addGraph(graph)
                    plot_point['grass_day'] = @calculate_fahrenheit(relevant_point.grass_day)
                    plot_chart.validateData()

          when 'night'
            switch cur_surface
              when 'snow'
                plot_data.forEach (plot_point) =>
                  if plot_point.height == relevant_point.height
                    graph = @get('snow_night_graph')
                    #console.log('graph is ', graph)
                    #console.log('last_graph is ', plot_chart.graphs.get('lastObject'))
                    #if plot_chart.graphs.get('lastObject') != graph
                    plot_chart.removeGraph(graph)
                    plot_chart.addGraph(graph)
                    plot_point['snow_night'] = @calculate_fahrenheit(relevant_point.snow_night)
                    plot_chart.validateData()

              when 'plowed'
                plot_data.forEach (plot_point) =>
                  if plot_point.height == relevant_point.height
                    graph = @get('plowed_night_graph')
                    #if plot_chart.graphs.get('lastObject') != graph
                    plot_chart.removeGraph(graph)
                    plot_chart.addGraph(graph)
                    plot_point['plowed_night'] = @calculate_fahrenheit(relevant_point.plowed_night)
                    plot_chart.validateData()

              when 'sand'
                plot_data.forEach (plot_point) =>
                  if plot_point.height == relevant_point.height
                    graph = @get('sand_night_graph')
                    #if plot_chart.graphs.get('lastObject') != graph
                    plot_chart.removeGraph(graph)
                    plot_chart.addGraph(graph)
                    plot_point['sand_night'] = @calculate_fahrenheit(relevant_point.sand_night)
                    plot_chart.validateData()

              when 'grass'
                plot_data.forEach (plot_point) =>
                  if plot_point.height == relevant_point.height
                    graph = @get('grass_night_graph')
                    #if plot_chart.graphs.get('lastObject') != graph
                    plot_chart.removeGraph(graph)
                    plot_chart.addGraph(graph)
                    plot_point['grass_night'] = @calculate_fahrenheit(relevant_point.grass_night)
                    plot_chart.validateData()