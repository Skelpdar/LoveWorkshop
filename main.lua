-- Load other files
require("otherfile")

framerate = 0

rec = { rec_pos_x = 100, rec_pos_y = 200, isMoving = false} 

function love.load()
	print("Prints on load")
end

-- love.update is given the timestep since the last update in seconds
-- love.timer.getFPS is also available
function love.update(dt)
	framerate = 1/dt	
	rec.rec_pos_x = 100 + 20*math.sin(love.timer.getTime() * 2) 

	-- there are also callback functions that are called on key-presses
	rec.isMoving = love.keyboard.isDown("space")

	if rec.isMoving then
		rec.rec_pos_y = 200 + 20*math.sin(love.timer.getTime() * 2)
	end	
end

function love.draw()
	-- Coloured text, love.graphics.printf is available for formatted text	
	-- To round a number x with a precision delta_x do:
	-- math.floor(x + delta_x / 2)
	love.graphics.print({{1,0,0,1},math.floor(framerate+0.5)}, 0, 0)
	love.graphics.print(returnstring(), 0, 20)
	-- The first argument is DrawMode, the other possibility is "line"
	-- for outlined shapes
	love.graphics.rectangle("fill", rec.rec_pos_x, rec.rec_pos_y , 50, 80)
end

