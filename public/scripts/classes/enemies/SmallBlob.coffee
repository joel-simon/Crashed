class window.SmallBlob extends Enemy
  constructor: ({ q, r }) ->
    health =  500
    speed = 2000 * (Math.random()/2 + 0.5)
    texture = textures.smallBlob
    super { q, r, health, speed, texture }

  onMove: (hex) ->
    if hex.building? and !hex.isWall()
      hex.building.destroy()