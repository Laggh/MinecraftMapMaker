local thisState = {}
local BASE_COLOR = {1,1,1}
textureTable = {
    {   
        id = 1,
        texture = "grass",
        name = "Grass",
        color = {100/255, 190/255, 89/255},
        randomRotate = true
    },
    {
        id = 2,
        texture = "log_side",
        name = "Log",
        color = BASE_COLOR
    },
    {
        id = 3,
        texture = "log_top",
        name = "Log top",
        color = BASE_COLOR
    },
    {
        id = 4,
        texture = "planks",
        name = "Planks",
        color = BASE_COLOR
    }
}

local selectedOption = 0
local options = {
    {
        name = "Width",
        value = 10
    },
    {
        name = "Height",
        value = 10
    },
    {
        name = "Texture",
        value = 1
    },
    {
        name = "Solid?",
        value = 1
    }
}

function thisState.load()
end

function thisState.update()
end

function thisState.draw()
    love.graphics.setFont(font.medium)
    for i,v in pairs(options) do
        local y = 50*i

        love.graphics.print(v.name..":"..v.value,10,y)

        love.graphics.rectangle("line",font.medium:getWidth(v.name..":"..v.value)+ 20,y,200,32)
        if selectedOption == i then
            love.graphics.line(font.medium:getWidth(v.name)+ 20 + 200, y, font.medium:getWidth(v.name)+ 20 + 200, y + 32)
        end
    end
    love.graphics.setFont(font.small)
end

function thisState.mousepressed(_X,_Y)
    selectedOption = 0
    love.keyboard.setTextInput(false)
    for i,v in pairs(options) do
        local y = 50*i
        if collision.pointRectangle(_X,_Y,font.medium:getWidth(v.name)+ 20,y,200,32) then
            selectedOption = i
            love.keyboard.setTextInput(true)
        end
    end
end

function thisState.keypressed(_Key)
    if selectedOption > 0 then
        if _Key == "backspace" then
            options[selectedOption].value = string.sub(options[selectedOption].value,1,-2)
        end
    end

    if _Key == "up" then
        selectedOption = selectedOption - 1
        if selectedOption < 1 then
            selectedOption = #options
        end
    end

    if _Key == "down" then
        selectedOption = selectedOption + 1
        if selectedOption > #options then
            selectedOption = 1
        end
    end

    if _Key == "return" then
        local width = tonumber(options[1].value)
        local height = tonumber(options[2].value)
        local mapDefault = {
            id = options[3].value,
            solid = options[4].value == 1
        }

        local arg = {
            width = width,
            height = height,
            default = mapDefault
        }
        changeGameState("app",arg)
    end
end

function thisState.textinput(_Text)
    if selectedOption > 0 then
        options[selectedOption].value = options[selectedOption].value.._Text
    end
end

return thisState
