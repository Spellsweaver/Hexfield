local scale = math.min(0.1, height*0.5/512)

local xMin = 40
local xMax = 512 * scale
local speed = 1000

local x = 40
local y = height

local rollResult = 0
local frame = 1
local maxFrames = 12
local fps = 24
local timer = 0

local imageBlank = love.graphics.newImage("diceroller/blank.png")
local imageRoll = {}
for roll = 1, 20 do
	imageRoll[roll] = love.graphics.newImage("diceroller/r"..roll..".png")
end

local frameQuad = {}
for frame = 1, maxFrames do
	frameQuad[frame] = love.graphics.newQuad((frame-1)*512,0,512,512,6144,512)
end

local diceroller = {}

function diceroller.draw()
	love.graphics.draw(imageBlank,x - 512 * scale,y - 512 * scale,0,scale)
	if rollResult>0 then
		love.graphics.draw(imageRoll[rollResult],frameQuad[frame],x - 512 * scale,y - 512 * scale,0,scale,scale)
	end
end

function diceroller.update(dt)
	scale = math.min(1, height*0.5/512)
	xMax = 512 * scale
	y = height
	local mouseX, mouseY = love.mouse.getPosition()
	if mouseX < x and mouseY > y - 512 * scale then
		speed = 2000 * ((256 * scale)/(256 * scale + x))^2
		x = math.min(xMax, x + dt*speed)
	else
		speed = 2000 * ((256 * scale)/(768 * scale - x))^1/2
		x = math.max(xMin, x - dt*speed)
	end
	if rollResult~=0 and frame<maxFrames then
		timer = timer + dt
		if timer>1/fps then
			timer = timer - 1/fps
			frame = frame + 1
		end
	end
end

function diceroller.click(clickX,clickY)
	if clickX < x and clickY > y - 512 * scale then
		frame = 1
		rollResult = math.random(1,20)
		timer = 0
		return true
	end
end

return diceroller