local geometry = require("hexagonalGeometryHelper")
local states = require("states")
local graphicsModel = require("models/graphicsModel")

local selection = {}
local offset = 0

local itemsFitX,itemsFitY

local itemName
local targetGraphicsTable
local rememberedMouseX,rememberedMouseY

function selection.open(params)
	offset = 0
	itemsFitX=math.floor(width/geometry.hexres/2)
	itemsFitY=math.floor(height/geometry.hexres/2)
	itemName = params.item or "texture"
	rememberedMouseX,rememberedMouseY = params.rememberedMouseX or 0,params.rememberedMouseY or 0
	targetGraphicsTable = graphicsModel[itemName]
end

function selection.draw()
	love.graphics.setColor(1,1,1)
	for i=1,#targetGraphicsTable do
		love.graphics.draw(targetGraphicsTable[i],((i-1)%itemsFitX)*2*geometry.hexres,(math.ceil(i/itemsFitX)-1-offset)*geometry.hexres*math.sqrt(3)+20)
	end	
	love.graphics.setColor(0,0,1)
	if love.mouse.getX()<2*geometry.hexres*itemsFitX and love.mouse.getY()<math.sqrt(3)*geometry.hexres*itemsFitY then
		love.graphics.rectangle('line',2*geometry.hexres*(math.ceil(love.mouse.getX()/(geometry.hexres*2))-1),20+geometry.hexres*math.sqrt(3)*math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))),2*geometry.hexres,geometry.hexres*math.sqrt(3))
		love.graphics.setColor(1,1,1)
	end
end

function selection.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	end

	if key == "up" then
		offset=math.max(0,offset-1)
	elseif key == "down" then
		offset=math.max(0,offset+1)
	end
end

function selection.wheelmoved(x,y)
	offset=math.max(offset-y,0)
end

function selection.mousepressed(x,y,button)
	if button==1 and love.mouse.getX()<2*geometry.hexres*itemsFitX and love.mouse.getY()<math.sqrt(3)*geometry.hexres*itemsFitY then
		itemChosen=math.ceil(love.mouse.getX()/(geometry.hexres*2)+math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))+offset)*itemsFitX)
		if itemChosen>#targetGraphicsTable then
			itemChosen=0
		end
		states.switch("map",{[itemName.."Chosen"]=itemChosen,clickMode=itemName})
		love.mouse.setPosition(rememberedMouseX,rememberedMouseY)
	end
end

function selection.resize()
	width,height=love.graphics.getDimensions()
	itemsFitX=math.floor(width/geometry.hexres/2)
	itemsFitY=math.floor(height/geometry.hexres/2)
end

return selection