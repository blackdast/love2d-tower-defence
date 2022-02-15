function love.load()
    love.window.setMode(1920, 1080)

    anim8 = require "libs/anim8/anim8"
    sti = require "libs/Simple-Tiled-Implementation/sti"
    grid = require ("libs/Jumper/jumper.grid")
    pathfinder = require ("libs/Jumper/jumper.pathfinder")

    enemyPath = {}
    enemyStartX = 0
    enemyStartY = 0
    enemyEndX = 0
    enemyEndY = 0

    sprites = {}
    sprites.enemySheet = love.graphics.newImage("sprites/enemy.png")
    sprites.towerSheet = love.graphics.newImage("sprites/tower.png")

    local enemyGrid = anim8.newGrid(32, 32, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())
    local towerGrid = anim8.newGrid(32, 32, sprites.towerSheet:getWidth(), sprites.towerSheet:getHeight())

    animations = {}
    animations.enemy = anim8.newAnimation(enemyGrid("1-4", 1), 0.2)
    animations.tower = anim8.newAnimation(towerGrid("1-4", 1), 0.6)

    wf = require "libs/windfield/windfield"
    world = wf.newWorld(0, 800, true)
    world:setGravity(0, 0)
    world:addCollisionClass("enemy")
    world:addCollisionClass("tower")
    world:addCollisionClass("towerPlace")
    -- world:setQueryDebugDrawing(true)

    towerPlaces = {}

    require("enemy")
    require("tower")
    require("libs/show")

    loadMap("Map-1")

    count = 30.9
    updateDelay = 31
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    updateEnemies(dt)
    updateTowers(dt)

    count = count + dt
    if count > updateDelay then
        spawnEnemy(enemyStartX, enemyStartY)
        count = 0
    end
end

function love.draw()
    gameMap:drawLayer(gameMap.layers["grass"])
    drawEnemies()
    drawTowers()
    -- world:draw()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local towerPlaceColliders = world:queryCircleArea(x, y, 16, {'towerPlace'})
        for i,c in ipairs(towerPlaceColliders) do
            local tx, ty = c:getPosition()
            spawnTower(tx - 16, ty - 16)
            c:destroy()
            break
        end
    end
end

function spawnTowerPlace(x, y, width, height)
    local towerPlace = world:newRectangleCollider(x, y, width, height, {collision_class = 'towerPlace'})
    towerPlace:setType('static')
    table.insert(towerPlaces, towerPlace)
end

function loadMap(mapName)
    destroyAll()

    gameMap = sti("maps/" .. mapName .. ".lua")

    for i, obj in pairs(gameMap.layers["start"].objects) do
        enemyStartX = obj.x + 32
        enemyStartY = obj.y + 32
    end

    for i, obj in pairs(gameMap.layers["end"].objects) do
        enemyEndX = obj.x + 32
        enemyEndY = obj.y + 32
    end

    for i, obj in pairs(gameMap.layers["towerPlace"].objects) do
        spawnTowerPlace(obj.x, obj.y, obj.width, obj.height)
    end

    local walkable = 2

    local enemyPathFinder = pathfinder(grid(prepareGrid(gameMap.layers["grass"].data, gameMap.layers["grass"].width, gameMap.layers["grass"].height)), 'JPS', walkable)
    enemyPath = enemyPathFinder:getPath(enemyStartX / 32, enemyStartY / 32, enemyEndX / 32, enemyEndY / 32)
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

    i = #towers
    while i > -1 do
        if towers[i] ~= nil then
            towers[i]:destroy()
        end
        table.remove(towers, i)
        i = i - 1
    end
end

function prepareGrid(grid, width, height)
    local preparedGrid = {}
    for i = 1, height do
        local string = {}
        for j = 1, width do
            table.insert(string, grid[i][j]["gid"])
        end
        table.insert(preparedGrid, string)
    end
    return preparedGrid
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end