local thisState = {}

function thisState.load()
    points = 0
end

function thisState.update(_Dt)
    points = points + points * 0.001 * _Dt
end

function thisState.draw()

end

function thisState.keypressed(key, scancode, isrepeat)

end

function thisState.mousepressed(x, y, button, istouch, presses)

end



return thisState
