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

    count = 30.9
    updateDelay = 31
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    updateEnemies(dt)

    count = count + dt
    if count > updateDelay then
        spawnEnemy(enemyStartX, enemyStartY)
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
        enemyStartX = obj.x
        enemyStartY = obj.y
    end

    for i, obj in pairs(gameMap.layers["end"].objects) do
        enemyEndX = obj.x
        enemyEndY = obj.y
    end

    local walkable = 2

    local enemyPathFinder = pathfinder(grid(prepareGrid(gameMap.layers["grass"].data, gameMap.layers["grass"].width, gameMap.layers["grass"].height)), 'JPS', walkable)
    enemyPath = enemyPathFinder:getPath(enemyStartX / 32 + 1, enemyStartY / 32 + 1, enemyEndX / 32 + 1, enemyEndY / 32 + 1)
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