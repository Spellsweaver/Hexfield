local model = {}

local items = {"texture","object","unit","buff"}

function model.preload()
	for _,item in ipairs(items) do
		model[item] = {}
		local i=1
		while love.filesystem.getInfo(item.."s/"..i..".png") do
			model[item][i]=love.graphics.newImage(item.."s/"..i..".png")		
			i=i+1
		end
	end
end

return model