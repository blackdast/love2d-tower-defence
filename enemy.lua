enemies = {}

function spawnEnemy(x, y)
    local enemy = world:newRectangleCollider(x + 32, y + 32, 32, 32,  { collision_class = "enemy" })
    enemy.currentStep = 1
    enemy.speed = 2
    enemy.animation = animations.enemy
    table.insert(enemies, enemy)
end

function updateEnemies(dt)
    for i, e in ipairs(enemies) do
        e.animation:update(dt)
        local ex, ey = e:getPosition()

        local normalX = ex - 16
        local normalY = ey - 16

        for node, count in enemyPath:nodes() do
            if count == (e.currentStep + 1) then
                local nextX = node:getX() * 32
                local nextY = node:getY() * 32

                if (normalX == nextX) and (normalY == nextY) then
                    e.currentStep = e.currentStep + 1
                    break
                end

                if not (normalX == nextX) then
                    local direction = 1
                    if normalX > nextX then
                        direction = -1
                    end
                    e:setX(ex + (e.speed * direction))
                end

                if not (normalY == nextY) then
                    local direction = 1
                    if normalY > nextY then
                        direction = -1
                    end
                    e:setY(ey + (e.speed * direction))
                end
            end
        end
    end
end

function drawEnemies()
    for i, e in ipairs(enemies) do
        local ex, ey = e:getPosition()

        e.animation:draw(sprites.enemySheet, ex, ey, nil, e.direction, 1, 48, 48)
    end
end