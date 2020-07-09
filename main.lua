AnimLib = require("lib/animation")
bump = require("lib/bump/bump")
cron = require("lib/cron/cron")
MGL = require("lib/MGL/src/MGL")

G_Framerate = 0


G_RocketHeight = 64
G_RocketWidth = 64

G_GroundLevel = 400
G_StartHeight = 400 - 64

G_ScreenWidth = 640
G_ScreenHeight = 480

G_world = bump.newWorld(64)

function CreateFireAnimation(AnimLib)
    local animation =
        {path="assets/fire.png", curFrame = 1, fps = 5,
         totalframes = 2, framewidth = 16, frameheight = 16}
    
    AnimLib.newAnimation("fireAnim", animation)

    return animation
end

G_Rocket = 
        {pos_x = 100, pos_y = G_StartHeight,
         vel_x = 0, vel_y = 0, image = love.graphics.newImage("assets/rocket.png"),
         animation = CreateFireAnimation(AnimLib), isThrusting = false} 

G_rocketCollision = {name="rocketCollision"}

G_world:add(G_rocketCollision, G_Rocket.pos_x, G_Rocket.pos_y, G_RocketHeight, G_RocketWidth)

G_groundCollision = {name="groundCollision"}

G_world:add(G_groundCollision, -64, 400, 640+2*64, 80)

function love.load()
	-- Creates a timer which calls the callback function every 5 seconds
	-- there is also cron.after, which only calls the function once
	G_clock = cron.every(5, (function() print("Five seconds have passed") end))

    love.window.setMode(G_ScreenWidth, G_ScreenHeight, {vsync=-1})
    love.graphics.setBackgroundColor(19/255, 20/255, 68/255)
end

-- love.update is given the timestep since the last update in seconds
-- love.timer.getFPS is also available
function love.update(dt)
    G_Framerate = 1/dt	

	-- All clocks need to be updated manually
	G_clock:update(dt)

    -- there are also callback functions that are called on key-presses
    G_Rocket.isThrusting = love.keyboard.isDown("space")

    -- Physics
    G_Rocket.pos_x = G_Rocket.pos_x + G_Rocket.vel_x * dt
    G_Rocket.pos_y = G_Rocket.pos_y + G_Rocket.vel_y * dt

    local g = -100

    G_Rocket.vel_y = G_Rocket.vel_y - g*dt

    -- Controls
    if G_Rocket.isThrusting then
            G_Rocket.vel_y = G_Rocket.vel_y + 2*g*dt
    end

    if love.keyboard.isDown("right") and G_Rocket.pos_y ~= G_StartHeight then
        G_Rocket.vel_x = G_Rocket.vel_x + 5
    end		

    if love.keyboard.isDown("left") and G_Rocket.pos_y ~= G_StartHeight then
        G_Rocket.vel_x = G_Rocket.vel_x - 5
    end	

    -- More physics
    local goal_x = G_Rocket.pos_x + G_Rocket.vel_x*dt
    local goal_y = G_Rocket.pos_y + G_Rocket.vel_y*dt

	-- Collisions
    local actualX, actualY, cols, len = G_world:move(G_rocketCollision, goal_x, goal_y)

    G_Rocket.pos_x = actualX
    G_Rocket.pos_y = actualY 

    if G_Rocket.pos_y < goal_y then
        G_Rocket.vel_y = 0
    end

	-- Friction
    if G_Rocket.pos_y == G_StartHeight then
        G_Rocket.vel_x = G_Rocket.vel_x * 0.95
    end

	-- Wrap around horizontally
    if G_Rocket.pos_x > G_ScreenWidth + G_RocketWidth then
        G_Rocket.pos_x = -G_RocketWidth
        G_world:update(G_rocketCollision, G_Rocket.pos_x, G_Rocket.pos_y)
    end		

    if G_Rocket.pos_x < -G_RocketWidth then
            G_Rocket.pos_x = G_ScreenWidth + G_RocketWidth
            G_world:update(G_rocketCollision, G_Rocket.pos_x, G_Rocket.pos_y)
    end		

    AnimLib.updateAllAnimations(dt)
end

function UpdateBackgroundColor(love, rocketHeight, startHeight)
    if rocketHeight < -500 then
        love.graphics.setBackgroundColor(19/255, 20/255, 68/255)
    else
        local r = (rocketHeight + 500) / (500 + startHeight)
        love.graphics.setBackgroundColor((1+2*r)*19/255, (1+2*r)*20/255, (1+2*r)*68/255)
    end
end

function SetCameraPosition(love, x, y)
    love.graphics.translate(x, y)
end

function RenderRocket(love, rocket)
    love.graphics.draw(rocket.image, rocket.pos_x, rocket.pos_y)

    if rocket.isThrusting then
        love.graphics.draw(
                rocket.animation.image, rocket.animation.frames[math.floor(rocket.animation.curFrame)],
                rocket.pos_x + 32 - 8, rocket.pos_y + 64 - 8)
    end
end

function love.draw()
    UpdateBackgroundColor(love, G_Rocket.pos_y, G_StartHeight)

    SetCameraPosition(love, 0, G_StartHeight - G_Rocket.pos_y)

    -- The first argument is DrawMode, the other possibility is "line"
    -- for outlined shapes
    love.graphics.rectangle("fill", 0, G_GroundLevel, G_ScreenWidth, 80)

    RenderRocket(love, G_Rocket)

    love.graphics.rectangle("line", G_Rocket.pos_x, G_Rocket.pos_y, G_RocketWidth, G_RocketHeight)

    -- This resets the translation above
    -- so that we can draw GUI in screen space coordinates
    love.graphics.origin()

    -- Coloured text, love.graphics.printf is available for formatted text	
    -- To round a number x with a precision delta_x do:
    -- math.floor(x + delta_x / 2)
    love.graphics.print({{1,0,0,1},math.floor(G_Framerate+0.5)}, 0, 0)
end
