local view = require("models/cameraModel")
local geometry = {}

geometry.panel = 300
geometry.hexres = 64
geometry.center = {}

function geometry.setSize(newSize)
	geometry.hexres = newSize
end

function geometry.recountDimensions()
	geometry.itemsFitX=math.floor(width/geometry.hexres/2)
	geometry.itemsFitY=math.floor(height/geometry.hexres/2)
	geometry.center[1]=math.floor((width-geometry.panel)/2)
	geometry.center[2]=math.floor(height/2)
end

function geometry.hex(x,y,mode)
	--draw a hexagon at x,y coordinates

	local mode = mode or 'line'

	local vertices={x+geometry.hexres*0.5, y+geometry.hexres*math.sqrt(3)/2, x+geometry.hexres, y, x+geometry.hexres*0.5,
	y-geometry.hexres*math.sqrt(3)/2, x-geometry.hexres*0.5, y-geometry.hexres*math.sqrt(3)/2, x-geometry.hexres, y, x-geometry.hexres*0.5, y+geometry.hexres*math.sqrt(3)/2}
	

	for i=1,6 do
		vertices[2*i]=vertices[2*i]-view.y
		vertices[2*i-1]=vertices[2*i-1]-view.x
	end

	for i=1,12 do
		vertices[i]=vertices[i]*view.scale
	end

	for i=1,6 do
		vertices[2*i]=vertices[2*i]+geometry.center[2]
		vertices[2*i-1]=vertices[2*i-1]+geometry.center[1]
	end

	love.graphics.polygon(mode, vertices)
end

function geometry.hexfill(x,y)
	--draw a filled hexagon
	geometry.hex(x,y,'fill')
end

function geometry.hexcoord(x,y)
	--convert cartesian coordinates into hexagonal
	return x/math.sqrt(3)-y,-x/math.sqrt(3)-y
end

function geometry.hextarget(x,y)
	--get index of a hexagon by hexagonal coordinates
	if x>=geometry.hexres*math.sqrt(3)/2 then
		xint=math.floor(x/(geometry.hexres*math.sqrt(3))+0.5)
	elseif x<=-geometry.hexres*math.sqrt(3)/2 then
		xint=math.ceil(x/(geometry.hexres*math.sqrt(3))-0.5)
	else
		xint=0
	end

	if y>=geometry.hexres*math.sqrt(3)/2 then
		yint=math.floor(y/(geometry.hexres*math.sqrt(3))+0.5)
	elseif y<=-geometry.hexres*math.sqrt(3)/2 then
		yint=math.ceil(y/(geometry.hexres*math.sqrt(3))-0.5)
	else
		yint=0
	end
	
	return xint,yint
end

return geometry