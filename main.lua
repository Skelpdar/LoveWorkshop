local anim = require("lib/animation")

framerate = 0

char = { pos_x = 100, pos_y = 400-64, isThrusting = false, vel_x = 0, vel_y = 0} 

local fireAnim = {path="assets/fire.png", curFrame = 1, fps = 5, totalframes = 2, 
    framewidth = 16, frameheight = 16}

function love.load()
	love.window.setMode(640,480)
	love.graphics.setBackgroundColor(19/255, 20/255, 68/255)

	characterImage = love.graphics.newImage("assets/rocket.png")

	anim.newAnimation("fireAnim",fireAnim)

end

-- love.update is given the timestep since the last update in seconds
-- love.timer.getFPS is also available
function love.update(dt)
	framerate = 1/dt	

	-- there are also callback functions that are called on key-presses
	char.isThrusting = love.keyboard.isDown("space")

	char.pos_x = char.pos_x + char.vel_x * dt
	char.pos_y = char.pos_y + char.vel_y * dt

	local g = -100

	char.vel_y = char.vel_y - g*dt

	if char.isThrusting then
			char.vel_y = char.vel_y + 2*g*dt
	end

	if love.keyboard.isDown("right") and char.pos_y ~= 400-64 then
		char.vel_x = char.vel_x + 5
	end		

	if love.keyboard.isDown("left") and char.pos_y ~= 400-64 then
		char.vel_x = char.vel_x - 5
	end	

	char.pos_x = char.pos_x + char.vel_x*dt
	char.pos_y = char.pos_y + char.vel_y*dt

	if char.pos_y > 400-64 then
		char.pos_y = 400-64
		char.vel_y = 0
	end

	if char.pos_y == 400-64 then
		char.vel_x = char.vel_x * 0.95
	end

	if char.pos_x > 640+64 then
		char.pos_x = -64
	end		

	if char.pos_x < -64 then
			char.pos_x = 640+64
	end		

	anim.updateAllAnimations(dt)

end

function love.draw()

    -- Changes the background color
    if char.pos_y < -500 then
	    love.graphics.setBackgroundColor(19/255, 20/255, 68/255)
    else
        local r = (char.pos_y + 500)/(500+400-64)
        love.graphics.setBackgroundColor((1+2*r)*19/255, (1+2*r)*20/255, (1+2*r)*68/255)
    end

    -- Translates the coordinates, as if we would have a moving camera
	love.graphics.translate(0, -char.pos_y + 400-64)

    -- Draws the rocket
	love.graphics.draw(characterImage, char.pos_x, char.pos_y)

	-- The first argument is DrawMode, the other possibility is "line"
	-- for outlined shapes
	love.graphics.rectangle("fill", 0, 400 , 640, 80)

    -- Fire exhaust
	if char.isThrusting then
		love.graphics.draw(fireAnim.image, fireAnim.frames[math.floor(fireAnim.curFrame)], char.pos_x + 32 - 8, char.pos_y + 64 - 8)
	end

    -- This resets the translation above
    -- so that we can draw GUI in screen space coordinates
	love.graphics.origin()

	-- Coloured text, love.graphics.printf is available for formatted text	
	-- To round a number x with a precision delta_x do:
	-- math.floor(x + delta_x / 2)
	love.graphics.print({{1,0,0,1},math.floor(framerate+0.5)}, 0, 0)
end

