local states = require("states")
local button = require("button")
local hexfieldModel = require("models/hexfieldModel")

local load = {}
local filetointeract

function load.open(params)
	filetointeract = params.filetointeract
end

function load.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(largefont)
	love.graphics.printf("You are going to open:\n"..filetointeract.."\nUnsaved data will be lost!",width/2-200,height/2-100,400,"center")
	love.graphics.setFont(smallfont)

	button({x=width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='OK'})
	button({x=2*width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='Cancel'})
	button({x=width-225,y=height-125,width=150,height=50,lineWidth=3,text='Delete',colorBasic={120,0,0},colorHighlit={255,0,0}})
end

function load.mousepressed(x,y,button)
	if button==1 and y<height/2+150 and y>height/2+100 and x>width/3-75 and x<width/3+75 then
		hexfieldModel.load(filetointeract)
		states.switch("map")
	elseif button==1 and y<height/2+150 and y>height/2+100 and x>2*width/3-75 and x<2*width/3+75 then
		states.switch("map")
	elseif button==1 and y<height-75 and y>height-125 and x>width-225 and x<width-75 then
		love.filesystem.remove("maps/"..filetointeract)
		states.switch("map")
	end
end

function load.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	end
end

return load