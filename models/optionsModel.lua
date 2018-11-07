local deepcopy = require("deepcopy")
local fileHelper = require("fileHelper")

local model = {}

local defaultOptions =
{
	{name = "Show HP bars", values = {true,"always",false}, currentValue = 1},
	{name = "Show HP numbers", values = {true,"always",false}, currentValue = 1},
	{name = "HP numbers mode", values = {"none", "current hp only", "current and max hp"}, currentValue = 1},
	{name = "HP setting", values = {"integer values", "real values", "percentage"}, currentValue = 1}
}

model.options = deepcopy(defaultOptions)

function model.initialize()

	model.options = fileHelper.loadTable("options.json") or {}

	--creating backwards compatibility in case of added options or option values
	for k,v in pairs(defaultOptions) do
		if not model.options[k] then
			model.options[k] = deepcopy(v)
		else
			model.options[k].values = deepcopy(v.values)
		end
	end

end

function model.value(optionName)
	if tonumber(optionName) then --for indices
		return model.options[optionName].values[model.options[optionName].currentValue]
	else --for names
		for k,v in pairs(model.options) do
			if v.name == optionName then
				return v.values[v.currentValue]
			end
		end
	end
end

function model.switch(optionIndex)
	model.options[optionIndex].currentValue=model.options[optionIndex].currentValue+1
	if model.options[optionIndex].currentValue>#model.options[optionIndex].values then
		model.options[optionIndex].currentValue=1
	end
end

function model.save()
	fileHelper.saveTable("options.json", model.options)
end

return model