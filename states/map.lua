local geometry = require("hexagonalGeometryHelper")
local button = require("button")
local states = require("states")
local deepcopy = require("deepcopy")
--models
local hexfieldModel = require("models/hexfieldModel")
local optionsModel = require("models/optionsModel")
local graphicsModel = require("models/graphicsModel")
local view = require("models/cameraModel")

local map = {}
------
local hexsize = hexfieldModel.hexsize

local camdrag = false --indicates whether camera is being moved
local unitdrag, objectdrag = false, false --indicates whether a unit/object is being moved
local glow = false --indicates whether cursor is over a field and glow should be drawn

local panel = geometry.panel
local center = geometry.center

local drawr,drawg,drawb=1,1,1
local drawalpha=0.5
local textureChosen=1
local objectChosen=1
local objectRotation=0
local unitChosen=1
local clickMode=nil

local xglow,yglow --coordinates of targeted hexagon

local buttonRotate=love.graphics.newImage("buttons/rotate.png")
local buttonHp=love.graphics.newImage("buttons/heart.png")
local buttonHand=love.graphics.newImage("buttons/hand.png")
local buttonDelete=love.graphics.newImage("buttons/delete.png")
local buttonPaint=love.graphics.newImage("buttons/paint.png")
local buttonSave=love.graphics.newImage("buttons/save.png")
local buttonLoad=love.graphics.newImage("buttons/load.png")
local buttonOptions=love.graphics.newImage("buttons/options.png")

local function mousepos()
	local x, y = love.mouse.getPosition()
	local x2=(x-center[1])/view.scale+view.x
	local y2=(y-center[2])/view.scale+view.y
	return x2,y2
end

local function drawObject(index,rot,x,y,zoom)
	love.graphics.draw(graphicsModel.object[index],x,y,math.rad(rot*60),zoom,zoom,geometry.hexres,geometry.hexres*math.sqrt(3)/2)
end

function map.open(params)
	textureChosen=params.textureChosen or textureChosen
	objectChosen=params.objectChosen or objectChosen
	unitChosen=params.unitChosen or unitChosen
	clickMode=params.clickMode or clickMode
	drawr=params.drawr or drawr
	drawg=params.drawg or drawg
	drawb=params.drawb or drawb
	drawalpha=params.drawalpha or drawalpha

	if params.reset then
		hexfieldModel.reset()
	end
	if params.colorall then
		hexfieldModel.colorAll(drawr,drawg,drawb,drawalpha)
	end
end

function map.update()
	local mx,my=mousepos()
	local xhex,yhex=geometry.hexcoord(mx,my)
	xglow,yglow=geometry.hextarget(xhex,yhex)
	local x, y = love.mouse.getPosition()
	if  x<=(width-panel) and x>=0 and y>=0 and y<=height and xglow<=hexsize and xglow>=-hexsize and yglow>=-hexsize and yglow<=hexsize then
		glow=true
	else glow=false
	end
end

function map.keypressed(key,scancode)
	if key == "escape" then
		love.event.quit()
	elseif  --Ctrl + S
	scancode == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
	and (not love.keyboard.isDown("rshift") and not love.keyboard.isDown("lshift") or hexfieldModel.lastsavename=="") then
		states.switch("saveload",{saving=true})
	elseif --Ctrl + Shift + S
	scancode == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
	and (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") and hexfieldModel.lastsavename~="") then
		states.switch("overwrite",{filetointeract=hexfieldModel.lastsavename})
	elseif --Ctrl + O
	scancode == "o" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
	and not love.keyboard.isDown("rshift") and not love.keyboard.isDown("lshift") then
		states.switch("saveload",{saving=false})
	elseif --Ctrl + Shift + O
	scancode == "o" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
	and (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")) then
		love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/maps")
	elseif --Ctrl + N
	scancode == "n" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		autosave()
		model.reset()
		hexfieldModel.backup()
	elseif --Ctrl + Z
	scancode == "z" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		model.restore()
	end
end

function map.draw()

	love.graphics.setLineWidth(3)
	love.graphics.setColor(0.2,0.3,1)
	love.graphics.line(width-panel, 0, width-panel, height)

	for i=-hexsize,hexsize do --drawing grid
		for j=-hexsize,hexsize do
			love.graphics.setColor(1,1,1)

			if hexfieldModel.hexfield[i][j].texture and hexfieldModel.hexfield[i][j].texture>0 then
				love.graphics.draw(graphicsModel.texture[hexfieldModel.hexfield[i][j].texture],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
			end
			if hexfieldModel.hexfield[i][j].object.type>0 then
				drawObject(hexfieldModel.hexfield[i][j].object.type,hexfieldModel.hexfield[i][j].object.rotation,((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y)*view.scale+center[2],view.scale)
			end
			love.graphics.setColor(hexfieldModel.hexfield[i][j].color[1],hexfieldModel.hexfield[i][j].color[2],hexfieldModel.hexfield[i][j].color[3],hexfieldModel.hexfield[i][j].color[4])
			geometry.hexfill((i-j)*geometry.hexres*3/2,-(i+j)*math.sqrt(3)/2*geometry.hexres)
			love.graphics.setColor(1-hexfieldModel.hexfield[i][j].color[1],1-hexfieldModel.hexfield[i][j].color[2],1-hexfieldModel.hexfield[i][j].color[3],1)
			love.graphics.setLineWidth(1)
			geometry.hex((i-j)*geometry.hexres*3/2,-(i+j)*math.sqrt(3)/2*geometry.hexres)
			
			if hexfieldModel.hexfield[i][j].unit.type>0 then
				love.graphics.setColor(hexfieldModel.hexfield[i][j].unit.r,hexfieldModel.hexfield[i][j].unit.g,hexfieldModel.hexfield[i][j].unit.b)
				love.graphics.draw(graphicsModel.unit[hexfieldModel.hexfield[i][j].unit.type],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
				love.graphics.setLineWidth(5)
				if optionsModel.value("Show HP bars")=="always" or (xglow==i and yglow==j and glow and optionsModel.value("Show HP bars")) then
					local hpPercentage = hexfieldModel.hexfield[i][j].unit.hp/hexfieldModel.hexfield[i][j].unit.maxhp
					love.graphics.setColor(1,0,0)
					love.graphics.line( ((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64-geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64+geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2])
					love.graphics.setColor(0,1,0)
					love.graphics.line( ((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64-geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64+hpPercentage*geometry.hexres-geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2])
				end

				if optionsModel.value("HP numbers mode")~="none" and (optionsModel.value("Show HP numbers")=="always" or (xglow==i and yglow==j and glow and optionsModel.value("Show HP numbers"))) then
					local hpText = string.format("%d",hexfieldModel.hexfield[i][j].unit.hp)..(optionsModel.value("HP numbers mode")=="current and max hp" and string.format("/%d",hexfieldModel.hexfield[i][j].unit.maxhp) or "")
					love.graphics.setColor(0,0,0,0.5)
					love.graphics.rectangle("fill",((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64-geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+60-view.y-geometry.hexres*2/3)*view.scale+center[2],geometry.hexres*view.scale,18*view.scale,6*view.scale,6*view.scale)
					love.graphics.setColor(1,1,1)
					love.graphics.setFont(smallfont)
					love.graphics.printf(hpText,((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2],geometry.hexres,"center",0,view.scale,view.scale,geometry.hexres/2)
				end

				if hexfieldModel.hexfield[i][j].unit.bufflist~={} then
					love.graphics.setColor(1,1,1,1)
					local buffspot=0
					for k in pairs(hexfieldModel.hexfield[i][j].unit.bufflist) do
						love.graphics.draw(graphicsModel.buff[k],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64-geometry.hexres/2+buffspot*16)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres+geometry.hexres*math.sqrt(3)/2+40-view.y-geometry.hexres)*view.scale+center[2],0,view.scale)
						buffspot=buffspot+1
					end
				end
			end
			love.graphics.setColor(1,1,1,1)			
		end
	end


	if camdrag==false and glow then --drawing selection glow
		love.graphics.setColor(1,1,0.1)
		love.graphics.setLineWidth(3)
		geometry.hex((xglow-yglow)*geometry.hexres*3/2,-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres)
		if clickMode=='color' then
			love.graphics.setColor(1,1,1,drawalpha/2)
			geometry.hexfill((xglow-yglow)*geometry.hexres*3/2,-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres)
		elseif clickMode=='texture' and textureChosen~=0 then
			love.graphics.setColor(1,1,1,0.5)
			love.graphics.draw(graphicsModel.texture[textureChosen],((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
		elseif clickMode=='object' and objectChosen~=0 then
			love.graphics.setColor(1,1,1,0.5)
			drawObject(objectChosen,objectRotation,((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x+64)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y)*view.scale+center[2],view.scale)
		elseif clickMode=='unit' and unitChosen~=0 then
			love.graphics.setColor(1,1,1,0.5)
			love.graphics.draw(graphicsModel.unit[unitChosen],((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
		elseif clickMode=='unit drag' and unitdrag then
			love.graphics.setColor(1,1,1,0.5)
			love.graphics.draw(graphicsModel.unit[hexfieldModel.hexfield[dragtarget.x][dragtarget.y].unit.type],((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
		elseif clickMode=='object drag' and objectdrag then
			love.graphics.setColor(1,1,1,0.5)
			drawObject(hexfieldModel.hexfield[dragtarget.x][dragtarget.y].object.type,hexfieldModel.hexfield[dragtarget.x][dragtarget.y].object.rotation,((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x+64)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y+56)*view.scale+center[2],view.scale)

		end
	end
	
	love.graphics.setColor(0,0,0,1) --button panel
	love.graphics.rectangle('fill',width-panel,0,panel,height)

	love.graphics.setColor(1,1,1) --just info
	love.graphics.print("Scale: "..view.scale,width-panel+5)

	love.graphics.setColor(drawr,drawg,drawb,1) --color sample
	love.graphics.rectangle('fill',width-panel+20,50,100,100)

	--color sample border
	button({x=width-panel+20,y=50,width=100,height=100,highlight=(clickMode=='color'),lineWidth=3})

	love.graphics.setFont(smallfont)
	--"clear" button
	button({x=width-panel+20,y=160,width=60,height=20,highlight=(drawalpha==0),lineWidth=1,text='CLEAR'})
	--"cover all" button
	button({x=width-panel+100,y=160,width=100,height=20,highlight=false,lineWidth=1,text='COVER ALL'})
	--texture sample
	if textureChosen>0 then love.graphics.draw(graphicsModel.texture[textureChosen],width-panel+10,200) end
	--texture sample border
	if (love.mouse.getX()>width-panel+10 and love.mouse.getX()<width-panel+138 and love.mouse.getY()>200 and love.mouse.getY()<311) or clickMode=='texture' then
		love.graphics.setColor(0,0,1)
	else
		love.graphics.setColor(0,0,0.6)
	end
	love.graphics.setLineWidth(3)
	love.graphics.polygon('line',width-panel+42,200,width-panel+106,200,width-panel+138,256,width-panel+106,311,width-panel+42,311,width-panel+10,256)

	--"cover all" button for textures
	button({x=width-panel+20,y=320,width=100,height=20,highlight=false,lineWidth=1,text='COVER ALL'})

	--object sample
	if objectChosen>0 then drawObject (objectChosen,objectRotation,width-panel+74,406,1) end
	--object sample border
	button({x=width-panel+10,y=350,width=128,height=111,highlight=(clickMode=='object'),lineWidth=3})

	--rotation button
	love.graphics.setColor(1,1,1)
	love.graphics.draw(buttonRotate, width-panel+150,350)

	--hp button
	button({x=width-panel+150,y=500,width=50,height=50,highlight=(clickMode=='properties'),lineWidth=3,image=buttonHp})
	--delete button
	button({x=width-panel+150,y=560,width=50,height=50,highlight=(clickMode=='unit delete'),lineWidth=3,image=buttonDelete})
	--hand button
	button({x=width-panel+220,y=500,width=50,height=50,highlight=(clickMode=='unit drag'),lineWidth=3,image=buttonHand})
	--delete button for objects
	button({x=width-panel+150,y=410,width=50,height=50,highlight=(clickMode=='object delete'),lineWidth=3,image=buttonDelete})
	--hand button for objects
	button({x=width-panel+220,y=350,width=50,height=50,highlight=(clickMode=='object drag'),lineWidth=3,image=buttonHand})
	--paint button
	button({x=width-panel+220,y=560,width=50,height=50,highlight=(clickMode=='unit recolor'),lineWidth=3,image=buttonPaint,imageR=drawr,imageG=drawg,imageB=drawb})
	--unit sample
	button({x=width-panel+10,y=500,width=128,height=111,highlight=(clickMode=='unit'),lineWidth=3,image=graphicsModel.unit[unitChosen]})

	love.graphics.setColor(1,1,1)

	if height>=740 then
		--save button
		love.graphics.draw(buttonSave,width-panel+24,height-124)
		--load button
		love.graphics.draw(buttonLoad,width-panel+152,height-124)
	end

	love.graphics.draw(buttonOptions,0,0)
end

function map.wheelmoved(x,y)
	view.scale=view.scale+y*0.05
	if view.scale>=3 then
		view.scale=3
	end
	if view.scale<=0.1 then
		view.scale=0.1
	end
end

function map.mousepressed(x,y,button)
	if x<=80 and y<=80 and x>=0 and y>=0 then --options
		states.switch('option')
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==2 then --drag field
		camdrag=true
	elseif x>width-panel+10 and x<width-panel+120 and y>50 and y<150 and button==1 then --trigger coloring mode
		if clickMode~='color' then clickMode='color'
		else clickMode=0
		end
	elseif x>width-panel+10 and x<width-panel+138 and y>200 and y<311 and button==1 then --trigger retexture mode
		if clickMode~='texture' then clickMode='texture'
		else clickMode=0
		end
	elseif x>width-panel+10 and x<width-panel+138 and y>350 and y<461 and button==1 then --trigger object placement mode
		if clickMode~='object' then clickMode='object'
		else clickMode=0
		end		
	elseif x>width-panel+10 and x<width-panel+138 and y>500 and y<611 and button==1 then --trigger unit placement mode
		if clickMode~='unit' then clickMode='unit'
		else clickMode=0
		end
	elseif x>width-panel+150 and x<width-panel+200 and y>500 and y<550 and button==1 then --trigger hp setting mode
		if clickMode~='properties' then clickMode='properties'
		else clickMode=0
		end
	elseif x>width-panel+220 and x<width-panel+270 and y>500 and y<550 and button==1 then --trigger unit drag mode
		if clickMode~='unit drag' then clickMode='unit drag'
		else clickMode=0
		end
	elseif x>width-panel+220 and x<width-panel+270 and y>350 and y<400 and button==1 then --trigger object drag mode
		if clickMode~='object drag' then clickMode='object drag'
		else clickMode=0
		end
	elseif x>width-panel+220 and x<width-panel+270 and y>560 and y<610 and button==1 then --trigger unit recolor mode
		if clickMode~='unit recolor' then clickMode='unit recolor'
		else clickMode=0
		end
	elseif x>width-panel+150 and x<width-panel+200 and y>560 and y<610 and button==1 then --trigger unit delete mode
		if clickMode~='unit delete' then clickMode='unit delete'
		else clickMode=0
		end		
	elseif x>width-panel+150 and x<width-panel+200 and y>410 and y<460 and button==1 then --trigger object delete mode
		if clickMode~='object delete' then clickMode='object delete'
		else clickMode=0
		end		
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='color' and glow then --coloring
		hexfieldModel.backup()
		hexfieldModel.hexfield[xglow][yglow].color={drawr,drawg,drawb,drawalpha}
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='texture' and glow then --texture placement
		hexfieldModel.backup()
		hexfieldModel.hexfield[xglow][yglow].texture=textureChosen
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='object' and glow then --object placement
		hexfieldModel.backup()
		hexfieldModel.hexfield[xglow][yglow].object.type=objectChosen
		hexfieldModel.hexfield[xglow][yglow].object.rotation=objectRotation
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='properties' and hexfieldModel.hexfield[xglow][yglow].unit.type~=0 and glow then --hp set
		hexfieldModel.backup()
		states.switch('properties',{target=hexfieldModel.hexfield[xglow][yglow].unit})
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='unit drag' and hexfieldModel.hexfield[xglow][yglow].unit.type~=0 and glow then --drag initiation
		hexfieldModel.backup()
		unitdrag=true
		dragtarget={x=xglow,y=yglow}
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='object drag' and hexfieldModel.hexfield[xglow][yglow].object.type~=0 and glow then --obj drag initiation
		hexfieldModel.backup()
		objectdrag=true
		dragtarget={x=xglow,y=yglow}
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='unit' and glow then --unit placement
		hexfieldModel.backup()
		hexfieldModel.hexfield[xglow][yglow].unit.type=unitChosen
		hexfieldModel.hexfield[xglow][yglow].unit.hp=100
		hexfieldModel.hexfield[xglow][yglow].unit.maxhp=100
		hexfieldModel.hexfield[xglow][yglow].unit.r=1
		hexfieldModel.hexfield[xglow][yglow].unit.g=1
		hexfieldModel.hexfield[xglow][yglow].unit.b=1
		hexfieldModel.hexfield[xglow][yglow].unit.bufflist={}
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='unit delete' 
	and hexfieldModel.hexfield[xglow][yglow].unit.type~=0 and glow then --unit delete
		hexfieldModel.backup()
		hexfieldModel.hexfield[xglow][yglow].unit={type=0,hp=100,maxhp=100,r=1,g=1,b=1,bufflist={}}
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='object delete' 
	and hexfieldModel.hexfield[xglow][yglow].object.type~=0 and glow then --object delete
		hexfieldModel.backup()
		hexfieldModel.hexfield[xglow][yglow].object={type=0,rotation=0}
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and clickMode=='unit recolor' 
	and hexfieldModel.hexfield[xglow][yglow].unit.type~=0 and glow then --unit recolor
		hexfieldModel.backup()
		if drawalpha~=0 then
			hexfieldModel.hexfield[xglow][yglow].unit.r=drawr
			hexfieldModel.hexfield[xglow][yglow].unit.g=drawg
			hexfieldModel.hexfield[xglow][yglow].unit.b=drawb
		else
			hexfieldModel.hexfield[xglow][yglow].unit.r=1
			hexfieldModel.hexfield[xglow][yglow].unit.g=1
			hexfieldModel.hexfield[xglow][yglow].unit.b=1
		end
	elseif (x>width-panel+10 and x<width-panel+120 and y>50 and y<150) and button==2 then
	 --switch to palette mode
		states.switch("palette",{r=drawr,g=drawg,b=drawb,alpha=drawalpha,clickMode='color',rememberedMouseX=x,rememberedMouseY=y})
	elseif (x>width-panel+220 and x<width-panel+270 and y>560 and y<610) and button==2 then
		states.switch("palette",{r=drawr,g=drawg,b=drawb,alpha=drawalpha,clickMode='unit recolor',rememberedMouseX=x,rememberedMouseY=y})
	elseif x>width-panel+10 and x<width-panel+138 and y>200 and y<311 and button==2 then --switch to texture mode
		states.switch("selection",{item="texture",rememberedMouseX=x,rememberedMouseY=y})
	elseif x>width-panel+10 and x<width-panel+138 and y>350 and y<461 and button==2 then --switch to object mode
		states.switch("selection",{item="object",rememberedMouseX=x,rememberedMouseY=y})
	elseif x>width-panel+10 and x<width-panel+138 and y>500 and y<611 and button==2 then --switch to unit mode
		states.switch("selection",{item="unit",rememberedMouseX=x,rememberedMouseY=y})
	elseif height>=740 and x>width-panel+24 and x<width-panel+124 and y>height-124 and y<height-24 and button==1 then --switch to save mode
		states.switch("saveload",{mode="save"})
	elseif height>=740 and x>width-panel+152 and x<width-panel+252 and y>height-124 and y<height-24 and button==1 then --switch to load mode
		states.switch("saveload",{mode="load"})
	elseif x>width-panel+20 and x<width-panel+80 and y>160 and y<180 and button==1 then
		if drawalpha>0 then alphatemp=drawalpha drawalpha=0
		else drawalpha=alphatemp
		end
	elseif x>width-panel+150 and x<width-panel+200 and y>350 and y<400 and button==1 then
		objectRotation=(objectRotation-1)%6
	elseif x>width-panel+150 and x<width-panel+200 and y>350 and y<400 and button==2 then
		objectRotation=(objectRotation+1)%6
	elseif x>width-panel+100 and x<width-panel+200 and y>160 and y<180 and button==1 then
		hexfieldModel.colorAll(drawr,drawg,drawb,drawalpha)
	elseif x>width-panel+20 and x<width-panel+120 and y>320 and y<340 then
		hexfieldModel.backup()
		for i=-hexsize,hexsize do
				for j=-hexsize,hexsize do
					hexfieldModel.hexfield[i][j].texture=textureChosen
				end
		end
	end
end

function map.mousereleased(x,y,button)
	if button==2 then
		camdrag=false
	end

	if button==1 and clickMode=='unit drag' and unitdrag then
		if x<=(width-panel) and x>=0 and y>=0 and y<=height and hexfieldModel.hexfield[xglow][yglow].unit.type==0 then
			hexfieldModel.hexfield[xglow][yglow].unit=hexfieldModel.hexfield[dragtarget.x][dragtarget.y].unit
			hexfieldModel.hexfield[dragtarget.x][dragtarget.y].unit={type=0,hp=100,maxhp=100,r=255,g=255,b=255,bufflist={}}
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height then
			local tmpunit=hexfieldModel.hexfield[xglow][yglow].unit
			hexfieldModel.hexfield[xglow][yglow].unit=hexfieldModel.hexfield[dragtarget.x][dragtarget.y].unit
			hexfieldModel.hexfield[dragtarget.x][dragtarget.y].unit=tmpunit
		end
		unitdrag=false
	end

	if button==1 and clickMode=='object drag' and objectdrag then
		if x<=(width-panel) and x>=0 and y>=0 and y<=height and hexfieldModel.hexfield[xglow][yglow].object.type==0 then
			hexfieldModel.hexfield[xglow][yglow].object=hexfieldModel.hexfield[dragtarget.x][dragtarget.y].object
			hexfieldModel.hexfield[dragtarget.x][dragtarget.y].object={type=0,rotation=0}
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height then
			local tmpobject=hexfieldModel.hexfield[xglow][yglow].object
			hexfieldModel.hexfield[xglow][yglow].object=hexfieldModel.hexfield[dragtarget.x][dragtarget.y].object
			hexfieldModel.hexfield[dragtarget.x][dragtarget.y].object=tmpobject
		end
		objectdrag=false
	end
end

function map.mousemoved(x,y,dx,dy)
	if camdrag then
		view.x=view.x-dx/view.scale
		view.y=view.y-dy/view.scale
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and clickMode=='color' and glow and love.mouse.isDown(1) then --coloring
		hexfieldModel.hexfield[xglow][yglow].color={drawr,drawg,drawb,drawalpha}
	elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and clickMode=='texture' and glow and love.mouse.isDown(1) then --coloring
		hexfieldModel.hexfield[xglow][yglow].texture=textureChosen
	end
end

return map