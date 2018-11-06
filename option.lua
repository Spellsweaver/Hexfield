local states = require("states")
local button = require("button")

local option = {}

function option.load(params)

end

function option.draw()
	local buttonPosition = 0
	for i=1,#options do
		button({x=300,y=i*60-30,width=width-600,height=30,lineWidth=3,text=options[i].name.." : "..tostring(options[i].values[options[i].currentValue])})
	end
end

function option.mousepressed(x,y,button)
	if button==1 and x>300 and x<width-300 and y%60>30  then
		local optionIndex = math.ceil(y/60)
		if optionIndex<=#options then
			options[optionIndex].currentValue=options[optionIndex].currentValue+1
			if options[optionIndex].currentValue>#options[optionIndex].values then
				options[optionIndex].currentValue=1
			end
		end
	end
end

function option.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	end
end

return option