enemies = {}

function spawnEnemy(x, y)
    local enemy = world:newRectangleCollider(x, y, 32, 32,  { collision_class = "enemy" })
    enemy.direction = 1
    enemy.speed = 200
    enemy.animation = animations.enemy
    table.insert(enemies, enemy)
end

function updateEnemies(dt)
    for i, e in ipairs(enemies) do
        e.animation:update(dt)
        local ex, ey = e:getPosition()

        local speed = e.speed * dt * e.direction
        e:setX(ex + speed)
    end
end

function drawEnemies()
    for i, e in ipairs(enemies) do
        local ex, ey = e:getPosition()

        e.animation:draw(sprites.enemySheet, ex, ey, nil, e.direction, 1, 50, 50)
    end
end