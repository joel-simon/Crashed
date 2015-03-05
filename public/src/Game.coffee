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

    # Game state
    @rows = 9
    @mode = 'build' #( attack | build )
    @enemyCount = 0
    @level = 0
    @money = 30
    
    @collectorIncome = 10
    @buildingProperties =
      collector: { consumption:  1, cost: 10 }
      reactor:   { consumption: -3, cost: 10 }
      pylon:     { consumption:  0, cost: 4  }
      wall:      { consumption:  0, cost: 2  }
      tower:     { consumption:  1, cost: 10 }
      base:      { consumption:  0, cost: 0  }

    # Physics
    @game.physics.startSystem Phaser.Physics.P2JS
    @physics.p2.setImpactEvents true
    @physics.p2.restitution = 0.8

    # Hexes
    @hexes = []
    @hexGroup = game.add.group()
    @selectedHexes = []

    # Enemies
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
    @buildUi = game.add.group() # ui specific to build phase
    @fightUi = game.add.group() # ui specific to fight phase
    @fightUi.visible = false
    @ui = game.add.group() # static ui
    
    # View
    @worldScale = 1
    game.world.setBounds -2000, -2000, 4000, 4000
    @camera.x -= @camera.width/2
    @camera.y -= @camera.height/2

    createMenu = () =>
      startButton = @buildUi.create 10, game.camera.height - 150, 'start'
      startButton.fixedToCamera = true
      startButton.inputEnabled = true
      startButton.input.useHandCursor = true
      startButton.events.onInputDown.add @startAttack

      i = 0
      for type, v of @buildingProperties
        continue if type is 'base' #cant build another base!
        button = @buildUi.create 10, (i * 60) + 50, type
        button.height = 50
        button.width = 50
        button.fixedToCamera = true
        button.inputEnabled = true
        button.input.useHandCursor = true
        #this monstrousity will wait until I modify phaser library
        button.events.onInputDown.add ((_type)=>(()=>@clickBuildButton(_type)))(type)
        i++
      
      style = { font: "45px Arial" }
      @statsText = game.add.text 50, 10, "", style
      @statsText.fixedToCamera = true
      @updateStatsText()

      @remainingText = new Phaser.Text game, 10, game.camera.height - 50, "Enemies remaining: #{@enemyCount}", style      
      @remainingText.fixedToCamera = true
      @fightUi.add @remainingText

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

    @hexes["0:0"].building = 'base'
    @buildings.push(new Buildings.base(@, @hexes["0:0"]))

    createMenu()
    @cursors = game.input.keyboard.createCursorKeys()
    # @game.physics.p2.setPostBroadphaseCallback @collided, @
    
  clickHex: (hex) =>
    if hex.selected
      @selectedHexes.remove hex
      hex.deselect()
    else
      @selectedHexes.push hex
      hex.select()

  clickBuildButton: (type) ->
    if buildingValidator.canBuild(@, type) != true
      alert buildingValidator.canBuild @, type
      @selectedHexes.forEach (h) => h.deselect()
      @selectedHexes = []
      return

    @selectedHexes.forEach (hex) =>
      hex.building = type
      @buildings.push(new Buildings[type](@, hex))
      hex.deselect()

    @money -= @selectedHexes.length * @buildingProperties[type].cost
    @selectedHexes = []
    @updateStatsText()

  updateStatsText: () ->
    @statsText.setText "Level: #{@level}   Power: #{@power()}    $#{@money}"

  power: () ->
    @buildings.reduce ((s, b) => s - @buildingProperties[b.sprite.name].consumption ), 0

  enemiesPerLevel: (n) ->
    n ?= @level
    Math.floor 10 * Math.pow(1.15, n)

  endAttack: () =>
    @mode = 'build'
    @buildUi.visible = true
    @fightUi.visible = false
    
    @enemies = []
    @level += 1
    for building in @buildings
      if building instanceof Buildings.collector
        @money += @collectorIncome
    
    @updateStatsText()
  
  startAttack: () =>
    @mode = 'attack'
    @buildUi.visible = false
    @fightUi.visible = true

    @enemyCount = @enemiesPerLevel()
    @remainingText.setText "Enemies remaining: #{@enemyCount}"
    outerRing = hexUtils.ring(@hexes, @rows)
    for i in [0...@enemyCount] by 1
      h = outerRing.random()
      @enemies.push new Enemy(@, h)
    true

  enemyHit: (enemySprite, sprite) ->
    # if sprite.name is 'building'
    if sprite.container and !(sprite.container instanceof Enemy)
      sprite.container.kill()

  bulletHit: (bulletSprite, enemySprite) ->
    enemySprite.container.kill()
    bulletSprite.kill()
    @enemyCount -= 1
    @remainingText.setText "Enemies remaining: #{@enemyCount}"
    @money++
    @updateStatsText()
    if @enemyCount is 0
      if (@enemies.reduce ((sum, e) -> sum + e.alive), 0) is 0
        @endAttack()
    true
      
  update: () ->
    e.update() for e in @enemies
    for b in @buildings
      b.update() if b.update

    if @cursors.up.isDown
      game.camera.y -= 8
    else if @cursors.down.isDown
      game.camera.y += 8

    if @cursors.left.isDown
      game.camera.x -= 8
    else if @cursors.right.isDown
      game.camera.x += 8
    true
