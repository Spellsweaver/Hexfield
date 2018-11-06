local states = require("states")
local utf8 = require("utf8")
local button = require("button")

local maxhpset = {}

local target
local maxhpnumber

local flashPeriod = 0.5
local flashTimeElapsed = 0
local flashingSymbol = true

function maxhpset.open(params)
	target = params.target
	maxhpnumber=target.maxhp or 0
end

function maxhpset.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	elseif key == "backspace" then
		local byteoffset = utf8.offset(maxhpnumber, -1)
 
		if byteoffset then
			-- remove the last UTF-8 character.
			-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
			maxhpnumber = string.sub(maxhpnumber, 1, byteoffset - 1)
		end
	end
end

function maxhpset.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(largefont)
	love.graphics.printf({{255,255,255},"Input new max HP (only numbers accepted):\n"..maxhpnumber,(flashingSymbol and {255,255,255} or {0,0,0}),"|"},width/2-200,height/2-100,400,"center")
	love.graphics.setFont(smallfont)

	button({x=width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='OK'})
	button({x=2*width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='Cancel'})
end

function maxhpset.update( dt )
	flashTimeElapsed = flashTimeElapsed + dt
	if flashTimeElapsed > flashPeriod then
		flashTimeElapsed = flashTimeElapsed - flashPeriod
		flashingSymbol = not flashingSymbol
	end
end

function maxhpset.mousepressed(x,y,button)
	if button==1 and y<height/2+150 and y>height/2+100 and x>width/3-75 and x<width/3+75 then
		local newMaxHp = tonumber(maxhpnumber)
		target.hp = target.hp*(newMaxHp/target.maxhp)
		target.maxhp = newMaxHp
		states.switch("properties",{target=target})
	elseif button==1 and y<height/2+150 and y>height/2+100 and x>2*width/3-75 and x<2*width/3+75 then
		states.switch("properties",{target=target})
	end
end

function maxhpset.textinput(t)
	if tonumber(t) then
		maxhpnumber = maxhpnumber .. t
	end
end

return maxhpset