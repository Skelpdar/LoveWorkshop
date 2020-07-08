--[ Library for animation, Erik "skelpdar" Wallin 2020
--
--An animation needs to be contained in a single spritesheet with frames placed horizontally.
--
--An animation is defined for example:
--animation = {path="assets/filename.png", curFrame = 1, fps = 5, totalframes = 2,
--	, framewidth = 16, frameheight = 16}
--
--	curFrame = the frame on which the animation starts
--	fps = frames per second, i.e. the animation speed
--	totalframes = the number of frames in the animation
--	framewidth = the width (in pixels) of one frame
--	frameheight = -||-
--]

local M = {}

-- Holds all animations and their states
M.list = {}

-- Helper function for loading animations
-- with images on a horizontal grid
local function loadAnimation(anim)
    anim.image = love.graphics.newImage(anim.path)
   
    anim.frames = {}
    for i = 0,(anim.totalframes - 1) do
        table.insert(anim.frames, love.graphics.newQuad(i*anim.framewidth,0, anim.framewidth, anim.frameheight, anim.image:getWidth(), anim.image:getHeight()))
    end
end

-- Creates and tracks a new animation
function M.newAnimation(name, table)
	M.list[name] = table
	loadAnimation(M.list[name])
end		

-- Updates the state of the animation
local function tickAnimation(anim, dt)
	anim.curFrame = anim.curFrame + dt*anim.fps

    if anim.curFrame > (anim.totalframes + 1)  then
        anim.curFrame = 1
    end
end	

-- Runs tickAnimation for all animations, used in love.update
function M.updateAllAnimations(dt)
	for key, val in pairs(M.list) do
		tickAnimation(val, dt)
	end		
end		

return M
