local states = require("states")
local geometry = require("hexagonalGeometryHelper")

local saveload = {}
local offset = 0
local saving

local mapSaveFile = {}

local buttonSave=love.graphics.newImage("buttons/save.png")
local buttonLoad=love.graphics.newImage("buttons/load.png")

function saveload.open(params)
	offset = 0
	saving = (params.mode == "save")
	mapSaveFile={}
	local fileinfolder=love.filesystem.getDirectoryItems("maps")
	for k,v in pairs(fileinfolder) do
		if v:sub(-4)==".hxm" then
			mapSaveFile[#mapSaveFile+1]=v
		end
	end
	if saving then
		mapSaveFile[#mapSaveFile+1]=""
	end
end

function saveload.draw()
	love.graphics.setColor(1,1,1)
	local filenameShown
	for i=1,#mapSaveFile-1 do
		love.graphics.draw(buttonLoad,((i-1)%geometry.itemsFitX)*2*geometry.hexres+14,(math.ceil(i/geometry.itemsFitX)-1-offset)*geometry.hexres*math.sqrt(3)+20)
		if mapSaveFile[i]:len()>15 then filenameShown=mapSaveFile[i]:sub(1,12).."..." else filenameShown=mapSaveFile[i] end
		love.graphics.printf(filenameShown,((i-1)%geometry.itemsFitX)*2*geometry.hexres,(math.ceil(i/geometry.itemsFitX)-offset)*geometry.hexres*math.sqrt(3),2*geometry.hexres,"center")
	end
	local i=#mapSaveFile
	if saving then
		love.graphics.draw(buttonSave,((i-1)%geometry.itemsFitX)*2*geometry.hexres+14,(math.ceil(i/geometry.itemsFitX)-1-offset)*geometry.hexres*math.sqrt(3)+20)
		love.graphics.printf("NEW FILE",((i-1)%geometry.itemsFitX)*2*geometry.hexres,(math.ceil(i/geometry.itemsFitX)-offset)*geometry.hexres*math.sqrt(3),2*geometry.hexres,"center")
	elseif i>0 then
		love.graphics.draw(buttonLoad,((i-1)%geometry.itemsFitX)*2*geometry.hexres+14,(math.ceil(i/geometry.itemsFitX)-1-offset)*geometry.hexres*math.sqrt(3)+20)
		if mapSaveFile[i]:len()>15 then filenameShown=mapSaveFile[i]:sub(1,12).."..." else filenameShown=mapSaveFile[i] end
		love.graphics.printf(filenameShown,((i-1)%geometry.itemsFitX)*2*geometry.hexres,(math.ceil(i/geometry.itemsFitX)-offset)*geometry.hexres*math.sqrt(3),2*geometry.hexres,"center")
	end

	if love.mouse.getX()<2*geometry.hexres*geometry.itemsFitX and love.mouse.getY()<math.sqrt(3)*geometry.hexres*geometry.itemsFitY then
		love.graphics.setColor(0,0,1)
		love.graphics.rectangle('line',2*geometry.hexres*(math.ceil(love.mouse.getX()/(geometry.hexres*2))-1),20+geometry.hexres*math.sqrt(3)*math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))),2*geometry.hexres,geometry.hexres*math.sqrt(3))
	end
	love.graphics.setColor(1,1,1)
end

function saveload.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	end

	if key == "up" then
		offset=math.max(0,offset-1)
	elseif key == "down" then
		offset=math.max(0,offset+1)
	end
end

function saveload.mousepressed(x,y,button)
	if button==1 and love.mouse.getX()<2*geometry.hexres*geometry.itemsFitX and love.mouse.getY()<math.sqrt(3)*geometry.hexres*geometry.itemsFitY then
		local fileChosen=math.ceil(love.mouse.getX()/(geometry.hexres*2)+math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))+offset)*geometry.itemsFitX)
		if saving and fileChosen<#mapSaveFile then
			states.switch("overwrite",{filetointeract=mapSaveFile[fileChosen]})
		elseif saving and fileChosen==#mapSaveFile then
			states.switch('save')
		elseif not saving then
			if fileChosen<=#mapSaveFile then
				states.switch("load",{filetointeract=mapSaveFile[fileChosen]})
			else
				states.switch("map")
			end
		end
	end
end

function saveload.wheelmoved(x,y)
	offset=math.max(offset-y,0)
end

return saveload