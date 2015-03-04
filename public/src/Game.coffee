class Crashed.Game  
    #  When a State is added to Phaser it automatically has the following properties set on it, even if they already exist:
    # game      #  a reference to the currently running game (Phaser.Game)
    # @add       #  used to add sprites, text, groups, etc (Phaser.GameObjectFactory)
    # @camera    #  a reference to the game camera (Phaser.Camera)
    # @cache     #  the game cache (Phaser.Cache)
    # @input     #  the global input manager. You can access @input.keyboard, @input.mouse, as well from it. (Phaser.Input)
    # @load      #  for preloading assets (Phaser.Loader)
    # @math      #  lots of useful common math operations (Phaser.Math)
    # @sound     #  the sound manager - add a sound, play one, set-up markers, etc (Phaser.SoundManager)
    # @stage     #  the game stage (Phaser.Stage)
    # @time      #  the clock (Phaser.Time)
    # @tweens    #  the tween manager (Phaser.TweenManager)
    # @state     #  the state manager (Phaser.StateManager)
    # @world     #  the game world (Phaser.World)
    # @particles #  the particle manager (Phaser.Particles)
    # @physics   #  the physics manager (Phaser.Physics)
    # @rnd       #  the repeatable random number generator (Phaser.RandomDataGenerator)
    #  You can use any of these from any function within this State.
    #  But do consider them as being 'reserved words', i.e. don't create a property for your own game called "world" or you'll over-write the world reference.

  create: () ->
    # Physics
    @game.physics.startSystem Phaser.Physics.P2JS
    @physics.p2.setImpactEvents true
    @physics.p2.restitution = 0.8

    # Game state
    @rows = 6
    @buildingTypes = [ 'collector', 'farm', 'tower', 'wall' ]

    # Hexes
    @hexes = []
    @hexGroup = game.add.group()
    @selectedHexes = []

    # Enemeis
    @enemies = []
    @enemyGroup = game.add.group()
    @enemyCG = game.physics.p2.createCollisionGroup()

    # Bullets
    @bulletGroup = game.add.group()
    @bulletCG = game.physics.p2.createCollisionGroup()
    
    # Buildings
    @buildings = []
    @buildingGroup = game.add.group()
    @buildingCG = game.physics.p2.createCollisionGroup()

    # UI
    ui = game.add.group()

    # View
    @worldScale = 1
    game.world.setBounds -2000, -2000, 4000, 4000
    @camera.x -= @camera.width/2
    @camera.y -= @camera.height/2

    createMenu = () =>
      start = ui.create 10, 400, 'start'
      start.fixedToCamera = true
      start.inputEnabled = true
      start.input.useHandCursor = true
      start.events.onInputDown.add @clickStart

      for type, i in @buildingTypes
        button = ui.create 10, (i * 100) + 50, type
        button.height = 50
        button.width = 50
        button.fixedToCamera = true
        button.inputEnabled = true
        button.input.useHandCursor = true
        #this monstrousity will wait until I modify phaser library
        button.events.onInputDown.add ((_type)=>(()=>@clickBuildButton(_type)))(type)
    
    # Create the hex field
    start = 0
    end = @rows
    size = (new Phaser.Sprite game, 0, 0, 'hex').width/2
    for q in [-@rows..@rows] by 1
      for r in [start..end] by 1
        x = q * size * 1.5
        y = (r * Math.sqrt(3) * size) + (q * Math.sqrt(3)/2 * size)
        hex = new Hex { game: @, group: @hexGroup, click: @clickHex, x, y, q, r }
        
        @hexes["#{q}:#{r}"] = hex
      if q < 0 then start-- else end--

    @hexes["0:0"].sprite.alpha = 0.3

    createMenu()
    @cursors = game.input.keyboard.createCursorKeys()
    @game.physics.p2.setPostBroadphaseCallback @collided, @
    
  collided : (a, b) ->
    a = a.sprite#.container
    b = b.sprite#.container
    # a.alpha = .7
    # b.alpha = .7
    true


  build: (hex, type) ->
    hex.building = type
    @buildings.push(new Buildings[type](@, hex))

  clickHex: (hex) =>
    if hex.selected
      @selectedHexes.remove hex
      hex.deselect()
    else
      @selectedHexes.push hex
      hex.select()

  clickBuildButton: (type) ->
    @selectedHexes.forEach (h) =>
      @build h, type
      h.deselect()

  clickStart: () =>
    for h in hexUtils.ring(@hexes, @rows)
      @enemies.push new Enemy(@, h)

  startAttack: () ->

  enemyHit: (body, shapeA, shapeB, equation) ->
    console.log body.sprite.container#, shapeA, shapeB, equation
  
  update: () ->
    @physics.arcade.collide(@enemyGroup);
    e.update() for e in @enemies
    b.update() for b in @buildings
    # game.physics.arcade.collide @enemyGroup, @enemyGroup

    if @cursors.up.isDown
      game.camera.y -= 8
    else if @cursors.down.isDown
      game.camera.y += 8

    if @cursors.left.isDown
      game.camera.x -= 8
    else if @cursors.right.isDown
      game.camera.x += 8
