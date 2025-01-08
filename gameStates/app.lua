local thisState = {}
local BASE_COLOR = {1,1,1}
textureTable = {
    {
        id = 1,
        texture = "air",
        name = "Air",
        color = BASE_COLOR
    },
    {   
        id = 2,
        texture = "grass",
        name = "Grass",
        color = {100/255, 190/255, 89/255},
        randomRotate = true
    },
    {
        id = 3,
        texture = "log_side",
        name = "Log",
        color = BASE_COLOR
    },
    {
        id = 4,
        texture = "log_top",
        name = "Log top",
        color = BASE_COLOR
    },
    {
        id = 5,
        texture = "planks",
        name = "Planks",
        color = BASE_COLOR
    }
}
textureTableSize = 0
for i,v in pairs(textureTable) do textureTableSize = textureTableSize + 1 end
cam = {
    offX = 0,
    offY = 0,
    scale = 1,
    width = 800,
    height = 600,
}
map = {
    width = 0,
    height = 0
}
selectedTile = 3
tileSize = 16
drawingMode = "hold"
isDrawingSolid = true
startedDrawingRectangle = false
rectangleStart = {0,0}
rectangleEnd = {0,0}

function createMap(_Width,_Height,_Default)
    map.width = _Width
    map.height = _Height
    map.default = _Default
    print("createMap",_Width,_Height,json.encode(_Default))
    for i = 1, map.width do
        map[i] = {}
        for j = 1, map.height do
            map[i][j] = shallowCopy(_Default)
        end
    end
end

function mapToJson()
    local mapData = {width = map.width,height = map.height,tiles = {}}
    for i = 1, map.width do mapData.tiles[i] = {}
        for j = 1, map.height do
        mapData.tiles[i][j] = {
            id = map[i][j].id,
            solid = map[i][j].solid
        }
        end
    end
    return json.encode(mapData)
end


function toMapDecimal(_X,_Y)
    local x = (_X / tileSize / cam.scale) - cam.offX
    local y = (_Y / tileSize / cam.scale) - cam.offY
    return x, y
end

function toMap(_X,_Y)
    local x = (_X / tileSize / cam.scale) - cam.offX
    local y = (_Y / tileSize / cam.scale) - cam.offY
    return math.floor(x), math.floor(y)
end

function toScreen(_X,_Y)
    local x = (_X + cam.offX) * tileSize * cam.scale
    local y = (_Y + cam.offY) * tileSize * cam.scale
    return x, y
end

function getMapCanvas()
    local canvas = love.graphics.newCanvas(map.width*tileSize, map.height*tileSize)
    canvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(canvas)
    drawMap(false)
    love.graphics.setCanvas()
    return canvas
end

function drawMap(optimisePerformance, cam)
    local offX, offY = 0, 0
    local camScale = 1
    if cam then
        offX = -cam.offX 
        offY = -cam.offY 
        camScale = cam.scale
    end
    
    local startX = 1
    local startY = 1
    local endX = map.width
    local endY = map.height
    if optimisePerformance and cam then
        startX = math.max(math.floor(offX), 1)
        startY = math.max(math.floor(offY), 1)
        endX = math.min(math.ceil(offX + cam.width / tileSize / cam.scale), map.width)
        endY = math.min(math.ceil(offY + cam.height / tileSize / cam.scale), map.height)
    end

    --[[
    local shadowAngle = math.pi*1.25
    local shadowForce = 0.2
    local simpleShadowX = math.cos(shadowAngle)
    local simpleShadowY = math.sin(shadowAngle)
    local shadowX = simpleShadowX * camScale * tileSize * shadowForce
    local shadowY = simpleShadowY * camScale * tileSize * shadowForce
    future shadow functions (will redo how map works for it)]] 

    for i = startX, endX do
        for j = startY, endY do
            local x = ((i-1) - offX) * tileSize * camScale
            local y = ((j-1) - offY) * tileSize * camScale

            local tile = map[i][j].id
            local drawName = textureTable[tile].texture
            local draw = img[drawName]
            local isSolid = map[i][j].solid
            local doRandomRotate = textureTable[tile].randomRotate
            local r, g, b = unpack(textureTable[tile].color)

            if draw then
                if isSolid then
                    --love.graphics.setColor(0,0,0,0.2)
                    --love.graphics.rectangle("fill",x + shadowX, y + shadowY, tileSize * camScale, tileSize * camScale)
                    love.graphics.setColor(r,g,b)
                else
                    love.graphics.setColor(r*0.8,g*0.8,b*0.8)
                end
                if doRandomRotate then
                    local rotate = math.floor(i * j + j^2) % 4 * math.pi / 2
                    love.graphics.draw(draw, x + (camScale * tileSize / 2), y + (camScale * tileSize / 2), rotate, camScale, camScale, tileSize / 2, tileSize / 2)
                else
                    love.graphics.draw(draw, x, y, 0, camScale, camScale)
                end
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.rectangle("line", x, y, tileSize, tileSize)
                love.graphics.line(x, y, x + tileSize, y + tileSize)
            end
        end
    end
end

function thisState.load(arg)
    print("arg",json.encode(arg))
    local mapWidth,mapHeight,mapDefault = 20,20,{id = 2,solid = false}
    if arg then
        mapWidth = arg.width
        mapHeight = arg.height
        mapDefault = arg.default
    end
    love.window.setMode(800, 600, {resizable=true})
    createMap(mapWidth, mapHeight, mapDefault)
end

function thisState.update()
    local camMoveSpeed = 0.2
    (function() -- input
        if love.keyboard.isDown("lshift") then
            camMoveSpeed = camMoveSpeed * 5
        end
        if love.keyboard.isDown("d") then
            cam.offX = cam.offX - camMoveSpeed
        end
        if love.keyboard.isDown("a") then
            cam.offX = cam.offX + camMoveSpeed
        end
        if love.keyboard.isDown("w") then
            cam.offY = cam.offY + camMoveSpeed
        end
        if love.keyboard.isDown("s") then
            cam.offY = cam.offY - camMoveSpeed
        end
        if love.keyboard.isDown("e") then
            cam.scale = cam.scale * 1.01
        end
        if love.keyboard.isDown("q") then
            cam.scale = cam.scale / 1.01
        end
    end)()

    if drawingMode == "rectangle" then
        if not startedDrawingRectangle then
            if love.mouse.isDown(1) then
                local mx,my = love.mouse.getPosition()
                local mapX, mapY = toMapDecimal(mx, my)
                rectangleStart = {mapX, mapY}
                rectangleEnd = {mapX, mapY}
                startedDrawingRectangle = true
            else
                local x1,y1 = rectangleStart[1], rectangleStart[2]
                local x2,y2 = rectangleEnd[1], rectangleEnd[2]
                if not (x1==0 and x2 == 0 and y1 == 0 and y2 == 0) then
                if x1 > x2 then
                    x1,x2 = x2,x1
                end
                if y1 > y2 then
                    y1,y2 = y2,y1
                end

                x1 = math.ceil(x1)
                y1 = math.ceil(y1)
                x2 = math.ceil(x2)
                y2 = math.ceil(y2)

                for i = x1, x2 do
                    for j = y1, y2 do
                        if i > 0 and j > 0 and i <= map.width and j <= map.height then
                            map[i][j].id = selectedTile
                            map[i][j].solid = isDrawingSolid
                        end
                    end
                end

                rectangleStart = {0,0}
                rectangleEnd = {0,0}
                end
            end
        else
            if not love.mouse.isDown(1) then
                startedDrawingRectangle = false
                print("RETANGULO",json.encode(rectangleStart),json.encode(rectangleEnd))
            else
                local mx,my = love.mouse.getPosition()
                local mapX, mapY = toMapDecimal(mx, my)
                rectangleEnd = {mapX, mapY}
            end
        end
    end

    if love.mouse.isDown(1) and drawingMode == "hold" then
        local mx,my = love.mouse.getPosition()
        local mapX, mapY = toMap(mx, my)
        local mapX = mapX + 1
        local mapY = mapY + 1
        if mapX > 0 and mapY > 0 and mapX <= map.width and mapY <= map.height then
            map[mapX][mapY].id = selectedTile
            map[mapX][mapY].solid = isDrawingSolid
        end
    end
end

function thisState.draw()
    local mx,my = love.mouse.getPosition()
    local mapX, mapY = toMap(mx, my)
    
    --love.graphics.draw(getMapCanvas(), cam.offX * cam.scale * 16,  cam.offY * cam.scale * 16, 0, cam.scale)
    drawMap(true,cam)
    local x,y = toScreen(mapX, mapY)
    love.graphics.rectangle("line", x, y, tileSize * cam.scale, tileSize * cam.scale)

    local y = 0
    local ii = 0
    for i,v in pairs(textureTable) do --drawing all the blocks GUI
        ii = ii + 1
        if img[i] then img[i]:setFilter("nearest", "nearest") end
        local r,g,b = unpack(v.color)
        withColor(r,g,b,1, function()love.graphics.draw(img[v.texture], 0, y, 0, 2, 2)end)
        if ii == selectedTile then
            love.graphics.rectangle("line", 0, y, 32, 32)
        end
        love.graphics.print(v.name, 32, y)
        y = y + 32
    end

    love.graphics.print("Drawing Mode: "..drawingMode, 150, 0)

    --print(json.encode(rectangleStart),json.encode(rectangleEnd))
    if drawingMode == "rectangle" and startedDrawingRectangle then
        local x,y = toScreen(rectangleStart[1], rectangleStart[2])
        local x2,y2 = toScreen(rectangleEnd[1], rectangleEnd[2])
        love.graphics.rectangle("line", x, y, (x2-x), (y2-y))
    end
    local windowWidth,windowHeight = love.window.getMode()
    local drawSolidString = ""

    if isDrawingSolid then drawSolidString = "Drawing Wall" else drawSolidString = "Drawing Ground" end
    
    love.graphics.print(drawSolidString, 0, windowHeight-32)
    love.graphics.print("F1: click mode, F2: hold mode, F3: rectangle mode, F5: save map, F6: new map", 0, windowHeight-16)
    love.graphics.print(string.format("%d , %d",cam.width,cam.height),300,200)
end

function thisState.keypressed(key, scancode, isrepeat)

    if tonumber(key) then
        selectedTile = tonumber(key)
        if selectedTile > textureTableSize then
            selectedTile = 1
        end
        if selectedTile < 1 then
            selectedTile = textureTableSize
        end
    end

    if key == "g" then
        isDrawingSolid = not isDrawingSolid
    end


    if key == "f1" then
        drawingMode = "click"
    end

    if key == "f2" then
        drawingMode = "hold"
    end

    if key == "f3" then
        drawingMode = "rectangle"
    end

    if key == "f5" then
        --obter o dia e hora como ano-mes-dia-hora-minuto-segundo
        local filename = os.date("%Y-%m-%d-%H-%M-%S") .. ".png"
        getMapCanvas():newImageData():encode("png", filename)
        -- Save the map data to a file

        local mapFile = love.filesystem.newFile(os.date("%Y-%m-%d-%H-%M-%S") .. ".json", "w")
        mapFile:write(mapToJson())
        mapFile:close()

        local selected = love.window.showMessageBox("Mapa salvo)","O mapa foi salvo como "..filename ,{"OK","Abrir pasta"})
        if selected == 2 then
            os.execute([[start %windir%\explorer.exe "C:\Users\Renan\AppData\Roaming\LOVE\MinecraftMapMaker"]])
        end
    end

    if key == "f6" then
        local selected = love.window.showMessageBox("Novo mapa","Deseja criar um novo mapa?",{"Sim","Não"})
        if selected == 1 then
            changeGameState("newMap")
        end
    end
end

function thisState.mousepressed(x,y)
    if drawingMode == "click" then
        local mx,my = love.mouse.getPosition()
        local mapX, mapY = toMap(mx, my)
        local mapX = mapX + 1
        local mapY = mapY + 1
        if mapX > 0 and mapY > 0 and mapX <= map.width and mapY <= map.height then
            map[mapX][mapY].id = selectedTile
            map[mapX][mapY].solid = isDrawingSolid
        end
    end
end

function thisState.wheelmoved(x,y)
    selectedTile = selectedTile - y
    if selectedTile > textureTableSize then
        selectedTile = 1
    end

    if selectedTile < 1 then
        selectedTile = textureTableSize
    end
end

function thisState.resize(w,h)
    cam.width = w
    cam.height = h
end

return thisState
