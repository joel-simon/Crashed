class window.Buildings.BasicTower2 extends Buildings.Tower
  constructor: (@game, @hex) ->
    @sprite = @game.buildingGroup.create @hex.x, @hex.y, 'BombTower1'
    @bullet = BasicBullet
    @controlledBullet = BasicBullet

    @name = 'BasicTower2'
    @range = 450
    @fireRate = 200
    @bulletSpeed = 600
    @bulletStrength = 200
    super(@game, @hex)
