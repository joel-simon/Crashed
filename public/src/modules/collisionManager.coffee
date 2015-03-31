window.collisionManager =
  enemyCollision: (game, enemy, collider) ->
    enemyWithEnemy = (enemy1, enemy2) ->
      # console.log(enemy1.sprite.body, enemy2.sprite.body)
      damage = Math.sqrt((enemy1.sprite.body.velocity.x - enemy2.sprite.body.velocity.x)**2 + (enemy1.sprite.body.velocity.y - enemy2.sprite.body.velocity.y)**2)
      # console.log('enemy to enemy collision did', damage)
      enemy1.damage damage/20
      enemy2.damage damage/20
    
    enemyWithBuilding = (enemy, building) ->
      return unless building
      game.buildings.remove building
      building.hex.building = null
      building.kill()
      if building instanceof Buildings.pylon
        game.markPowered()
    
    enemyWithWall = (enemy, wall) ->
      return unless enemy instanceof BigEnemy
      game.buildings.remove wall
      wall.hex.building = null
      wall.kill()
      game.enemies.forEach (e) -> 
        e.newPath = true if e instanceof SmallEnemy

    enemyWithBullet = (enemy, bullet) ->
      # console.log('collision with bullet')
      enemy.damage bullet.strength
      bullet.sprite.kill()
    enemyWithAoEBullet = (enemy, bullet) ->
      # console.log('collision withAoEBullet')
      enemy.damage bullet.strength
      for e in game.enemies
        distance = game.physics.arcade.distanceBetween e.sprite, bullet.sprite
        if distance < bullet.area
          force = 1/Math.pow(distance, 2)
          angle = Math.atan2(e.sprite.x - bullet.sprite.x, e.sprite.y - bullet.sprite.y)
          e.sprite.body.velocity.x += 800 * Math.cos(angle)# * force
          e.sprite.body.velocity.y += 800 * Math.sin(angle)# * force
      bullet.sprite.kill()

    if collider instanceof Enemy
      enemyWithEnemy(enemy, collider)
    else if (collider instanceof Buildings.pylon or
        collider instanceof Buildings.tower or
        collider instanceof Buildings.base or
        collider instanceof Buildings.collector)
      enemyWithBuilding(enemy, collider)
    else if collider instanceof Buildings.wall
      enemyWithWall enemy, collider
    else if collider instanceof Bullet
      enemyWithBullet(enemy, collider)
    else if collider instanceof AoEBullet
      enemyWithAoEBullet(enemy, collider)
    true