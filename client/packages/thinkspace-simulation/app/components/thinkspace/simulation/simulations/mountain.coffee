import ember from 'ember'
import ds from 'ember-data'
import ns from 'totem/ns'
import default_prop_mixin from 'totem-application/mixins/default_property_settings'
import base_component from 'thinkspace-base/components/base'
# import default_prop_mixin from 'cnc-base/mixins/default_property_settings'
# import validations from 'totem/mixins/validations'

export default base_component.extend default_prop_mixin,
  ## Components
  c_result: ns.to_p('simulation', 'simulations', 'mountain', 'result')
  
  simulation_loaded: false

  ## Flag to update our graph dynamically.
  dynamic_graphing: false

  mountain_game:  null
  leaf_obj:       null
  update_counter: 0
  sim_fps:        60

  trial_num: 0

  ## Attributes for calculations as the simulation runs.
  wind_speed:     0
  parcel_temp:    0

  cur_altitude:  0
  cur_temp:      0
  cur_humidity:  0
  cur_pressure:  0
  cur_dew_point: 0

  start_temp:     25
  start_humidity: 10.0
  start_pressure: 1000

  #sun_center:            null
  #sun_rings:             []
  sun_scale_coefficient: 0.2
  sun_ring_toggle:       false

  fill_class:     'ts-rangeslider_fill'
  handle_class:   'ts-rangeslider_handle'
  range_class:    'ts-rangeslider'

  ## Number of pixels the leaf will traverse in x and y directions on each sim tick
  x_step_size: 2
  y_step_size: 2

  ## Starting x coordinate for our leaf. The starting y coordinate will always correspond to 'ground_level'
  leaf_start_x:     50
  sim_ground_level: 350
  sim_peak:         65
  canvas_midpoint:  340

  ## Needed to enable the concept of bounds for user-input sliders.
  start_temp_max:     30.0
  start_temp_min:     -20.0
  start_humidity_max: 42.5
  start_humidity_min: 3.0

  sim_altitude_max: 2.5
  sim_altitude_min: 0

  slider_step_size: 0.1

  volume_bar:      null
  sound_count:     2
  sounds_complete: 0
  muted:           false

  factor: 10

  image_preloader:      new createjs.LoadQueue(false)
  #load_image_preloader: new createjs.LoadQueue(false)

  game_tick_listener:  null
  sim_update_listener: null
  load_listener:       null
  load_text_container: null

  load_update_counter: 0
 
  sim_running: false
  cloud_base:  'Clear'

  night_overlay_obj: null

  ## Easy-access graph min-max data, so we don't graph points that are out of bounds.
  graph_altitude_max: 5
  graph_altitude_min: 0
  graph_temp_max:     30
  graph_temp_min:     -20
  graph_humidity_max: 50
  graph_humidity_min: 0.1

  humidity_output: 0.1
  temp_output:     0.0

  next_cloud_y:        350
  cloud_height:        45
  base_cloud_array:    []
  leaf_cloud_array:    []
  cloud_array:         []
  cloud_base_y:        null
  first_cloud:         null
  rain_array:          []
  rain_update_counter: 0
  rain_update_target:  5

  slider_background_template: "<div class='ts-rangeslider_background' />"

  default_altitude_chart_data: [{'temp': 0, 'altitude':0}]
  default_humidity_chart_data: [{'start_temp':25, 'start_humidity':10, 'customBullet':'/assets/images/simulations/mountain/rect_leaf.png'},{'temp':-20,'phase_line_vapor_humidity':1.222945649168197},{'temp':-19.5,'phase_line_vapor_humidity':1.277495908928843},{'temp':-19,'phase_line_vapor_humidity':1.3342078551627543},
                        {'temp':-18.5,'phase_line_vapor_humidity':1.3931558368273866},{'temp':-18,'phase_line_vapor_humidity':1.4544163427835477},{'temp':-17.5,'phase_line_vapor_humidity':1.51806805004944},
                        {'temp':-17,'phase_line_vapor_humidity':1.5841918727839308},{'temp':-16.5,'phase_line_vapor_humidity':1.652871012002036},{'temp':-16,'phase_line_vapor_humidity':1.7241910060256844},
                        {'temp':-15.5,'phase_line_vapor_humidity':1.79823978167263},{'temp':-15,'phase_line_vapor_humidity':1.8751077061862296},{'temp':-14.5,'phase_line_vapor_humidity':1.9548876399086634},
                        {'temp':-14,'phase_line_vapor_humidity':2.037674989700097},{'temp':-13.5,'phase_line_vapor_humidity':2.123567763106011},{'temp':-13,'phase_line_vapor_humidity':2.212666623274969},
                        {'temp':-12.5,'phase_line_vapor_humidity':2.305074944628757},{'temp':-12,'phase_line_vapor_humidity':2.400898869286813},{'temp':-11.5,'phase_line_vapor_humidity':2.500247364246667},
                        {'temp':-11,'phase_line_vapor_humidity':2.603232279321993},{'temp':-10.5,'phase_line_vapor_humidity':2.709968405839659},{'temp':-10,'phase_line_vapor_humidity':2.8205735360971143},
                        {'temp':-9.5,'phase_line_vapor_humidity':2.935168523581191},{'temp':-9,'phase_line_vapor_humidity':3.05387734394933},{'temp':-8.5,'phase_line_vapor_humidity':3.1768271567740776},
                        {'temp':-8,'phase_line_vapor_humidity':3.3041483680514574},{'temp':-7.5,'phase_line_vapor_humidity':3.4359746934737885},{'temp':-7,'phase_line_vapor_humidity':3.572443222467293},
                        {'temp':-6.5,'phase_line_vapor_humidity':3.713694482994712},{'temp':-6,'phase_line_vapor_humidity':3.859872507122967},{'temp':-5.5,'phase_line_vapor_humidity':4.01112489735568},
                        {'temp':-5,'phase_line_vapor_humidity':4.16760289373051},{'temp':-4.5,'phase_line_vapor_humidity':4.3294614416805395},{'temp':-4,'phase_line_vapor_humidity':4.496859260659482},
                        {'temp':-3.5,'phase_line_vapor_humidity':4.669958913529648},{'temp':-3,'phase_line_vapor_humidity':4.848926876712026},{'temp':-2.5,'phase_line_vapor_humidity':5.033933611097255},
                        {'temp':-2,'phase_line_vapor_humidity':5.2251536337162285},{'temp':-1.5,'phase_line_vapor_humidity':5.42276559016919},{'temp':-1,'phase_line_vapor_humidity':5.626952327811398},
                        {'temp':-0.5,'phase_line_vapor_humidity':5.837900969694071},{'temp':0,'phase_line_vapor_humidity':6.055802989258314},{'temp':0.5,'phase_line_vapor_humidity':6.280854285780446},
                        {'temp':1,'phase_line_vapor_humidity':6.513255260566105},{'temp':1.5,'phase_line_vapor_humidity':6.753210893891136},{'temp':2,'phase_line_vapor_humidity':7.000930822686538},
                        {'temp':2.5,'phase_line_vapor_humidity':7.256629418964895},{'temp':3,'phase_line_vapor_humidity':7.520525868985428},{'temp':3.5,'phase_line_vapor_humidity':7.792844253154714},
                        {'temp':4,'phase_line_vapor_humidity':8.073813626659913},{'temp':4.5,'phase_line_vapor_humidity':8.363668100831166},{'temp':5,'phase_line_vapor_humidity':8.662646925229787},
                        {'temp':5.5,'phase_line_vapor_humidity':8.970994570458526},{'temp':6,'phase_line_vapor_humidity':9.288960811690254},{'temp':6.5,'phase_line_vapor_humidity':9.61680081291103},
                        {'temp':7,'phase_line_vapor_humidity':9.954775211873493},{'temp':7.5,'phase_line_vapor_humidity':10.303150205756438},{'temp':8,'phase_line_vapor_humidity':10.662197637526125},
                        {'temp':8.5,'phase_line_vapor_humidity':11.032195082994555},{'temp':9,'phase_line_vapor_humidity':11.413425938570565},{'temp':9.5,'phase_line_vapor_humidity':11.806179509698287},
                        {'temp':10,'phase_line_vapor_humidity':12.210751099978435},{'temp':10.5,'phase_line_vapor_humidity':12.627442100966872},{'temp':11,'phase_line_vapor_humidity':13.056560082645785},
                        {'temp':11.5,'phase_line_vapor_humidity':13.498418884561259},{'temp':12,'phase_line_vapor_humidity':13.953338707622153},{'temp':12.5,'phase_line_vapor_humidity':14.421646206554753},
                        {'temp':13,'phase_line_vapor_humidity':14.903674583006461},{'temp':13.5,'phase_line_vapor_humidity':15.399763679293798},{'temp':14,'phase_line_vapor_humidity':15.910260072787176},
                        {'temp':14.5,'phase_line_vapor_humidity':16.43551717092745},{'temp':15,'phase_line_vapor_humidity':16.97589530686672},{'temp':15.5,'phase_line_vapor_humidity':17.531761835727696},
                        {'temp':16,'phase_line_vapor_humidity':18.103491231474482},{'temp':16.5,'phase_line_vapor_humidity':18.691465184387702},{'temp':17,'phase_line_vapor_humidity':19.29607269913806},
                        {'temp':17.5,'phase_line_vapor_humidity':19.917710193449725},{'temp':18,'phase_line_vapor_humidity':20.556781597347648},{'temp':18.5,'phase_line_vapor_humidity':21.213698452980985},
                        {'temp':19,'phase_line_vapor_humidity':21.888880015014692},{'temp':19.5,'phase_line_vapor_humidity':22.582753351582785},{'temp':20,'phase_line_vapor_humidity':23.295753445794162},
                        {'temp':20.5,'phase_line_vapor_humidity':24.02832329778478},{'temp':21,'phase_line_vapor_humidity':24.780914027306498},{'temp':21.5,'phase_line_vapor_humidity':25.553984976846152},
                        {'temp':22,'phase_line_vapor_humidity':26.348003815265415},{'temp':22.5,'phase_line_vapor_humidity':27.163446641953918},{'temp':23,'phase_line_vapor_humidity':28.000798091486978},
                        {'temp':23.5,'phase_line_vapor_humidity':28.86055143877933},{'temp':24,'phase_line_vapor_humidity':29.743208704726253},{'temp':24.5,'phase_line_vapor_humidity':30.64928076232403},
                        {'temp':25,'phase_line_vapor_humidity':31.579287443259478},{'temp':25.5,'phase_line_vapor_humidity':32.53375764496122},{'temp':26,'phase_line_vapor_humidity':33.51322943810272},
                        {'temp':26.5,'phase_line_vapor_humidity':34.518250174548065},{'temp':27,'phase_line_vapor_humidity':35.54937659573159},{'temp':27.5,'phase_line_vapor_humidity':36.607174941461906},
                        {'temp':28,'phase_line_vapor_humidity':37.69222105914062},{'temp':28.5,'phase_line_vapor_humidity':38.80510051338682},{'temp':29,'phase_line_vapor_humidity':39.946408696057574},
                        {'temp':29.5,'phase_line_vapor_humidity':41.11675093665394},{'temp':30,'phase_line_vapor_humidity':42.316742613104566}]

  humidity_chart_data: null
  altitude_chart_data: null
  ## Used to record all the steps made, even if they are outside the bounds of the graph.
  chart_step_data: []
  trial_results:   []

  ## Used to contain the data for the trial we're currently running in between it's beginning and conclusion.
  cur_trial_data: {}

  humidity_chart: null
  altitude_chart: null

  sim_started: false
  sim_paused:  false

  sounds_loaded: false
  images_loaded: false

  ## Can't randomize our graph colors, because we inevitably end up with an invisible white graph.
  valid_graph_colors: ['#82c2ee','#94cb8a','#fb6b6b','#fcb725','#285cc9']

  default_property_settings: {
    update_counter:      0,
    rain_update_counter: 0,
    wind_speed:          0,
    cur_altitude:        0,
    cur_temp:            0,
    cur_humidity:        0,
    cur_dew_point:       0,
    start_temp:          25,
    start_humidity:      10.0,
    start_pressure:      1000,
    start_temp_max:      30.0,
    start_temp_min:      -20.0,
    start_humidity_max:  42.5,
    start_humidity_min:  0,
    factor:              10,
    sim_running:         false,
    sim_started:         false,
    cloud_base:          'Clear',
    first_cloud:         null,
    next_cloud_y:        350,
    cur_trial_data:      {},
    base_cloud_array:    {type:'array'},
    cloud_array:         {type:'array'}
  }

  display_altitude: ember.computed 'cur_altitude', ->
    if @get('cur_altitude').toFixed(1) < 0
      return 0.00
    else
      return @get('cur_altitude').toFixed(1)

  display_dew_point: ember.computed 'cur_dew_point', ->
    return @get('cur_dew_point').toFixed(1)

  display_humidity: ember.computed 'cur_humidity', 'start_humidity', ->
    if @get('sim_started')
      return @get('cur_humidity').toFixed(1)
    else
      return @get('start_humidity').toFixed(1)

  display_pressure: ember.computed 'cur_pressure', ->
    return @get('cur_pressure').toFixed(1)

  display_temp: ember.computed 'cur_temp', 'start_temp', ->
    if @get('sim_started')
      return @get('cur_temp').toFixed(1)
    else
      return @get('start_temp').toFixed(1)

  display_cloud_base: ember.computed 'cloud_base', ->
    cloud_base = @get('cloud_base')

    if cloud_base == 'Clear'
      return cloud_base
    else
      return cloud_base.toFixed(1) + ' km'

  need_reset: ember.computed 'sim_running', 'sim_started', ->
    sim_running = @get('sim_running')
    sim_started = @get('sim_started')

    if sim_running
      @set('sim_started', true)
      return false
    else
      if sim_started
        return true

  sim_final_load: ember.observer 'sounds_loaded', 'images_loaded', ->
    if @get('sounds_loaded') and @get('images_loaded')
      load_text_container = @get('load_text_container')
      mountain_game       = @get('mountain_game')

      createjs.Tween.removeTweens(load_text_container)
      mountain_game.removeChild(load_text_container)
      mountain_game.alpha = 0

      @initialize_simulation()
      @set('simulation_loaded', true)

  next_graph_color: ember.computed 'trial_num', ->
    trial_num = @get('trial_num')
    valid_graph_colors = @get('valid_graph_colors')

    index = trial_num % valid_graph_colors.length

    return valid_graph_colors[index]

  animation_obs: ember.observer 'sim_running', ->
    leaf_obj = @get('leaf_obj')

    if @get('sim_running')
      leaf_obj.play()
    else
      leaf_obj.stop()

  temp_slider_obs: ember.observer 'start_temp', ->
    @$('input[id="temp_slider"]').val(@get('start_temp')).change()

  humidity_slider_obs: ember.observer 'start_humidity', ->
    @$('input[id="humidity_slider"]').val(@get('start_humidity')).change()

  ## Determines the change in altitude for each tick of our simulation
  ## May be an issue in the event that a browser is resized?
  alt_per_step: ember.computed 'x_step_size', 'canvas_midpoint', 'leaf_start_x', ->
    canvas_midpoint  = @get('canvas_midpoint')
    leaf_start_x     = @get('leaf_start_x')
    x_step_size      = @get('x_step_size')
    sim_altitude_max = @get('sim_altitude_max')
    sim_altitude_min = @get('sim_altitude_min')

    ## Calculate the number of steps we'll be able to take before we start reducing altitude again.
    y_steps = (canvas_midpoint - leaf_start_x) / x_step_size

    ## Divide the altitude we need to traverse by y_steps to calculate alt_per_step
    (sim_altitude_max - sim_altitude_min) / y_steps

  cur_alt_obs: ember.observer 'cur_altitude', ->
    cur_altitude = @get('cur_altitude')
    if @get('sim_running') and cur_altitude <= 0
      @collect_trial_completion_data()
      @get('humidity_chart').validateData()
      @get('altitude_chart').validateData()
      @set('sim_running', false)

  start_dew_point: ember.computed 'start_humidity', ->
    start_humidity = @get('start_humidity')

    start_dew_point = 2354 / (9.4041 - Math.log(start_humidity)/Math.log(10)) - 273
    start_dew_point = start_dew_point.toFixed(1)
  
  # Used to make sure that the max temp is tied to the selected humidity
  temp_min: ember.computed 'start_humidity', ->
    start_humidity_mb = parseFloat(@get('start_humidity'))

    start_humidity_mmhg = start_humidity_mb / 1.33322368

    min_temp = (1730.63 / (8.07131 - (Math.log(start_humidity_mmhg) / Math.log(10)))) - 233.426

  ## Used to make sure that the max humidity is tied to the selected temp.
  humidity_max: ember.computed 'start_temp', ->
    start_temp = parseFloat(@get("start_temp"))

    ## Use the Antoine equation to calculate the vapor pressure.
    pressure_mmhg = Math.pow(10, (8.07131 - (1730.63 / (233.426 + start_temp))))

    pressure_mb = pressure_mmhg * 1.33322368

  trial_valid: ember.computed 'temp_min', 'humidity_max', ->
    temp_min       = @get('temp_min')
    humidity_max   = @get('humidity_max')
    start_humidity = @get('start_humidity')
    start_temp     = @get('start_temp')

    if start_temp < temp_min or start_humidity > humidity_max
      return false
    else
      return true

  ## Used so the user can have the visual indication of where on the graph they'll be starting
  user_indicator_update: ember.observer 'start_temp', 'start_humidity', ->
    humidity_chart      = @get('humidity_chart')
    humidity_chart_data = @get('humidity_chart_data')
    start_temp          = @get('start_temp')
    start_humidity      = @get('start_humidity')

    humidity_chart_data.find(
      ((element) ->
        if element.start_temp?
          element.start_temp     = start_temp
          element.start_humidity = start_humidity
          humidity_chart.validateData()
      )
    )

  muted_obs: ember.observer 'muted', ->
    if @get('muted')
      createjs.Sound.volume = 0
    else
      createjs.Sound.volume = @get('volume_bar').scaleY

  init_template: ->
    range_class = @get 'range_class'
    template    = @get 'slider_background_template'
    $background = $(template)

    @$(".#{range_class}").prepend($background)

  collect_trial_start_data: ->
    cur_trial_data  = @get('cur_trial_data')
    start_temp      = @get('start_temp')
    start_humidity  = @get('start_humidity')
    start_dew_point = @get('start_dew_point')
    trial_num       = @get('trial_num')

    cur_trial_data["#{trial_num}"]['start_temp']      = start_temp
    cur_trial_data["#{trial_num}"]['start_humidity']  = start_humidity
    cur_trial_data["#{trial_num}"]['start_dew_point'] = start_dew_point

    @set('cur_trial_data', cur_trial_data)

  collect_trial_completion_data: ->
    cur_trial_data  = @get('cur_trial_data')
    trial_results   = @get('trial_results')
    final_temp      = @get('cur_temp')
    final_humidity  = @get('cur_humidity')
    final_dew_point = @get('cur_dew_point')
    trial_num       = @get('trial_num')
    cloud_base      = @get('cloud_base')

    cur_trial_data["#{trial_num}"]['final_temp']      = final_temp
    cur_trial_data["#{trial_num}"]['final_humidity']  = final_humidity
    cur_trial_data["#{trial_num}"]['final_dew_point'] = final_dew_point
    cur_trial_data["#{trial_num}"]['cloud_base']      = cloud_base

    trial_results.pushObject(cur_trial_data)

  willDestroyElement: ->
    @get('mountain_game').removeAllEventListeners()
    createjs.Ticker.removeAllEventListeners()

  didInsertElement: ->
    ## Need to set up the stage here so we can associate it with our template's canvas element
    @set('mountain_game', new createjs.Stage('mountain-sim-canvas'))

    canvas = document.getElementById('mountain-sim-canvas')
    canvas.width = 700
    canvas.height = 400

    createjs.Ticker.setFPS(@get('sim_fps'))
    createjs.Ticker.addEventListener('tick', createjs.Tween)

    #load_image_preloader = @get('load_image_preloader')
    #load_image_preloader.on('complete', ((event) -> @initialize_load_screen()).bind(@))
    #load_image_preloader.loadFile(new createjs.LoadItem().set({id: 'spaceship',     crossOrigin: true, src:'/assets/images/loading-ship.png'}))
    
    #load_image_preloader.load()
    @initialize_load_screen()

  ######## LOAD FUNCTIONS ########
  ## Called from didInsertElement hook. Uses 'image_preloader' to ensure simulation image assets are loaded, and animates via tween until load finishes.
  ## => initialize_load_screen()
  ## ===> Initializes canvas element loading animation, and creates 'tick' listener for timed_load
  ## => timed_load()
  ## ===> Waits for 120 ticks (~2 seconds at 60FPS) before starting load operation. Creates listener for load completion.
  ## => handle_load()
  ## ===> Cleans up load-related tweens and listeners, before calling 'initialize_simulation()'

  initialize_load_screen: ->
    mountain_game = @get('mountain_game')
    mountain_game.setBounds(0,0,700,400)

    load_text_container = new createjs.Container()

    #spaceship = new createjs.Bitmap(@get('load_image_preloader').getResult('spaceship'))
    dark_text = new createjs.Text('Arriving shortly!', '24px omnes-pro', '#63b4d6')
    dark_text.textAlign = 'center'

    #dark_text.y = spaceship.getBounds().height + 10

    #load_text_container.addChild(spaceship)
    load_text_container.addChild(dark_text)

    dark_text.x = load_text_container.getBounds().width / 2
    
    load_text_container.regY = load_text_container.getBounds().height / 2
    load_text_container.regX = load_text_container.getBounds().width / 2
    load_text_container.y    = mountain_game.getBounds().height / 2
    load_text_container.x    = mountain_game.getBounds().width / 2

    mountain_game.addChild(load_text_container)

    createjs.Tween.get(load_text_container, {loop:true})
      .to({alpha: 0}, 1000)
      .to({alpha: 1}, 1000)

    @set('load_text_container', load_text_container)

    ## Listener for general stage updates.
    game_tick_listener = createjs.Ticker.addEventListener("tick", mountain_game)
    @set('game_tick_listener', game_tick_listener)
    ## Listener for load.
    load_listener = createjs.Ticker.addEventListener("tick", ((event) -> @timed_load(event)).bind(@))
    @set('load_listener', load_listener)
    
    @initialize_graph()

    @$('input[id="temp_slider"]').rangeslider
      polyfill:    false
      rangeClass:  @get 'range_class'
      fillClass:   @get 'fill_class'
      handleClass: @get 'handle_class'
      onInit: => @init_template()
      onSlideEnd:  (position, value) =>
        @set('start_temp', value)
        #temp_output = document.getElementById('temp_output')
        #temp_output = value + ' °C'
      onSlide: (position, value) =>
        @set('temp_output', value.toFixed(1) + ' °C')
        #@update_temp(value)

    @$('input[id="humidity_slider"]').rangeslider
      polyfill:    false
      rangeClass:  @get 'range_class'
      fillClass:   @get 'fill_class'
      handleClass: @get 'handle_class'
      onInit: => @init_template()
      onSlideEnd:  (position, value) =>
        @set('start_humidity', value)
        #humidity_output = document.getElementById('humidity_output')
        #humidity_output = value + ' mb'
      onSlide: (position, value) =>
        @set('humidity_output', value.toFixed(1) + ' mb')
        #@update_humidity(value)


  # update_humidity: (value) ->
  #   humidity_output           = document.getElementById('humidity_output')
  #   humidity_output.innerHTML = value + ' mb'

  update_temp: (value) ->
    start_temp            = value
    start_temp_max        = @get('start_temp_max')
    start_temp_min        = @get('start_temp_min')
    sun_scale_coefficient = @get('sun_scale_coefficient')
    sun_rings             = @get('sun_rings')
    mountain_game         = @get('mountain_game')
    sun_ring_toggle       = @get('sun_ring_toggle')

    scale = 1 + ((start_temp - start_temp_min) / (start_temp_max - start_temp_min))

    sun_rings.forEach (ring_obj) =>
      if scale < 1 + ring_obj.coefficient
        createjs.Tween.get(ring_obj.ring)
          .to({alpha: 0}, 250)
              
        mountain_game.removeChild(ring_obj.ring)
        sun_rings.removeObject(ring_obj)

    ## The fraction of the bar we need to have moved down to create a new set of rings.
    next_ring_value = 1 + sun_scale_coefficient * (1 + sun_rings.get('length'))
    
    if scale > next_ring_value
      image_preloader = @get('image_preloader')
      mountain_game   = @get('mountain_game')
      new_ring       = {}

      if sun_ring_toggle
        ring = new createjs.Bitmap(image_preloader.getResult('sun_inner_ring'))
      else
        ring = new createjs.Bitmap(image_preloader.getResult('sun_outer_ring'))

      new_ring['ring']        = ring
      new_ring['coefficient'] = next_ring_value - 1

      ring.alpha = 0
      ring.x     = 560
      ring.y     = 50
      ring.regX  = ring.getBounds().width / 2
      ring.regY  = ring.getBounds().height / 2
      
      mountain_game.addChild(ring)

      createjs.Tween.get(ring)
        .to({alpha: 1}, 500)

      sun_rings.pushObject(new_ring)

      @toggleProperty('sun_ring_toggle')

    sun_rings.forEach (ring_obj) =>
      ring_obj.ring.scaleX = ring_obj.ring.scaleY = scale - ring_obj.coefficient - 0.1

    # temp_output           = document.getElementById('temp_output')
    # if temp_output?
    #   temp_output.innerHTML = value + ' °C'

  timed_load: (event) ->
    load_update_counter = @get('load_update_counter')

    if load_update_counter == @get('sim_fps')
      image_queue   = @get('image_preloader')
      load_listener = @get('load_listener')

      createjs.Sound.alternateExtensions = ['mp3']
      createjs.Sound.registerPlugins([createjs.HTMLAudioPlugin])

      createjs.Sound.on('fileload', ((event) -> @handle_sound_load(event)).bind(@))

      ## Needed to make ensure that if the sounds are already pre-loaded we register the sim as loaded.
      if createjs.Sound.loadComplete('https://s3.amazonaws.com/thinkspace-prod/sounds/thunder.mp3')
        @handle_sound_load('https://s3.amazonaws.com/thinkspace-prod/sounds/thunder.mp3')

      if createjs.Sound.loadComplete('https://s3.amazonaws.com/thinkspace-prod/sounds/wind.mp3')
        @handle_sound_load('https://s3.amazonaws.com/thinkspace-prod/sounds/wind.mp3')

      createjs.Sound.registerSound('https://s3.amazonaws.com/thinkspace-prod/sounds/thunder.mp3', 'thunder')
      createjs.Sound.registerSound('https://s3.amazonaws.com/thinkspace-prod/sounds/wind.mp3', 'wind')

      image_queue.on('complete', ((event) -> @handle_load(event)).bind(@))
      #image_queue.loadFile(new createjs.LoadItem().set({id: 'leaf',           crossOrigin: true, src:'/assets/images/simulations/mountain/leaf.png'}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'background',     crossOrigin: true, src:'/assets/images/simulations/mountain/mountain.png'}))
      #image_queue.loadFile(new createjs.LoadItem().set({id: 'cloud_1',        crossOrigin: true, src:'/assets/images/simulations/mountain/cloud.png'}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'leaf_sheet',     crossOrigin: true, src:'/assets/images/simulations/mountain/leaf-spritesheet.png'}))
      #image_queue.loadFile(new createjs.LoadItem().set({id: 'sun_center',     crossOrigin: true, src:'/assets/images/simulations/mountain/mountain_sun.png'}))
      #image_queue.loadFile(new createjs.LoadItem().set({id: 'sun_inner_ring', crossOrigin: true, src:'/assets/images/simulations/mountain/mountain_sun-inner-ring.png'}))
      #image_queue.loadFile(new createjs.LoadItem().set({id: 'sun_outer_ring', crossOrigin: true, src:'/assets/images/simulations/mountain/mountain_sun-outer-ring2.png'}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'raindrop',       crossOrigin: true, src:'/assets/images/simulations/mountain/raindrop.png'}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'cloud_2',        crossOrigin: true, src:'/assets/images/simulations/mountain/borderless_cloud3.png'}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'mountain_base',  crossOrigin: true, src:'/assets/images/simulations/mountain/mountain_base.png'}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'speaker',        crossOrigin: true, src:'/assets/images/simulations/speaker.png'}))
      image_queue.loadFile(new createjs.LoadItem().set({id: 'speaker_mute',   crossOrigin: true, src:'/assets/images/simulations/speaker-mute.png'}))
      
      image_queue.load()

      createjs.Ticker.removeEventListener("tick", load_listener)

    @set('load_update_counter', load_update_counter + 1)

  handle_sound_load: (event) ->
    sounds_complete = @get('sounds_complete') + 1
    if sounds_complete == @get('sound_count')
      createjs.Sound.removeAllEventListeners()
      @set('sounds_loaded', true)

    @set('sounds_complete', sounds_complete)

  handle_load: (event) ->
    @get('image_preloader').removeAllEventListeners()
    #@get('load_image_preloader').removeAllEventListeners()
    @set('images_loaded', true)

  ######## END OF LOAD FUNCTIONS ########

  simulation_update: (event) ->
    mountain_game   = @get('mountain_game')
    leaf            = mountain_game.leaf
    ground_level    = @get('sim_ground_level')
    canvas_midpoint = @get('canvas_midpoint')
    x_step_size     = @get('x_step_size')
    y_step_size     = @get('y_step_size')
    alt_per_step    = @get('alt_per_step')
    trial_num       = @get('trial_num')

    update_counter = @get('update_counter')

    if leaf.y <= ground_level
      if @get('sim_running')
        update_counter += 1

        ## We either can update the leaf sprite position here, allowing us to have it move several 'ticks' before we re-plot the point,
        ## or do it inside the update_counter == 'x' block, which slows down the speed of the sim as 'x' increases.
        if leaf.x < canvas_midpoint
            leaf.x += x_step_size
            leaf.y -= y_step_size
          else
            leaf.x += x_step_size
            leaf.y += y_step_size

        leaf.rotation += Math.floor(Math.random() * 5) + 1

        @set('update_counter', update_counter)

        ## Can modify the update_counter == x to change the modify the frequency of data being plotted.
        if update_counter == 1
          ## Save old values before we start manipulating them
          old_altitude  = @get('cur_altitude')
          old_temp      = @get('cur_temp')
          old_humidity  = @get('cur_humidity')
          old_pressure  = @get('cur_pressure')
          old_dew_point = @get('cur_dew_point')

          factor        = @get('factor')

          start_temp     = parseInt(@get('start_temp'))
          start_pressure = @get('start_pressure')
          start_altitude = @get('sim_altitude_min')
          start_humidity = parseInt(@get('start_humidity'))

          if old_temp == 0
            old_temp = start_temp

          if old_humidity == 0
            old_humidity = start_humidity

          if old_pressure == 0
            old_pressure = start_pressure

          if leaf.x > canvas_midpoint
            alt_per_step *= -1
          ## Update Altitude
          cur_altitude = old_altitude + update_counter * alt_per_step
          ## Update humidity
          cur_pressure = start_pressure - 125 * (cur_altitude - start_altitude)
          ## Update Humidity
          cur_humidity = old_humidity * cur_pressure / old_pressure
          ## Update Dew Point
          cur_dew_point = 2354 / (9.4041 - Math.log(old_humidity)/Math.log(10)) - 273
          ## Update Temp
          cur_temp = old_temp - factor * (cur_altitude - old_altitude)
          ## Determine whether we're on the sublimation line
          h = Math.pow(10, (9.4041 - 2354 / (cur_temp + 273)))

          if cur_humidity > h
            if leaf.y <= @get('next_cloud_y')
              @animate_clouds(cur_altitude, leaf)
            cur_humidity = h
            factor = 6.0
          if cur_temp > old_temp
            factor = 10.0

          ## Set new values
          @set('cur_altitude',  cur_altitude)
          @set('cur_pressure',  cur_pressure)
          @set('cur_humidity',  cur_humidity)
          @set('cur_dew_point', cur_dew_point)
          @set('cur_temp',      cur_temp)
          @set('factor',        factor)

          ## This object will be pushed into a list of the steps regardless of bounds in add_graph_coords()
          step_data_obj             = {}
          step_data_obj['temp']     = cur_temp
          step_data_obj['humidity'] = cur_humidity
          step_data_obj['altitude'] = cur_altitude

          if @get('cloud_base') != 'Clear' and old_altitude < cur_altitude
            @create_rain(leaf)

          ## Needed to determine if the data for this step should be added to the graph.
          @add_graph_coords(step_data_obj, trial_num)

          @set('update_counter', 0)

  create_rain: (leaf_obj) ->
    rain_update_counter = @get('rain_update_counter')
    rain_update_target  = @get('rain_update_target')
    image_preloader     = @get('image_preloader')
    base_cloud_array    = @get('base_cloud_array')
    rain_array          = @get('rain_array')
    cloud               = base_cloud_array.get('firstObject')
    mountain_game       = @get('mountain_game')

    sim_peak        = @get('sim_peak')
    canvas_midpoint = @get('canvas_midpoint')

    if rain_update_counter >= rain_update_target
      first_cloud = base_cloud_array.get('firstObject')
      last_cloud  = base_cloud_array.get('lastObject')

      rand_range = (last_cloud.x + (last_cloud.getBounds().width / 2)) - (first_cloud.x - (first_cloud.getBounds().width / 2))

      rand = Math.floor(Math.random() * rand_range) - rand_range / 2

      total_y_distance = first_cloud.y - sim_peak
      total_x_distance = canvas_midpoint - first_cloud.x

      cur_y_distance = first_cloud.y - leaf_obj.y
      cur_x_distance = leaf_obj.x - first_cloud.x

      total_distance = Math.floor(Math.sqrt(Math.pow(total_x_distance, 2) + Math.pow(total_y_distance, 2)))
      cur_distance = Math.floor(Math.sqrt(Math.pow(cur_x_distance, 2) + Math.pow(cur_y_distance, 2)))

      traveled = cur_distance / total_distance

      calls_before_drop = (1 - traveled) * 20
      @set('rain_update_target', calls_before_drop)

      raindrop = new createjs.Bitmap(image_preloader.getResult('raindrop'))

      raindrop.x = first_cloud.x + rand
      if raindrop.x > leaf_obj.x 
        raindrop.x = leaf_obj.x
      raindrop.y = first_cloud.y
      
      mountain_game.addChild(raindrop)
      mountain_game.setChildIndex(raindrop, 1)
      rain_array.pushObject(raindrop)

      createjs.Tween.get(raindrop, {loop:true})
        .to({y: raindrop.y + 125}, 750)
        .call(->
          raindrop.x = cloud.x - rand
          raindrop.y = cloud.y
        )

      rain_update_counter = 0

    rain_update_counter += 1
    @set('rain_update_counter', rain_update_counter)

  initialize_simulation: ->
    mountain_game   = @get('mountain_game')
    leaf_start_x    = @get('leaf_start_x')
    leaf_start_y    = @get('sim_ground_level')
    image_preloader = @get('image_preloader')

    sim_ground_level = @get('sim_ground_level')
    sim_peak         = @get('sim_peak')

    createjs.Ticker.addEventListener("tick", mountain_game)
    sim_update_listener = createjs.Ticker.addEventListener("tick", ((event) -> @simulation_update(event)).bind(@))
    @set('sim_update_listener', sim_update_listener)

    mountain_background = new createjs.Bitmap(image_preloader.getResult('background'))
    mountain_base       = new createjs.Bitmap(image_preloader.getResult('mountain_base'))
    #sun_center          = new createjs.Bitmap(image_preloader.getResult('sun_center'))

    #sun_center.regX     = sun_center.getBounds().width / 2
    #sun_center.regY     = sun_center.getBounds().height / 2

    #sun_center.x = 560
    #sun_center.y = 50

    #@set('sun_center', sun_center)

    mountain_game.addChild(mountain_background)
    mountain_game.addChild(mountain_base)
    #mountain_game.addChild(sun_center)

    sprite_data = {
      images: [image_preloader.getResult('leaf_sheet')],
      frames: {width: 30, height: 30},
      animations: {
        roll: {
          frames: [0,1,2,3]
        },
        inverted_roll: {
          frames: [3,2,1,0]
        }
      },
      framerate: 4
    }

    sprite_sheet = new createjs.SpriteSheet(sprite_data)

    leaf      = new createjs.Sprite(sprite_sheet)
    leaf.x    = leaf_start_x
    leaf.y    = leaf_start_y
    leaf.regX = leaf.getBounds().width / 2
    leaf.regY = leaf.getBounds().height / 2
    leaf.addEventListener('animationend', ((event) -> @animation_manager(event)).bind(@))
    mountain_game.snapToPixelEnabled = true
    leaf.snapToPixel = true

    mountain_game.leaf = leaf
    @set('leaf_obj', leaf)

    night_background = new createjs.Shape()
    night_background.graphics.beginFill("Black").drawRect(0,0,mountain_game.getBounds().width, mountain_game.getBounds().height)
    night_background.alpha = 0
    @set('night_overlay_obj', night_background)

    mountain_game.addChild(leaf)
    mountain_game.addChild(night_background)

    ## Need to initialize our mute button and volume bar. Bool is horizontal:true | vertical:false.
    @initialize_sound(mountain_game, false)

    createjs.Tween.get(mountain_game)
      .to({alpha: 1}, 1000)


  initialize_sound: (game, horizontal) ->
    game.enableMouseOver(10)

    sound_bar_container = new createjs.Container()
    speaker_image_container = new createjs.Container()
    speaker_image       = new createjs.Bitmap(@get('image_preloader').getResult('speaker'))
    speaker_mute_image  = new createjs.Bitmap(@get('image_preloader').getResult('speaker_mute'))

    speaker_mute_image.x = -6
    speaker_mute_image.alpha = 0

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
        speaker_mute_image.alpha = 1
        speaker_image.alpha      = 0
      else
        speaker_mute_image.alpha = 0
        speaker_image.alpha      = 1
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

  animation_manager: (event) ->
    leaf_obj = @get('leaf_obj')

    animation = Math.floor((Math.random() * 2) + 1)

    if animation == 1
      leaf_obj.play('roll')
    else
      leaf_obj.play('inverted_roll')

  animate_clouds: (cur_altitude, leaf_obj) ->
    cloud_height     = @get('cloud_height')
    mountain_game    = @get('mountain_game')
    cloud_base       = @get('cloud_base')
    base_cloud_array = @get('base_cloud_array')
    leaf_cloud_array = @get('leaf_cloud_array')
    cloud_array      = @get('cloud_array')
    image_preloader  = @get('image_preloader')
    sim_peak         = @get('sim_peak')
    cloud_base_y     = @get('cloud_base_y')

    next_cloud_y = @get('next_cloud_y')

    if leaf_obj.y <= next_cloud_y or cloud_base == 'Clear'

      ## Build the cloud based on our current base layer.
      base_cloud_array.forEach (base_cloud) =>
        if base_cloud_array.indexOf(base_cloud) >= base_cloud_array.get('length') - 5
          new_cloud = new createjs.Bitmap(image_preloader.getResult('cloud_2'))

          new_cloud.regX = new_cloud.getBounds().width / 2
          new_cloud.regY = new_cloud.getBounds().height / 2

          new_cloud.alpha = 0

          if base_cloud_array.indexOf(base_cloud) >= base_cloud_array.length - 1
            new_cloud.x = base_cloud.x + Math.floor((Math.random() * 45) - 22)
            new_cloud.y = base_cloud.y - base_cloud.getBounds().height / 2
          else
            if Math.floor(Math.random() * 2) == 0
              new_cloud.x = base_cloud.x + Math.floor((Math.random() * 45) - 22) + (10 * base_cloud_array.length)
              new_cloud.y = next_cloud_y + Math.floor((Math.random() * 45) - 22)
            else
              new_cloud.x = base_cloud.x - Math.floor((Math.random() * 45) - 22) + (10 * base_cloud_array.length)
              new_cloud.y = cloud_base_y - Math.floor(Math.random() * (cloud_base_y - leaf_obj.y))


          new_cloud.rotation = Math.floor(Math.random() * 360)
          cloud_array.pushObject(new_cloud)

          mountain_game.addChild(new_cloud)
          mountain_game.setChildIndex(new_cloud, 4)

          createjs.Tween.get(new_cloud)
            .to({alpha: 1}, 500)

      leaf_cloud_array.forEach (base_cloud) =>
        if leaf_cloud_array.indexOf(base_cloud) >= leaf_cloud_array.get('length') - 5
          new_cloud = new createjs.Bitmap(image_preloader.getResult('cloud_2'))

          new_cloud.regX = new_cloud.getBounds().width / 2
          new_cloud.regY = new_cloud.getBounds().height / 2

          new_cloud.alpha = 0

          if leaf_cloud_array.indexOf(base_cloud) >= leaf_cloud_array.length - 1
            new_cloud.x = base_cloud.x + Math.floor((Math.random() * 45) - 22)
            new_cloud.y = base_cloud.y - base_cloud.getBounds().height / 2
          else
            if Math.floor(Math.random() * 2) == 0
              new_cloud.x = base_cloud.x + Math.floor((Math.random() * 45) - 22) + (10 * leaf_cloud_array.length)
              new_cloud.y = next_cloud_y + Math.floor((Math.random() * 45) - 22)
            else
              new_cloud.x = base_cloud.x - Math.floor((Math.random() * 45) - 22) + (10 * leaf_cloud_array.length)
              new_cloud.y = cloud_base_y - Math.floor(Math.random() * (cloud_base_y - leaf_obj.y))


          new_cloud.rotation = Math.floor(Math.random() * 360)
          cloud_array.pushObject(new_cloud)

          mountain_game.addChild(new_cloud)
          mountain_game.setChildIndex(new_cloud, 4)

          createjs.Tween.get(new_cloud)
            .to({alpha: 1}, 500)

      cloud        = new createjs.Bitmap(image_preloader.getResult("cloud_2"))
      cloud.x      = -100
      cloud.alpha  = 0

      cloud.regX  = cloud.getBounds().width / 2
      cloud.regY  = cloud.getBounds().height / 2

      if Math.floor((Math.random() * 2) + 1) == 2
        cloud.rotation = 180
        mountain_game.setChildIndex(cloud, 2)
      else
        mountain_game.setChildIndex(cloud, 3)

      mountain_game.addChild(cloud)

      if cloud_base == 'Clear'
        @set('first_cloud', cloud)
        @set('cloud_base_y', leaf_obj.y)
        @set('cloud_base', cur_altitude)
        @play_thunder()
        @transition_storm()

      first_cloud  = @get('first_cloud')
      cloud_base_y = @get('cloud_base_y')
      cloud_width  = first_cloud.getBounds().width
      cloud_height = first_cloud.getBounds().height

      if base_cloud_array.length != 0
        left_cloud   = base_cloud_array.get('firstObject')
        right_cloud  = base_cloud_array.get('lastObject')

      if cloud == first_cloud
        cloud.x = leaf_obj.x
        cloud.y = leaf_obj.y
      ## Can go forwards or backwards, randomize one
      else if left_cloud.x - cloud_width > 0 and right_cloud.x + cloud_width / 2 < @calc_x(cloud_base_y)
        if Math.floor(Math.random() * 2) == 0
          ## Forwards
          cloud.x = right_cloud.x + cloud_width - (Math.floor(Math.random() * 10) + 10)
          cloud.y = cloud_base_y + (Math.floor(Math.random() * 15) - 8)
        else
          ## Backwards
          cloud.x = left_cloud.x - cloud_width + (Math.floor(Math.random() * 10) + 10)
          cloud.y = cloud_base_y + (Math.floor(Math.random() * 15) - 8)
      ## Can only go backwards
      else if left_cloud.x - cloud_width > 0
        cloud.x = left_cloud.x - cloud_width + (Math.floor(Math.random() * 10) + 10)
        cloud.y = cloud_base_y + (Math.floor(Math.random() * 15) - 8)
      ## Can only go forwards
      else if right_cloud.x + cloud_width < @calc_x(cloud_base_y)
        cloud.x = right_cloud.x + cloud_width - (Math.floor(Math.random() * 10) + 10)
        cloud.y = cloud_base_y + (Math.floor(Math.random() * 15) - 8)
      ## Follow the leaf
      else
        cloud.x = leaf_obj.x + (Math.floor(Math.random() * 15) - 10)
        cloud.y = right_cloud.y - (cloud_height - (Math.floor(Math.random() * 15) - 10))

      ## Add cloud to base_cloud_array based on x-coord.
      if cloud == first_cloud
        base_cloud_array.pushObject(cloud)
      else
        if cloud.x < left_cloud.x
          base_cloud_array.splice(0,0,cloud)
        else if cloud.x > right_cloud.x
          base_cloud_array.pushObject(cloud)

      leaf_cloud       = new createjs.Bitmap(image_preloader.getResult('cloud_2'))
      leaf_cloud.regX  = leaf_cloud.getBounds().width / 2
      leaf_cloud.regY  = leaf_cloud.getBounds().height / 2
      leaf_cloud.alpha = 0

      leaf_cloud.x        = leaf_obj.x + (Math.floor(Math.random() * 15) - 8)
      leaf_cloud.y        = leaf_obj.y

      leaf_cloud_array.pushObject(leaf_cloud)
      mountain_game.addChild(leaf_cloud)
      mountain_game.setChildIndex(leaf_cloud, 2)


      cloud.rotation = Math.floor(Math.random() * 180)
      @set('base_cloud_array', base_cloud_array)
      @set('leaf_cloud_array', leaf_cloud_array)

      createjs.Tween.get(leaf_cloud)
        .to({alpha:1},500)

      createjs.Tween.get(cloud)
        .to({alpha:1},500)

      @set('next_cloud_y', leaf_obj.y - cloud_height + 30)

  play_wind: ->
    createjs.Sound.play('wind')

  play_thunder: ->
    createjs.Sound.play('thunder')

  transition_storm: ->
    night_overlay = @get('night_overlay_obj')
    #sun_rings     = @get('sun_rings')
    #sun_center    = @get('sun_center')
    mountain_game = @get('mountain_game')

    createjs.Tween.get(night_overlay)
      .to({alpha:0}, 500)

    # sun_rings.forEach (ring) =>
    #   createjs.Tween.get(ring.ring)
    #     .to({alpha: 0}, 150)
    #     .call(->
    #       mountain_game.removeChild(ring.ring)
    #     )

    # createjs.Tween.get(sun_center)
    #   .to({alpha:0}, 150)

  initialize_graph: ->
    trial_num = @get('trial_num')
    default_humidity_chart_data = @get('default_humidity_chart_data').slice()
    default_altitude_chart_data = @get('default_altitude_chart_data').slice()

    @set('trial_results', ember.makeArray())

    @set('humidity_chart_data', default_humidity_chart_data)
    @set('altitude_chart_data', default_altitude_chart_data)

    humidity_chart_data = @get('humidity_chart_data')
    altitude_chart_data = @get('altitude_chart_data')

    humidity_chart = new AmCharts.AmXYChart()
    altitude_chart = new AmCharts.AmXYChart()

    humidity_chart.dataProvider     = humidity_chart_data
    humidity_chart.valueAxes        = [{'id':'y-axis', 'titleFontSize': 14, 'titleBold': false,'title':'Vapor pressure (mb)', 'maximum':50, 'minimum':0, 'autoGridCount':false,'gridCount':5}, 
                                      {'id':'x-axis', 'titleFontSize': 14, 'titleBold': false, 'title':'Temperature (°C)', 'position':'bottom', 'maximum':30,'minimum':-20, 'autoGridCount':false, 'gridCount':5}]
    humidity_chart.fontFamily       = 'omnes-pro'
    humidity_chart.creditsPosition  = 'top-left'

    altitude_chart.dataProvider    = altitude_chart_data
    altitude_chart.valueAxes       = [{'id':'y-axis', 'titleFontSize': 14, 'titleBold': false, 'title': 'Altitude (km)', 'maximum':5, 'minimum':0, 'autoGridCount':false, 'gridCount':5},
                                      {'id':'x-axis', 'titleFontSize': 14, 'titleBold': false, 'title': 'Temperature (°C)', 'position':'bottom','maximum':30, 'minimum':-20, 'autoGridCount':false, 'gridCount':5}]
    altitude_chart.fontFamily      = 'omnes-pro'
    altitude_chart.creditsPosition = 'top-left'

    next_graph_color = @get('next_graph_color')

    phase_line           = new AmCharts.AmGraph()
    phase_line.xField    = 'temp'
    phase_line.yField    = 'phase_line_vapor_humidity'
    phase_line.title     = 'Dew Point'
    phase_line.type      = 'smoothedLine'
    phase_line.lineColor = '#833da1'

    user_indicator                   = new AmCharts.AmGraph()
    user_indicator.xField            = 'start_temp'
    user_indicator.yField            = 'start_humidity'
    user_indicator.customBullet      = '/assets/images/simulations/mountain/rect_leaf.png'
    user_indicator.customBulletField = 'customBullet'
    user_indicator.bulletSize        = 20

    altitude_default_graph = new AmCharts.AmGraph()
    altitude_default_graph.xField = 'temp'
    altitude_default_graph.yField = 'altitude'

    altitude_graph_0             = new AmCharts.AmGraph()
    altitude_graph_0.xField      = 'dynamic_temp_0'
    altitude_graph_0.yField      = 'dynamic_altitude_0'
    altitude_graph_0.title       = 'Altitude'
    altitude_graph_0.lineColor   = next_graph_color

    humidity_graph_0           = new AmCharts.AmGraph()
    humidity_graph_0.xField    = 'dynamic_temp_0'
    humidity_graph_0.yField    = 'dynamic_humidity_0'
    humidity_graph_0.title     = 'Dynamic Graph'
    humidity_graph_0.lineColor = next_graph_color

    @set('humidity_graph_0', humidity_graph_0)
    @set('altitude_graph_0', altitude_graph_0)

    humidity_chart.addGraph(phase_line)
    humidity_chart.addGraph(user_indicator)
    humidity_chart.addGraph(humidity_graph_0)
    altitude_chart.addGraph(altitude_graph_0)
    altitude_chart.addGraph(altitude_default_graph)

    @set('humidity_chart', humidity_chart)
    @set('altitude_chart', altitude_chart)

    humidity_chart.write('chart-column1')
    altitude_chart.write('chart-column2')

    humidity_chart.validateData()
    altitude_chart.validateData()

    cur_trial_data = @get('cur_trial_data')
    trial_num      = @get('trial_num')

    cur_trial_data = {"#{trial_num}":{}}
    cur_trial_data["#{trial_num}"]["color"] = next_graph_color
    @set('cur_trial_data', cur_trial_data)

  ## Used to calculate how much x-space we have between the left-hand side of the canvas and the mountain graphic for a given 'y' value.
  calc_x: (y) ->
    return (470 - y) / 1.02

  add_first_point: ->
    humidity_chart_data = @get('humidity_chart_data')
    altitude_chart_data = @get('altitude_chart_data')
    start_temp          = @get('start_temp')
    start_humidity      = @get('start_humidity')
    start_altitude      = @get('start_altitude')
    trial_num           = @get('trial_num')

    new_altitude_data_point = {"dynamic_temp_#{trial_num}":start_temp, "dynamic_altitude_#{trial_num}":start_altitude}
    new_humidity_data_point = {"dynamic_temp_#{trial_num}":start_temp, "dynamic_humidity_#{trial_num}":start_humidity}

    humidity_chart_data.pushObject(new_humidity_data_point)
    altitude_chart_data.pushObject(new_altitude_data_point)

  add_dynamic_graphs: (trial_num) ->
    humidity_chart = @get('humidity_chart')
    altitude_chart = @get('altitude_chart')
    trial_num      = @get('trial_num')
    cur_trial_data = {}

    next_graph_color = @get('next_graph_color')

    temp_altitude = @get("altitude_graph_#{trial_num}")
    temp_humidity = @get("humidity_graph_#{trial_num}")

    if ember.isNone(temp_humidity) and ember.isNone(temp_altitude)
      ember.defineProperty @, "humidity_graph_#{trial_num}", undefined, new AmCharts.AmGraph()
      ember.defineProperty @, "altitude_graph_#{trial_num}", undefined, new AmCharts.AmGraph()

      temp_altitude = @get("altitude_graph_#{trial_num}")
      temp_humidity = @get("humidity_graph_#{trial_num}")

      humidity_chart.addGraph(temp_humidity)
      altitude_chart.addGraph(temp_altitude)

    temp_humidity.xField    = "dynamic_temp_#{trial_num}"
    temp_humidity.yField    = "dynamic_humidity_#{trial_num}"
    temp_humidity.title     = "Vapor Humidity Trial ##{trial_num}"
    temp_humidity.lineColor = next_graph_color

    temp_altitude.xField    = "dynamic_temp_#{trial_num}"
    temp_altitude.yField    = "dynamic_altitude_#{trial_num}"
    temp_altitude.title     = "Altitude Trial ##{trial_num}"
    temp_altitude.lineColor = next_graph_color

    cur_trial_data = {"#{trial_num}":{}}
    cur_trial_data["#{trial_num}"]["color"] = next_graph_color

    @set('cur_trial_data', cur_trial_data)

  add_graph_coords: (step_data_obj, trial_num) ->
    humidity_chart_data = @get('humidity_chart_data')
    humidity_chart      = @get('humidity_chart')
    altitude_chart_data = @get('altitude_chart_data')
    altitude_chart      = @get('altitude_chart')

    humidity_max = @get('graph_humidity_max')
    humidity_min = @get('graph_humidity_min')
    temp_max     = @get('graph_temp_max')
    temp_min     = @get('graph_temp_min')
    altitude_max = @get('graph_altitude_max')
    altitude_min = @get('graph_altitude_min')

    chart_step_data = @get('chart_step_data')
    ## Key our data to the trial num, and push it to the master data list.
    chart_step_data.pushObject({"#{trial_num}":step_data_obj})

    # Check whether the newly calculated data is within the bounds of our graphs.
    if step_data_obj.temp >= temp_min and step_data_obj.temp <= temp_max
      if step_data_obj.humidity >= humidity_min and step_data_obj.humidity <= humidity_max
        new_humidity_data_point = {}

        new_humidity_data_point["dynamic_temp_#{trial_num}"]     = step_data_obj.temp
        new_humidity_data_point["dynamic_humidity_#{trial_num}"] = step_data_obj.humidity

        humidity_chart_data.pushObject(new_humidity_data_point)

        if @get('dynamic_graphing')
          humidity_chart.validateData()

      if step_data_obj.altitude >= altitude_min and step_data_obj.altitude <= altitude_max
        new_altitude_data_point = {}

        new_altitude_data_point["dynamic_temp_#{trial_num}"]     = step_data_obj.temp
        new_altitude_data_point["dynamic_altitude_#{trial_num}"] = step_data_obj.altitude

        altitude_chart_data.pushObject(new_altitude_data_point)
        
        if @get('dynamic_graphing')
          altitude_chart.validateData()

  actions:
    pause_simulation: ->
      if @get('sim_running')
        game_tick_listener = @get('game_tick_listener')
        sim_update_listener = @get('sim_update_listener')

        createjs.Ticker.removeEventListener('tick', game_tick_listener)
        createjs.Ticker.removeEventListener('tick', sim_update_listener)
        @set('sim_paused', true)

    resume_simulation: ->
      if @get('sim_running')
        game_tick_listener = @get('game_tick_listener')
        sim_update_listener = @get('sim_update_listener')

        createjs.Ticker.addEventListener('tick', game_tick_listener)
        createjs.Ticker.addEventListener('tick', sim_update_listener)
        @set('sim_paused', false)

    reset_simulation: ->
      if @get('need_reset')
        leaf_obj         = @get('leaf_obj')
        leaf_start_x     = @get('leaf_start_x')
        leaf_start_y     = @get('sim_ground_level')
        trial_num        = @get('trial_num') + 1
        trial_results    = @get('trial_results')
        mountain_game    = @get('mountain_game')
        base_cloud_array = @get('base_cloud_array')
        leaf_cloud_array = @get('leaf_cloud_array')
        cloud_array      = @get('cloud_array')
        rain_array       = @get('rain_array')
        night_overlay    = @get('night_overlay_obj')
        #sun_center       = @get('sun_center')
        #sun_rings        = @get('sun_rings')

        @set('trial_num', trial_num)
        @set('sim_started', false)

        createjs.Tween.get(night_overlay)
          .to({alpha: 0}, 500)

        base_cloud_array.forEach (cloud) =>
          createjs.Tween.get(cloud)
            .to({alpha:0},500)
            .call(->
              mountain_game.removeChild(cloud)
              base_cloud_array.removeObject(cloud)
            )

        cloud_array.forEach (cloud) =>
          createjs.Tween.get(cloud)
            .to({alpha: 0}, 500)
            .call(->
              mountain_game.removeChild(cloud)
              cloud_array.removeObject(cloud)
            )

        leaf_cloud_array.forEach (cloud) =>
          createjs.Tween.get(cloud)
            .to({alpha: 0}, 500)
            .call(->
              mountain_game.removeChild(cloud)
              leaf_cloud_array.removeObject(cloud)
            )

        rain_array.forEach (raindrop) =>
          createjs.Tween.get(raindrop)
            .to({alpha: 0}, 500)
            .call(->
              mountain_game.removeChild(raindrop)
              rain_array.removeObject(raindrop)
            )

        createjs.Tween.get(leaf_obj)
          .to({alpha:0},500)
          .call(->
            leaf_obj.x = leaf_start_x
            leaf_obj.y = leaf_start_y
            createjs.Tween.get(leaf_obj)
              .to({alpha:1},500)
          )

        # sun_rings.forEach (ring_obj) =>
        #   mountain_game.removeChild(ring_obj.ring)
        #   sun_rings.removeObject(ring_obj)

        # createjs.Tween.get(sun_center)
        #   .to({alpha:1}, 500)

        @reset_properties_to_default()

        if trial_num > 0
          @set('start_temp', trial_results.get("lastObject.#{trial_num - 1}.start_temp"))
          @set('start_humidity', trial_results.get("lastObject.#{trial_num - 1}.start_humidity"))
        @add_dynamic_graphs(@get('trial_num'))

    step_humidity_slider: (bool) ->
      if @get('sim_running') == false
        slider_step_size = @get('slider_step_size')
        start_humidity = @get('start_humidity')

        if bool
          start_humidity_max = @get('start_humidity_max')

          if start_humidity < start_humidity_max
            @set('start_humidity', start_humidity + slider_step_size)
        else
          start_humidity_min = @get('start_humidity_min')

          if start_humidity > start_humidity_min
            @set('start_humidity', start_humidity - slider_step_size)

    step_temp_slider: (bool) ->
      if @get('sim_running') == false
        slider_step_size = @get('slider_step_size')
        start_temp = @get('start_temp')

        if bool
          start_temp_max = @get('start_temp_max')

          if start_temp < start_temp_max
            @set('start_temp', start_temp + slider_step_size)
        else
          start_temp_min = @get('start_temp_min')

          if start_temp > start_temp_min
            @set('start_temp', start_temp - slider_step_size)

    clear_graphs: ->
      if @get('simulation_loaded')
        humidity_chart = @get("humidity_chart")
        altitude_chart = @get("altitude_chart")

        new_humidity_array = @get('default_humidity_chart_data').slice()
        new_altitude_array = @get('default_altitude_chart_data').slice()

        @set('humidity_chart_data', null)
        @set('altitude_chart_data', null)
        @set('humidity_chart_data', new_humidity_array)
        @set('altitude_chart_data', new_altitude_array)
        @set('trial_num', -1)
        @set('trial_results', null)
        @set('trial_results', [])

        humidity_chart.dataProvider = @get('humidity_chart_data')
        altitude_chart.dataProvider = @get('altitude_chart_data')

        humidity_chart.validateNow()
        altitude_chart.validateNow()

        humidity_chart.validateData()
        altitude_chart.validateData()

        @send('reset_simulation')

    start_simulation: ->
      if @get('simulation_loaded')
        humidity_chart_data = @get('humidity_chart_data')
        humidity_chart      = @get('humidity_chart')
        start_temp          = @get('start_temp')
        start_humidity      = @get('start_humidity')

        humidity_chart_data.find(
          ((element) ->
            if element.start_temp?
              element.dynamic_temp     = start_temp
              element.dynamic_humidity = start_humidity
              humidity_chart.validateData()
          )
        )

        @collect_trial_start_data()
        @play_wind()
        @set('sim_running', true)
        @get('leaf_obj').play('roll')

    toggle_graph_visible: (visible, trial_num) ->
      altitude_chart = @get('altitude_chart')
      humidity_chart = @get('humidity_chart')

      altitude_graph = @get("altitude_graph_#{trial_num}")
      humidity_graph = @get("humidity_graph_#{trial_num}")

      if visible
        altitude_chart.addGraph(altitude_graph)
        humidity_chart.addGraph(humidity_graph)
      else
        altitude_chart.removeGraph(altitude_graph)
        humidity_chart.removeGraph(humidity_graph)

      altitude_chart.validateData()
      humidity_chart.validateData()