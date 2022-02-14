function love.load()
    love.window.setMode(1920, 1080)

    anim8 = require "libs/anim8/anim8"

    sti = require "libs/Simple-Tiled-Implementation/sti"

    sprites = {}
    sprites.enemySheet = love.graphics.newImage("sprites/enemy.png")

    local enemyGrid = anim8.newGrid(32, 32, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

    animations = {}
    animations.enemy = anim8.newAnimation(enemyGrid("1-1", 1), 0.1)

    wf = require "libs/windfield/windfield"
    world = wf.newWorld(0, 800, true)
    world:setGravity(0, 0)
    world:addCollisionClass("enemy")

    require("enemy")
    require("libs/show")

    loadMap("Map-1")

    count = 0
    updateDelay = 5
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    updateEnemies(dt)

    count = count + dt
    if count > updateDelay then
        spawnEnemy(flagX, flagY)
        count = 0
    end
end

function love.draw()
    gameMap:drawLayer(gameMap.layers["grass"])
    drawEnemies()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function loadMap(mapName)
    destroyAll()

    gameMap = sti("maps/" .. mapName .. ".lua")

    for i, obj in pairs(gameMap.layers["start"].objects) do
        flagX = obj.x
        flagY = obj.y
    end
end

function destroyAll()
    i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies, i)
        i = i - 1
    end
end