local states = require("states")
local utf8 = require("utf8")
local button = require("button")

local input = {}

local inputText

local flashPeriod = 0.5
local flashTimeElapsed = 0
local flashingSymbol = true

local staticText
local callbackApply, callbackCancel

function input.open(params)
	inputText = params.inputText
	staticText = params.staticText
	callbackApply = params.callbackApply
	callbackCancel = params.callbackCancel
end

function input.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	elseif key == "backspace" then
		local byteoffset = utf8.offset(inputText, - 1)
 
		if byteoffset then
			-- remove the last UTF-8 character.
			-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
			inputText = string.sub(inputText, 1, byteoffset - 1)
		end
	elseif key == "return" then
		callbackApply(inputText)
	end
end

function input.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(largefont)
	love.graphics.printf({{255,255,255},staticText..inputText,(flashingSymbol and {255,255,255} or {0,0,0}),"|"},width/2-200,height/2-100,400,"center")
	love.graphics.setFont(smallfont)

	button({x=width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='OK'})
	button({x=2*width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='Cancel'})
end

function input.update( dt )
	flashTimeElapsed = flashTimeElapsed + dt
	if flashTimeElapsed > flashPeriod then
		flashTimeElapsed = flashTimeElapsed - flashPeriod
		flashingSymbol = not flashingSymbol
	end
end

function input.mousepressed(x,y,button)
	if button==1 and y<height/2+150 and y>height/2+100 and x>width/3-75 and x<width/3+75 then
		callbackApply(inputText)
	elseif button==1 and y<height/2+150 and y>height/2+100 and x>2*width/3-75 and x<2*width/3+75 then
		callbackCancel(inputText)
	end
end

function input.textinput(t)
	if tonumber(t) then
		inputText = inputText .. t
	end
end

return input