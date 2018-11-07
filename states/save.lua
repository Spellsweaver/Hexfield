local states = require("states")
local utf8 = require("utf8")
local button = require("button")
local fileHelper = require("fileHelper")
local hexfieldModel = require("models/hexfieldModel")

local save = {}
local filetointeract

local flashPeriod = 0.5
local flashTimeElapsed = 0
local flashingSymbol = true

function save.open(params)
	filetointeract = ""
end

function save.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	elseif key == "backspace" then
		-- get the byte offset to the last UTF-8 character in the string.
		local byteoffset = utf8.offset(filetointeract, -1)
		if byteoffset then
			-- remove the last UTF-8 character.
			-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
			filetointeract = string.sub(filetointeract, 1, byteoffset - 1)
		end
	elseif (key == "return" or key == "kpenter") and filetointeract~="" then
		hexfieldModel.save(filetointeract..".hxm")
		states.switch("map")
	end
end

function save.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(largefont)
	love.graphics.printf({{255,255,255},"Enter the name for a new file:\n"..filetointeract,(flashingSymbol and {255,255,255} or {0,0,0}),"|"},width/2-200,height/2-100,400,"center")
	love.graphics.setFont(smallfont)

	button({x=width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,unhighlight=(filetointeract==""),text='OK'})
	button({x=2*width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='Cancel'})
end

function save.update( dt )
	flashTimeElapsed = flashTimeElapsed + dt
	if flashTimeElapsed > flashPeriod then
		flashTimeElapsed = flashTimeElapsed - flashPeriod
		flashingSymbol = not flashingSymbol
	end
end

function save.mousepressed(x,y,button)
	if button==1 and filetointeract~="" and y<height/2+150 and y>height/2+100 and x>width/3-75 and x<width/3+75 then
		hexfieldModel.save(filetointeract..".hxm")
		states.switch("map")
	elseif button==1 and y<height/2+150 and y>height/2+100 and x>2*width/3-75 and x<2*width/3+75 then
		states.switch("map")
	end
end

function save.textinput(t)
	filetointeract = filetointeract .. t
end

return save