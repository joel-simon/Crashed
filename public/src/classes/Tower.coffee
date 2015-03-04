class window.Buildings.tower
  constructor: (@game, hex) ->
    # View
    @sprite = @game.buildingGroup.create hex.x, hex.y, 'tower'
    @sprite.anchor.set 0.5, 0.5

    # State
    @health = 100
    @alive = true
    @range = 200
    @target = null #Enemy Object
    @sprite.name = 'building'
    @sprite.container = @

    @fireRate = 400
    @nextFire = 0

    # Physics
    @game.physics.p2.enable @sprite, false
    @sprite.body.setCircle 15
    @sprite.body.static = true
    @sprite.body.setCollisionGroup @game.buildingCG
    @sprite.body.collides [ @game.enemyCG ]

  kill: () ->
    @alive = false
    @sprite.kill()

  update: () ->
    return unless @alive
    if @target? and @target.alive
      angle = Math.atan2(@target.sprite.y - @sprite.y, @target.sprite.x - @sprite.x)
      @sprite.body.rotation = angle + game.math.degToRad 90
      if @game.time.now > @nextFire
        @nextFire = @game.time.now + @fireRate
        new Bullet @game, @sprite.x, @sprite.y, angle
    else
      minD = Infinity
      for e in @game.enemies
        continue unless e.alive
        d = @game.physics.arcade.distanceBetween @sprite, e.sprite
        if d < minD and d < @range 
          minD = d
          @target = e
    true