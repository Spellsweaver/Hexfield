local json = require("JSON")

local fileHelper = {}

function fileHelper.saveString(filepath,source)
	local filetoopen = love.filesystem.newFile(filepath)
	filetoopen:open("w")
	filetoopen:write(source)
	filetoopen:close()
end

function fileHelper.loadString(filepath)
	if love.filesystem.getInfo(filepath) then
		local filetoopen=love.filesystem.newFile(filepath)
		filetoopen:open("r")
		local contents = filetoopen:read()
		filetoopen:close()
		return contents
	end
end

function fileHelper.saveTable(filepath,source)
	local jsonData = json:encode(source)
	fileHelper.saveString(filepath,jsonData)
end

function fileHelper.loadTable(filepath)
	local jsonData = fileHelper.loadString(filepath)
	if jsonData then
		return json:decode(jsonData)
	end
end

function fileHelper.loadTableWithNegativeIndices(filepath)
--as json doesn't support negative and/or non-integer indices
--and I made a choice of using them for my coordinates
--I have to make a special method of conversion
--this function converts indices of numbers in form of string, like "1" into actual numberical indices
	local rawTable = fileHelper.loadTable(filepath)
	local refinedTable = {}
	for k,v in pairs(rawTable) do
		if type(k)~="number" and tonumber(k) then
			refinedTable[tonumber(k)]={}
			for kk, vv in pairs(v) do
				if type(kk)~="number" and tonumber(kk) then
					refinedTable[tonumber(k)][tonumber(kk)] = vv
				end
			end
		end
	end


	return refinedTable
end

return fileHelper