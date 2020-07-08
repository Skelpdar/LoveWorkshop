AnimLib = require("lib/animation")

G_Framerate = 0

G_CharacterHeight = 64
G_CharacterWidth = 64

G_GroundLevel = 400
G_StartHeight = 400 - 64

G_ScreenWidth = 640
G_ScreenHeight = 480

function CreateFireAnimation(AnimLib)
    local animation =
        {path="assets/fire.png", curFrame = 1, fps = 5,
         totalframes = 2, framewidth = 16, frameheight = 16}
    
    AnimLib.newAnimation("fireAnim", animation)

    return animation
end

G_Character = 
        {pos_x = 100, pos_y = G_StartHeight,
         vel_x = 0, vel_y = 0, image = love.graphics.newImage("assets/rocket.png"),
         animation = CreateFireAnimation(AnimLib), isThrusting = false} 

function love.load()
    love.window.setMode(G_ScreenWidth, G_ScreenHeight)
    love.graphics.setBackgroundColor(19/255, 20/255, 68/255)
end

-- love.update is given the timestep since the last update in seconds
-- love.timer.getFPS is also available
function love.update(dt)
    G_Framerate = 1/dt	

    -- there are also callback functions that are called on key-presses
    G_Character.isThrusting = love.keyboard.isDown("space")

    -- Physics
    G_Character.pos_x = G_Character.pos_x + G_Character.vel_x * dt
    G_Character.pos_y = G_Character.pos_y + G_Character.vel_y * dt

    local g = -100

    G_Character.vel_y = G_Character.vel_y - g*dt

    -- Controls
    if G_Character.isThrusting then
            G_Character.vel_y = G_Character.vel_y + 2*g*dt
    end

    if love.keyboard.isDown("right") and G_Character.pos_y ~= G_StartHeight then
        G_Character.vel_x = G_Character.vel_x + 5
    end		

    if love.keyboard.isDown("left") and G_Character.pos_y ~= G_StartHeight then
        G_Character.vel_x = G_Character.vel_x - 5
    end	

    -- More physics
    G_Character.pos_x = G_Character.pos_x + G_Character.vel_x*dt
    G_Character.pos_y = G_Character.pos_y + G_Character.vel_y*dt

    if G_Character.pos_y > G_StartHeight then
        G_Character.pos_y = G_StartHeight
        G_Character.vel_y = 0
    end

    if G_Character.pos_y == G_StartHeight then
        G_Character.vel_x = G_Character.vel_x * 0.95
    end

    if G_Character.pos_x > G_ScreenWidth + G_CharacterWidth then
        G_Character.pos_x = -G_CharacterWidth
    end		

    if G_Character.pos_x < -G_CharacterWidth then
            G_Character.pos_x = G_ScreenWidth + G_CharacterWidth
    end		

    AnimLib.updateAllAnimations(dt)
end

function UpdateBackgroundColor(love, characterHeight, startHeight)
    if characterHeight < -500 then
        love.graphics.setBackgroundColor(19/255, 20/255, 68/255)
    else
        local r = (characterHeight + 500) / (500 + startHeight)
        love.graphics.setBackgroundColor((1+2*r)*19/255, (1+2*r)*20/255, (1+2*r)*68/255)
    end
end

function SetCameraPosition(love, x, y)
    love.graphics.translate(x, y)
end

function RenderCharacter(love, character)
    love.graphics.draw(character.image, character.pos_x, character.pos_y)

    if character.isThrusting then
        love.graphics.draw(
                character.animation.image, character.animation.frames[math.floor(character.animation.curFrame)],
                character.pos_x + 32 - 8, character.pos_y + 64 - 8)
    end
end

function love.draw()
    UpdateBackgroundColor(love, G_Character.pos_y, G_StartHeight)

    SetCameraPosition(love, 0, G_StartHeight - G_Character.pos_y)

    -- The first argument is DrawMode, the other possibility is "line"
    -- for outlined shapes
    love.graphics.rectangle("fill", 0, G_GroundLevel, G_ScreenWidth, 80)

    RenderCharacter(love, G_Character)

    -- This resets the translation above
    -- so that we can draw GUI in screen space coordinates
    love.graphics.origin()

    -- Coloured text, love.graphics.printf is available for formatted text	
    -- To round a number x with a precision delta_x do:
    -- math.floor(x + delta_x / 2)
    love.graphics.print({{1,0,0,1},math.floor(G_Framerate+0.5)}, 0, 0)
end

