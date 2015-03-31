class window.SmallEnemy extends Enemy
  constructor: (@game, hex) ->
    # View
    @sprite = @game.enemyGroup.create hex.x, hex.y, 'enemy'

    # State
    @health = 100
    @maxHealth = 100
    @speed = 50
    @alive = true
    @sprite.name = 'enemy'

    # physics
    @game.physics.p2.enable @sprite, false
    @sprite.body.setCircle 7

    # Pathing
    @options =
      graph: @game.hexes
      end: @game.hexes["0:0"]
      impassable: (h) => h.building instanceof Buildings.wall
      heuristic: hexUtils.hexDistance
      neighbors: hexUtils.neighbors

    super(hex)