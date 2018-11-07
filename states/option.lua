local states = require("states")
local button = require("button")
local optionsModel = require("models/optionsModel")

local option = {}

function option.load(params)

end

function option.draw()
	local buttonPosition = 0
	for i=1,#optionsModel.options do
		button({x=300,y=i*60-30,width=width-600,height=30,lineWidth=3,text=optionsModel.options[i].name.." : "..tostring(optionsModel.value(i))})
	end
end

function option.mousepressed(x,y,button)
	if button==1 and x>300 and x<width-300 and y%60>30  then
		local optionIndex = math.ceil(y/60)
		if optionIndex<=#optionsModel.options then
			optionsModel.switch(optionIndex)
		end
	end
end

function option.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	end
end

return option