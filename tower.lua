towers = {}

function spawnTower(x, y)
    local tower = world:newRectangleCollider(x, y, 32, 32,  { collision_class = "tower" })
    tower:setType('static')
    tower.animation = animations.tower
    table.insert(towers, tower)
end

function updateTowers(dt)
    for i, e in ipairs(towers) do
        e.animation:update(dt)
    end
end


function drawTowers()
    for i, e in ipairs(towers) do
        local ex, ey = e:getPosition()

        e.animation:draw(sprites.towerSheet, ex, ey, nil, 1, 1, 16, 16)
    end
end