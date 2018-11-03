---------------------------
--Hexagonal field
---------------------------
--by spellsweaver@gmail.com
----------------------------
--1.3.5
----------------------------
local utf8 = require("utf8")
local states = require("states")
local fileHelper = require("fileHelper")
local geometry = require("hexagonalGeometryHelper")
local deepcopy = require("deepcopy")
require("fonts")

function fieldReset()
	lastsavename=""
	love.window.setTitle("Hexfield")
		for i=-hexsize,hexsize do
			hexfield[i]={}
			for j=-hexsize,hexsize do
				hexfield[i][j]=
				{
					color={0,0,0,0},
					texture=1,
					object=
						{
							type=0,
							rotation=0
						},
					unit=
						{
							type=0,
							hp=100,
							maxhp=100,
							r=1,
							g=1,
							b=1,
							bufflist={},
							text='',
						}
				}
			end
		end
end

function autosave()
	fileHelper.saveTable("maps/autosave.hxm", hexfield)
	fileHelper.saveTable("options.json", options)
	return false
end

function backup()
	hexfield_backup=deepcopy(hexfield)
end

function restore()
	if hexfield_backup then
		local tmp=hexfield
		hexfield=hexfield_backup
		hexfield_backup=tmp
	end
end

function love.load()
	states.setup()
	offset=0
	local _, _, flags = love.window.getMode()
	width, height = love.window.getDesktopDimensions(flags.display)
	love.window.setMode (width,height,{fullscreen=false,vsync=true,resizable=true,borderless=false,centered=true})
	love.window.maximize()
	width,height = love.graphics.getDimensions()
	love.window.setTitle ("Hexagonal field")
	panel=300
	center={math.floor((width-panel)/2),math.floor(height/2)}
	view={scale=1,x=0,y=0}
	camdrag=false
	glow=false
	geometry.hexres=64 --hexagon's side
	--images for tiles should be 2*geometry.hexres wide and geometry.hexres*sqrt(3) high to be displayed properly
	hexsize=50 --this means that we'll have a field of [-hexsize..hexsize] x [-hexsize..hexsize]
	hexfield={}
	--x is to the right and up, y is to the left and up
	fieldReset()
	screen_mode='main'
	click_mode=nil
	texture={}
	local i=1
	while love.filesystem.getInfo("textures/"..i..".png") do
				texture[i]=love.graphics.newImage("textures/"..i..".png")		
				i=i+1
	end

	i=1
	object_graph={}
	while love.filesystem.getInfo("objects/"..i..".png") do
				object_graph[i]=love.graphics.newImage("objects/"..i..".png")		
				i=i+1
	end

	button_rotate=love.graphics.newImage("buttons/rotate.png")
	button_hp=love.graphics.newImage("buttons/heart.png")
	button_hand=love.graphics.newImage("buttons/hand.png")
	button_delete=love.graphics.newImage("buttons/delete.png")
	button_paint=love.graphics.newImage("buttons/paint.png")
	button_save=love.graphics.newImage("buttons/save.png")
	button_load=love.graphics.newImage("buttons/load.png")
	button_options=love.graphics.newImage("buttons/options.png")

	i=1
	unit_graph={}
	while love.filesystem.getInfo("units/"..i..".png") do
				unit_graph[i]=love.graphics.newImage("units/"..i..".png")		
				i=i+1
	end

	i=1
	buff_graph={}
	while love.filesystem.getInfo("buffs/"..i..".png") do
				buff_graph[i]=love.graphics.newImage("buffs/"..i..".png")		
				i=i+1
	end

	map_savefile={}

	love.filesystem.createDirectory("maps")
	lastsavename=""

	local defaultOptions =
	{
		{name = "Show HP bars", values = {true,"always",false}, currentValue = 1},
		{name = "Show HP numbers", values = {true,"always",false}, currentValue = 1},
		{name = "HP numbers mode", values = {"none", "current hp only", "current and max hp"}, currentValue = 1},
		{name = "HP setting", values = {"integer values", "real values", "percentage"}, currentValue = 1}
	}

	options = fileHelper.loadTable("options.json") or {}

	--creating backwards compatibility in case of added options or option values
	for k,v in pairs(defaultOptions) do
		if not options[k] then
			options[k] = deepcopy(v)
		else
			options[k].values = deepcopy(v.values)
		end
	end

	function optionValue(optionName)
		for k,v in pairs(options) do
			if v.name == optionName then
				return v.values[v.currentValue]
			end
		end
	end

	drawr,drawg,drawb=1,1,1;
	drawalpha=0.5;
	texture_chosen=1;

	textures_fit_x=math.floor(width/geometry.hexres/2)
	textures_fit_y=math.floor(height/geometry.hexres/2)

	object_chosen=1
	object_rot=0

	unit_chosen=1

	flashPeriod = 0.5
	flashTimeElapsed = 0
	flashingSymbol = true
end

function mousepos()
	local x, y = love.mouse.getPosition()
	local x2=(x-center[1])/view.scale+view.x
	local y2=(y-center[2])/view.scale+view.y
	return x2,y2
end

function draw_object(index,rot,x,y,zoom)
	love.graphics.draw(object_graph[index],x,y,math.rad(rot*60),zoom,zoom,geometry.hexres,geometry.hexres*math.sqrt(3)/2)
end

function love.keypressed(key,scancode)
	if key == "escape" then
		if screen_mode == 'main' then
				love.event.quit()
			else 
				screen_mode = 'main'
			end
	elseif key == "backspace" then
		if screen_mode=='save' then
			-- get the byte offset to the last UTF-8 character in the string.
			local byteoffset = utf8.offset(filetointeract, -1)

			if byteoffset then
					-- remove the last UTF-8 character.
					-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
					filetointeract = string.sub(filetointeract, 1, byteoffset - 1)
			end
		elseif screen_mode=='maxhpset' then
			local byteoffset = utf8.offset(maxhpnumber, -1)
	 
			if byteoffset then
					-- remove the last UTF-8 character.
					-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
					maxhpnumber = string.sub(maxhpnumber, 1, byteoffset - 1)
			end
		end
	elseif (key == "return" or key == "kpenter") and screen_mode=='save' and filetointeract~="" then
		fileHelper.saveTable("maps/"..filetointeract..".hxm",hexfield)
		lastsavename=filetointeract..".hxm"
		screen_mode='main'
	elseif key == "up" and (screen_mode=='texture' or screen_mode=='object' or screen_mode=='unit' or screen_mode=='saveload') then
		offset=math.max(0,offset-1)
	elseif key == "down" and (screen_mode=='texture' or screen_mode=='object' or screen_mode=='unit' or screen_mode=='saveload') then
		offset=math.max(0,offset+1)
	elseif screen_mode=='main' and --Ctrl + S
	scancode == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
	and (not love.keyboard.isDown("rshift") and not love.keyboard.isDown("lshift") or lastsavename=="") then
		screen_mode='saveload'
		offset=0
		saving=true
		map_savefile={}
		local fileinfolder=love.filesystem.getDirectoryItems("maps")
		for k,v in pairs(fileinfolder) do
			if v:sub(-4)==".hxm" then
				map_savefile[#map_savefile+1]=v
			end
		end
		map_savefile[#map_savefile+1]=""
	elseif screen_mode=='main' and --Ctrl + Shift + S
	scancode == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
	and (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") and lastsavename~="") then
			filetointeract=lastsavename
			screen_mode='overwrite'
	elseif screen_mode=='main' and --Ctrl + O
	scancode == "o" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
	and not love.keyboard.isDown("rshift") and not love.keyboard.isDown("lshift") then
		screen_mode='saveload'
		offset=0
		saving=false
		map_savefile={}
		local fileinfolder=love.filesystem.getDirectoryItems("maps")
		for k,v in pairs(fileinfolder) do
			if v:sub(-4)==".hxm" then
				map_savefile[#map_savefile+1]=v
			end
		end
	elseif screen_mode=='main' and --Ctrl + Shift + O
	scancode == "o" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
	and (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")) then
		love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/maps")
	elseif screen_mode=='main' and --Ctrl + N
	scancode == "n" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		autosave()
		fieldReset()
		backup()
	elseif screen_mode=='main' and --Ctrl + Z
	scancode == "z" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		restore()
		end
end

function love.draw()

	local function button(options)
		local x = options.x or 0
		local y = options.y or 0
		local buttonWidth = options.width or 0
		local buttonHeight = options.height or 0
		local highlight = options.highlight or false
		local unhighlight = options.unhighlight or false
		local text = options.text
		local lineWidth = options.lineWidth or 1
		local image = options.image
		local imageR,imageG,imageB = options.imageR or 1, options.imageG or 1, options.imageB or 1
		local colorBasic = options.colorBasic or {0,0,0.45}
		local colorHighlit = options.colorHighlit or {0,0,1}

		if ((love.mouse.getX()>x and love.mouse.getX()<x+buttonWidth
		and love.mouse.getY()>y and love.mouse.getY()<y+buttonHeight) or highlight)
		and not unhighlight then
			love.graphics.setColor(unpack(colorHighlit))
		else
			love.graphics.setColor(unpack(colorBasic))
		end
		love.graphics.setLineWidth(lineWidth)
		love.graphics.rectangle('line',x,y,buttonWidth,buttonHeight)
		if text then
			love.graphics.printf(text,x,y+buttonHeight*0.5-10,buttonWidth,'center')
		end
		if image then
			love.graphics.setColor(imageR,imageG,imageB)
			love.graphics.draw(image,x+buttonWidth*0.5,y+buttonHeight*0.5,0,1,1,image:getWidth()*0.5,image:getHeight()*0.5)
		end
		love.graphics.setColor(1,1,1)
	end

	if screen_mode=='main' then
		love.graphics.setLineWidth(3)
		love.graphics.setColor(0.2,0.3,1)
		love.graphics.line(width-panel, 0, width-panel, height)

		for i=-hexsize,hexsize do --drawing grid
			for j=-hexsize,hexsize do
				love.graphics.setColor(1,1,1)

				if hexfield[i][j].texture and hexfield[i][j].texture>0 then
					love.graphics.draw(texture[hexfield[i][j].texture],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
				end
				if hexfield[i][j].object.type>0 then
					draw_object(hexfield[i][j].object.type,hexfield[i][j].object.rotation,((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y)*view.scale+center[2],view.scale)
				end
				love.graphics.setColor(hexfield[i][j].color[1],hexfield[i][j].color[2],hexfield[i][j].color[3],hexfield[i][j].color[4])
				geometry.hexfill((i-j)*geometry.hexres*3/2,-(i+j)*math.sqrt(3)/2*geometry.hexres)
				love.graphics.setColor(1-hexfield[i][j].color[1],1-hexfield[i][j].color[2],1-hexfield[i][j].color[3],1)
				love.graphics.setLineWidth(1)
				geometry.hex((i-j)*geometry.hexres*3/2,-(i+j)*math.sqrt(3)/2*geometry.hexres)
				
				if hexfield[i][j].unit.type>0 then
					love.graphics.setColor(hexfield[i][j].unit.r,hexfield[i][j].unit.g,hexfield[i][j].unit.b)
					love.graphics.draw(unit_graph[hexfield[i][j].unit.type],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
					love.graphics.setLineWidth(5)
					if optionValue("Show HP bars")=="always" or (xglow==i and yglow==j and glow and optionValue("Show HP bars")) then
						local hpPercentage = hexfield[i][j].unit.hp/hexfield[i][j].unit.maxhp
						love.graphics.setColor(1,0,0)
						love.graphics.line( ((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64-geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64+geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2])
						love.graphics.setColor(0,1,0)
						love.graphics.line( ((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64-geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64+hpPercentage*geometry.hexres-geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2])
					end

					if optionValue("HP numbers mode")~="none" and (optionValue("Show HP numbers")=="always" or (xglow==i and yglow==j and glow and optionValue("Show HP numbers"))) then
						local hpText = string.format("%d",hexfield[i][j].unit.hp)..(optionValue("HP numbers mode")=="current and max hp" and string.format("/%d",hexfield[i][j].unit.maxhp) or "")
						love.graphics.setColor(0,0,0,0.5)
						love.graphics.rectangle("fill",((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64-geometry.hexres/2)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+60-view.y-geometry.hexres*2/3)*view.scale+center[2],geometry.hexres*view.scale,18*view.scale,6*view.scale,6*view.scale)
						love.graphics.setColor(1,1,1)
						love.graphics.setFont(smallfont)
						love.graphics.printf(hpText,((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y-geometry.hexres*2/3)*view.scale+center[2],geometry.hexres,"center",0,view.scale,view.scale,geometry.hexres/2)
					end

					if hexfield[i][j].unit.bufflist~={} then
						love.graphics.setColor(1,1,1,1)
						local buffspot=0
						for k in pairs(hexfield[i][j].unit.bufflist) do
							love.graphics.draw(buff_graph[k],((i-j)*geometry.hexres*3/2-geometry.hexres-view.x+64-geometry.hexres/2+buffspot*16)*view.scale+center[1],(-(i+j)*math.sqrt(3)/2*geometry.hexres+geometry.hexres*math.sqrt(3)/2+40-view.y-geometry.hexres)*view.scale+center[2],0,view.scale)
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
			if click_mode=='color' then
				love.graphics.setColor(1,1,1,drawalpha/2)
				geometry.hexfill((xglow-yglow)*geometry.hexres*3/2,-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres)
			elseif click_mode=='texture' and texture_chosen~=0 then
				love.graphics.setColor(1,1,1,0.5)
				love.graphics.draw(texture[texture_chosen],((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
			elseif click_mode=='object' and object_chosen~=0 then
				love.graphics.setColor(1,1,1,0.5)
				draw_object(object_chosen,object_rot,((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x+64)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2+56-view.y)*view.scale+center[2],view.scale)
			elseif click_mode=='unit' and unit_chosen~=0 then
				love.graphics.setColor(1,1,1,0.5)
				love.graphics.draw(unit_graph[unit_chosen],((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
			elseif click_mode=='unit drag' and unitdrag then
				love.graphics.setColor(1,1,1,0.5)
				love.graphics.draw(unit_graph[hexfield[dragtarget.x][dragtarget.y].unit.type],((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y)*view.scale+center[2],0,view.scale)
			elseif click_mode=='object drag' and objectdrag then
				love.graphics.setColor(1,1,1,0.5)
				draw_object(hexfield[dragtarget.x][dragtarget.y].object.type,hexfield[dragtarget.x][dragtarget.y].object.rotation,((xglow-yglow)*geometry.hexres*3/2-geometry.hexres-view.x+64)*view.scale+center[1],(-(xglow+yglow)*math.sqrt(3)/2*geometry.hexres-geometry.hexres*math.sqrt(3)/2-view.y+56)*view.scale+center[2],view.scale)

			end
		end
		
		love.graphics.setColor(0,0,0,1) --button panel
		love.graphics.rectangle('fill',width-panel,0,panel,height)

		love.graphics.setColor(1,1,1) --just info
		love.graphics.print("Scale: "..view.scale,width-panel+5)

		love.graphics.setColor(drawr,drawg,drawb,1) --color sample
		love.graphics.rectangle('fill',width-panel+20,50,100,100)

		--color sample border
		button({x=width-panel+20,y=50,width=100,height=100,highlight=(click_mode=='color'),lineWidth=3})

		love.graphics.setFont(smallfont)
		--"clear" button
		button({x=width-panel+20,y=160,width=60,height=20,highlight=(drawalpha==0),lineWidth=1,text='CLEAR'})
		--"cover all" button
		button({x=width-panel+100,y=160,width=100,height=20,highlight=false,lineWidth=1,text='COVER ALL'})
		--texture sample
		if texture_chosen>0 then love.graphics.draw(texture[texture_chosen],width-panel+10,200) end
		--texture sample border
		if (love.mouse.getX()>width-panel+10 and love.mouse.getX()<width-panel+138 and love.mouse.getY()>200 and love.mouse.getY()<311) or click_mode=='texture' then
			love.graphics.setColor(0,0,1)
		else
			love.graphics.setColor(0,0,0.6)
		end
		love.graphics.setLineWidth(3)
		love.graphics.polygon('line',width-panel+42,200,width-panel+106,200,width-panel+138,256,width-panel+106,311,width-panel+42,311,width-panel+10,256)

		--"cover all" button for textures
		button({x=width-panel+20,y=320,width=100,height=20,highlight=false,lineWidth=1,text='COVER ALL'})

		--object sample
		if object_chosen>0 then draw_object (object_chosen,object_rot,width-panel+74,406,1) end
		--object sample border
		button({x=width-panel+10,y=350,width=128,height=111,highlight=(click_mode=='object'),lineWidth=3})

		--rotation button
		love.graphics.setColor(1,1,1)
		love.graphics.draw(button_rotate, width-panel+150,350)

		--hp button
		button({x=width-panel+150,y=500,width=50,height=50,highlight=(click_mode=='properties'),lineWidth=3,image=button_hp})
		--delete button
		button({x=width-panel+150,y=560,width=50,height=50,highlight=(click_mode=='unit delete'),lineWidth=3,image=button_delete})
		--hand button
		button({x=width-panel+220,y=500,width=50,height=50,highlight=(click_mode=='unit drag'),lineWidth=3,image=button_hand})
		--delete button for objects
		button({x=width-panel+150,y=410,width=50,height=50,highlight=(click_mode=='object delete'),lineWidth=3,image=button_delete})
		--hand button for objects
		button({x=width-panel+220,y=350,width=50,height=50,highlight=(click_mode=='object drag'),lineWidth=3,image=button_hand})
		--paint button
		button({x=width-panel+220,y=560,width=50,height=50,highlight=(click_mode=='unit recolor'),lineWidth=3,image=button_paint,imageR=drawr,imageG=drawg,imageB=drawb})
		--unit sample
		button({x=width-panel+10,y=500,width=128,height=111,highlight=(click_mode=='unit'),lineWidth=3,image=unit_graph[unit_chosen]})

		love.graphics.setColor(1,1,1)

		if height>=740 then
			--save button
			love.graphics.draw(button_save,width-panel+24,height-124)
			--load button
			love.graphics.draw(button_load,width-panel+152,height-124)
		end

		love.graphics.draw(button_options,0,0)

	elseif screen_mode=='palette' then
		love.graphics.setLineWidth(9)
		love.graphics.setColor(1,0,0,1)
		love.graphics.line(100, 100, 355, 100);

		love.graphics.setColor(0,1,0,1)
		love.graphics.line(100, 200, 355, 200);


		love.graphics.setColor(0,0,1,1)
		love.graphics.line(100, 300, 355, 300);

		love.graphics.setColor(1,1,1,1)
		love.graphics.line(100, 400, 355, 400);	

		love.graphics.print("RED",365,100);
		love.graphics.print("GREEN",365,200);
		love.graphics.print("BLUE",365,300);
		love.graphics.print("TRANSPARENCY",365,400);

		love.graphics.setLineWidth(3)
		love.graphics.line(100+drawr*255,93,100+drawr*255,108);
		love.graphics.line(100+drawg*255,193,100+drawg*255,208);
		love.graphics.line(100+drawb*255,293,100+drawb*255,308);
		love.graphics.line(355-drawalpha*255,393,355-drawalpha*255,408);
		love.graphics.setColor(drawr,drawg,drawb,1)
		love.graphics.rectangle('fill',center[1],0,center[1],height);

		button({x=100,y=500,width=255,height=100,lineWidth=3,text='APPLY'})
		button({x=100,y=650,width=255,height=100,lineWidth=3,text='PAINT ALL'})

	elseif screen_mode=='texture' then
		love.graphics.setColor(1,1,1)
		for i=1,#texture do
			love.graphics.draw(texture[i],((i-1)%textures_fit_x)*2*geometry.hexres,(math.ceil(i/textures_fit_x)-1-offset)*geometry.hexres*math.sqrt(3)+20)

		end	
		love.graphics.setColor(0,0,1)
		if love.mouse.getX()<2*geometry.hexres*textures_fit_x and love.mouse.getY()<math.sqrt(3)*geometry.hexres*textures_fit_y then
			love.graphics.rectangle('line',2*geometry.hexres*(math.ceil(love.mouse.getX()/(geometry.hexres*2))-1),20+geometry.hexres*math.sqrt(3)*math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))),2*geometry.hexres,geometry.hexres*math.sqrt(3))
			love.graphics.setColor(1,1,1)
		end
	elseif screen_mode=='object' then
		love.graphics.setColor(1,1,1)
		for i=1,#object_graph do
			love.graphics.draw(object_graph[i],((i-1)%textures_fit_x)*2*geometry.hexres,(math.ceil(i/textures_fit_x)-1-offset)*geometry.hexres*math.sqrt(3)+20)
		end	
		love.graphics.setColor(0,0,1)
		if love.mouse.getX()<2*geometry.hexres*textures_fit_x and love.mouse.getY()<math.sqrt(3)*geometry.hexres*textures_fit_y then
			love.graphics.rectangle('line',2*geometry.hexres*(math.ceil(love.mouse.getX()/(geometry.hexres*2))-1),20+geometry.hexres*math.sqrt(3)*math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))),2*geometry.hexres,geometry.hexres*math.sqrt(3))
			love.graphics.setColor(1,1,1)
		end
	elseif screen_mode=='unit' then
		love.graphics.setColor(1,1,1)
		for i=1,#unit_graph do
			love.graphics.draw(unit_graph[i],((i-1)%textures_fit_x)*2*geometry.hexres,(math.ceil(i/textures_fit_x)-1-offset)*geometry.hexres*math.sqrt(3)+20)
		end	
		love.graphics.setColor(0,0,1)
		if love.mouse.getX()<2*geometry.hexres*textures_fit_x and love.mouse.getY()<math.sqrt(3)*geometry.hexres*textures_fit_y then	
			love.graphics.rectangle('line',2*geometry.hexres*(math.ceil(love.mouse.getX()/(geometry.hexres*2))-1),20+geometry.hexres*math.sqrt(3)*math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))),2*geometry.hexres,geometry.hexres*math.sqrt(3))
			love.graphics.setColor(1,1,1)
		end
	elseif screen_mode=='properties' then
		love.graphics.setLineWidth(11)
		love.graphics.setColor(1,0,0)
		love.graphics.line(width/3, height/2, 2*width/3, height/2)
		love.graphics.setColor(0,1,0)
		love.graphics.line(width/3, height/2, width/3*(1+hexfield[hptarget.x][hptarget.y].unit.hp/hexfield[hptarget.x][hptarget.y].unit.maxhp), height/2)

		button({x=width/2-75,y=height/2+100,width=150,height=50,lineWidth=3,text='OK'})
		local hpString
		if optionValue("HP setting")=="percentage" then
			hpString=string.format("%.1f",(100*hexfield[hptarget.x][hptarget.y].unit.hp/hexfield[hptarget.x][hptarget.y].unit.maxhp)).."%"
		elseif optionValue("HP setting")=="integer values" then
			hpString=string.format("%d",hexfield[hptarget.x][hptarget.y].unit.hp)
		elseif optionValue("HP setting")=="real values" then
			hpString=string.format("%.1f",hexfield[hptarget.x][hptarget.y].unit.hp)
		end
		love.graphics.print(hpString,width/2-15,height/2+20);

		button({x=width*2/3+50,y=height/2-30,width=120,height=60,lineWidth=3,text='Max HP = '..hexfield[hptarget.x][hptarget.y].unit.maxhp})

		love.graphics.setColor(1,1,1)
		love.graphics.setLineWidth(1)
		love.graphics.rectangle('line',width/2-128,height/2-356,256,256)

		for i=1,#buff_graph do

			if (love.mouse.getX()>((i-1)%8)*32+width/2-128 and love.mouse.getX()<((i-1)%8)*32+width/2-96 and love.mouse.getY()>(math.ceil(i/8)-1)*32+height/2-356 and love.mouse.getY()<(math.ceil(i/8)-1)*32+height/2-324) or hexfield[hptarget.x][hptarget.y].unit.bufflist[i] then
				love.graphics.setColor(1,1,1)
				love.graphics.rectangle('fill',((i-1)%8)*32+width/2-128,(math.ceil(i/8)-1)*32+height/2-356,32,32)
			end
			love.graphics.draw(buff_graph[i],((i-1)%8)*32+width/2-128,(math.ceil(i/8)-1)*32+height/2-356,0,2)
		end

	elseif screen_mode=='saveload' then	
		love.graphics.setColor(1,1,1)
		for i=1,#map_savefile-1 do
			love.graphics.draw(button_load,((i-1)%textures_fit_x)*2*geometry.hexres+14,(math.ceil(i/textures_fit_x)-1-offset)*geometry.hexres*math.sqrt(3)+20)
			local filename_shown
			if map_savefile[i]:len()>15 then filename_shown=map_savefile[i]:sub(1,12).."..." else filename_shown=map_savefile[i] end
			love.graphics.printf(filename_shown,((i-1)%textures_fit_x)*2*geometry.hexres,(math.ceil(i/textures_fit_x)-offset)*geometry.hexres*math.sqrt(3),2*geometry.hexres,"center")
		end
		local i=#map_savefile
		if saving then
			love.graphics.draw(button_save,((i-1)%textures_fit_x)*2*geometry.hexres+14,(math.ceil(i/textures_fit_x)-1-offset)*geometry.hexres*math.sqrt(3)+20)
			love.graphics.printf("NEW FILE",((i-1)%textures_fit_x)*2*geometry.hexres,(math.ceil(i/textures_fit_x)-offset)*geometry.hexres*math.sqrt(3),2*geometry.hexres,"center")
		elseif i>0 then
			love.graphics.draw(button_load,((i-1)%textures_fit_x)*2*geometry.hexres+14,(math.ceil(i/textures_fit_x)-1-offset)*geometry.hexres*math.sqrt(3)+20)
			if map_savefile[i]:len()>15 then filename_shown=map_savefile[i]:sub(1,12).."..." else filename_shown=map_savefile[i] end
			love.graphics.printf(filename_shown,((i-1)%textures_fit_x)*2*geometry.hexres,(math.ceil(i/textures_fit_x)-offset)*geometry.hexres*math.sqrt(3),2*geometry.hexres,"center")
		end

		if love.mouse.getX()<2*geometry.hexres*textures_fit_x and love.mouse.getY()<math.sqrt(3)*geometry.hexres*textures_fit_y then
			love.graphics.setColor(0,0,1)
			love.graphics.rectangle('line',2*geometry.hexres*(math.ceil(love.mouse.getX()/(geometry.hexres*2))-1),20+geometry.hexres*math.sqrt(3)*math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))),2*geometry.hexres,geometry.hexres*math.sqrt(3))
		end
		love.graphics.setColor(1,1,1)
	elseif screen_mode=='overwrite' then
		love.graphics.setColor(1,1,1)
		love.graphics.setFont(largefont)
		love.graphics.printf("You are going to overwrite:\n"..filetointeract,width/2-200,height/2-100,400,"center")
		love.graphics.setFont(smallfont)

		if (love.mouse.getX()>width/3-75 and love.mouse.getX()<width/3+75 and love.mouse.getY()>height/2+100 and love.mouse.getY()<height/2+150) then
			love.graphics.setColor(0,0,1)
		else
			love.graphics.setColor(0,0,0.6)
		end

		button({x=width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='OK'})
		button({x=2*width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='Cancel'})
		button({x=width-225,y=height-125,width=150,height=50,lineWidth=3,text='Delete',colorBasic={120,0,0},colorHighlit={255,0,0}})

	elseif screen_mode=='load' then
		love.graphics.setColor(1,1,1)
		love.graphics.setFont(largefont)
		love.graphics.printf("You are going to open:\n"..filetointeract.."\nUnsaved data will be lost!",width/2-200,height/2-100,400,"center")
		love.graphics.setFont(smallfont)

		button({x=width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='OK'})
		button({x=2*width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='Cancel'})
		button({x=width-225,y=height-125,width=150,height=50,lineWidth=3,text='Delete',colorBasic={120,0,0},colorHighlit={255,0,0}})

	elseif screen_mode=='save' then
		love.graphics.setColor(1,1,1)
		love.graphics.setFont(largefont)
		love.graphics.printf({{255,255,255},"Enter the name for a new file:\n"..filetointeract,(flashingSymbol and {255,255,255} or {0,0,0}),"|"},width/2-200,height/2-100,400,"center")
		love.graphics.setFont(smallfont)

		button({x=width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,unhighlight=(filetointeract==""),text='OK'})
		button({x=2*width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='Cancel'})
	elseif screen_mode=='maxhpset' then
		love.graphics.setColor(1,1,1)
		love.graphics.setFont(largefont)
		love.graphics.printf({{255,255,255},"Input new max HP (only numbers accepted):\n"..maxhpnumber,(flashingSymbol and {255,255,255} or {0,0,0}),"|"},width/2-200,height/2-100,400,"center")
		love.graphics.setFont(smallfont)

		button({x=width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='OK'})
		button({x=2*width/3-75,y=height/2+100,width=150,height=50,lineWidth=3,text='Cancel'})
	elseif screen_mode=='options' then
		local buttonPosition = 0
		for i=1,#options do
			button({x=300,y=i*60-30,width=width-600,height=30,lineWidth=3,text=options[i].name.." : "..tostring(options[i].values[options[i].currentValue])})
		end
	end


end

function love.update( dt )
	if screen_mode=='main' then
		local mx,my=mousepos()
		local xhex,yhex=geometry.hexcoord(mx,my)
		xglow,yglow=geometry.hextarget(xhex,yhex)
		local x, y = love.mouse.getPosition()
		if  x<=(width-panel) and x>=0 and y>=0 and y<=height and xglow<=hexsize and xglow>=-hexsize and yglow>=-hexsize and yglow<=hexsize then
			glow=true
		else glow=false
		end
	end

	flashTimeElapsed = flashTimeElapsed + dt
	if flashTimeElapsed > flashPeriod then
		flashTimeElapsed = flashTimeElapsed - flashPeriod
		flashingSymbol = not flashingSymbol
	end

end

function love.wheelmoved(x,y)
	if screen_mode=='main' then
			view.scale=view.scale+y*0.05
			if view.scale>=3 then
				view.scale=3
			end
			if view.scale<=0.1 then
				view.scale=0.1
			end
	elseif screen_mode=='texture' or screen_mode=='object' or screen_mode=='unit' or screen_mode=='saveload' then
		offset=math.max(offset-y,0)
	end
end

function love.mousepressed( x, y, button )
	if screen_mode=='main' then
		if x<=80 and y<=80 and x>=0 and y>=0 then --options
			screen_mode = 'options'
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==2 then --drag field
			camdrag=true
		elseif x>width-panel+10 and x<width-panel+120 and y>50 and y<150 and button==1 then --trigger coloring mode
			if click_mode~='color' then click_mode='color'
			else click_mode=0
			end
		elseif x>width-panel+10 and x<width-panel+138 and y>200 and y<311 and button==1 then --trigger retexture mode
			if click_mode~='texture' then click_mode='texture'
			else click_mode=0
			end
		elseif x>width-panel+10 and x<width-panel+138 and y>350 and y<461 and button==1 then --trigger object placement mode
			if click_mode~='object' then click_mode='object'
			else click_mode=0
			end		
		elseif x>width-panel+10 and x<width-panel+138 and y>500 and y<611 and button==1 then --trigger unit placement mode
			if click_mode~='unit' then click_mode='unit'
			else click_mode=0
			end
		elseif x>width-panel+150 and x<width-panel+200 and y>500 and y<550 and button==1 then --trigger hp setting mode
			if click_mode~='properties' then click_mode='properties'
			else click_mode=0
			end
		elseif x>width-panel+220 and x<width-panel+270 and y>500 and y<550 and button==1 then --trigger unit drag mode
			if click_mode~='unit drag' then click_mode='unit drag'
			else click_mode=0
			end
		elseif x>width-panel+220 and x<width-panel+270 and y>350 and y<400 and button==1 then --trigger object drag mode
			if click_mode~='object drag' then click_mode='object drag'
			else click_mode=0
			end
		elseif x>width-panel+220 and x<width-panel+270 and y>560 and y<610 and button==1 then --trigger unit recolor mode
			if click_mode~='unit recolor' then click_mode='unit recolor'
			else click_mode=0
			end
		elseif x>width-panel+150 and x<width-panel+200 and y>560 and y<610 and button==1 then --trigger unit delete mode
			if click_mode~='unit delete' then click_mode='unit delete'
			else click_mode=0
			end		
		elseif x>width-panel+150 and x<width-panel+200 and y>410 and y<460 and button==1 then --trigger object delete mode
			if click_mode~='object delete' then click_mode='object delete'
			else click_mode=0
			end		
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='color' and glow then --coloring
			backup()
			hexfield[xglow][yglow].color={drawr,drawg,drawb,drawalpha}
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='texture' and glow then --texture placement
			backup()
			hexfield[xglow][yglow].texture=texture_chosen
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='object' and glow then --object placement
			backup()
			hexfield[xglow][yglow].object.type=object_chosen
			hexfield[xglow][yglow].object.rotation=object_rot
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='properties' and hexfield[xglow][yglow].unit.type~=0 and glow then --hp set
			backup()
			hptarget={x=xglow,y=yglow}
			screen_mode='properties'
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='unit drag' and hexfield[xglow][yglow].unit.type~=0 and glow then --drag initiation
			backup()
			unitdrag=true
			dragtarget={x=xglow,y=yglow}
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='object drag' and hexfield[xglow][yglow].object.type~=0 and glow then --obj drag initiation
			backup()
			objectdrag=true
			dragtarget={x=xglow,y=yglow}
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='unit' and glow then --unit placement
			backup()
			hexfield[xglow][yglow].unit.type=unit_chosen
			hexfield[xglow][yglow].unit.hp=100
			hexfield[xglow][yglow].unit.maxhp=100
			hexfield[xglow][yglow].unit.r=1
			hexfield[xglow][yglow].unit.g=1
			hexfield[xglow][yglow].unit.b=1
			hexfield[xglow][yglow].unit.bufflist={}
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='unit delete' and hexfield[xglow][yglow].unit.type~=0 and glow then --unit delete
			backup()
			hexfield[xglow][yglow].unit={type=0,hp=100,maxhp=100,r=1,g=1,b=1,bufflist={}}
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='object delete' and hexfield[xglow][yglow].object.type~=0 and glow then --unit delete
			backup()
			hexfield[xglow][yglow].object={type=0,rotation=0}
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and button==1 and click_mode=='unit recolor' and hexfield[xglow][yglow].unit.type~=0 and glow then --unit recolor
			backup()
			if drawalpha~=0 then
				hexfield[xglow][yglow].unit.r=drawr
				hexfield[xglow][yglow].unit.g=drawg
				hexfield[xglow][yglow].unit.b=drawb
			else
				hexfield[xglow][yglow].unit.r=1
				hexfield[xglow][yglow].unit.g=1
				hexfield[xglow][yglow].unit.b=1
			end
		elseif (x>width-panel+10 and x<width-panel+120 and y>50 and y<150) or (x>width-panel+220 and x<width-panel+270 and y>560 and y<610) and button==2 then
		 --switch to palette mode
			screen_mode='palette'
		elseif x>width-panel+10 and x<width-panel+138 and y>200 and y<311 and button==2 then --switch to texture mode
			screen_mode='texture'
			offset=0
		elseif x>width-panel+10 and x<width-panel+138 and y>350 and y<461 and button==2 then --switch to object mode
			screen_mode='object'
			offset=0
		elseif x>width-panel+10 and x<width-panel+138 and y>500 and y<611 and button==2 then --switch to unit mode
			screen_mode='unit'
			offset=0
		elseif height>=740 and x>width-panel+24 and x<width-panel+124 and y>height-124 and y<height-24 and button==1 then --switch to save mode
			screen_mode='saveload'
			offset=0
			saving=true
			map_savefile={}
			local fileinfolder=love.filesystem.getDirectoryItems("maps")
			for k,v in pairs(fileinfolder) do
				if v:sub(-4)==".hxm" then
					map_savefile[#map_savefile+1]=v
				end
			end
			map_savefile[#map_savefile+1]=""

		elseif height>=740 and x>width-panel+152 and x<width-panel+252 and y>height-124 and y<height-24 and button==1 then --switch to load mode
			screen_mode='saveload'
			offset=0
			saving=false
			map_savefile={}
			local fileinfolder=love.filesystem.getDirectoryItems("maps")
			for k,v in pairs(fileinfolder) do
				if v:sub(-4)==".hxm" then
					map_savefile[#map_savefile+1]=v
				end
			end

		elseif x>width-panel+20 and x<width-panel+80 and y>160 and y<180 and button==1 then
			if drawalpha>0 then alphatemp=drawalpha drawalpha=0
			else drawalpha=alphatemp
			end
		elseif x>width-panel+150 and x<width-panel+200 and y>350 and y<400 and button==1 then
			backup()
			object_rot=(object_rot-1)%6
		elseif x>width-panel+150 and x<width-panel+200 and y>350 and y<400 and button==2 then
			backup()
			object_rot=(object_rot+1)%6
		elseif x>width-panel+100 and x<width-panel+200 and y>160 and y<180 and button==1 then
			backup()
			for i=-hexsize,hexsize do
						for j=-hexsize,hexsize do
							hexfield[i][j].color={drawr,drawg,drawb,drawalpha}
						end
				end
			elseif x>width-panel+20 and x<width-panel+120 and y>320 and y<340 then
				backup()
				for i=-hexsize,hexsize do
						for j=-hexsize,hexsize do
							hexfield[i][j].texture=texture_chosen
						end
				end
		end
	elseif screen_mode=='palette' and button==1 then
		if x>=100 and x<=355 then
			if y>90 and y<110 then
				drawr=(x-100)/255
			elseif y>190 and y<210 then
				drawg=(x-100)/255
			elseif y>290 and y<310 then
				drawb=(x-100)/255
			elseif y>390 and y<410 then
				drawalpha=(355-x)/255
			elseif y>500 and y<600 then
				screen_mode='main'
				love.mouse.setPosition(width-panel+65,100)
			elseif y>650 and y<750 then
				screen_mode='main'
				for i=-hexsize,hexsize do
						for j=-hexsize,hexsize do
							hexfield[i][j].color={drawr,drawg,drawb,drawalpha}
						end
					end
			end
		end --color settings
	elseif screen_mode=='texture' and button==1 and love.mouse.getX()<2*geometry.hexres*textures_fit_x and love.mouse.getY()<math.sqrt(3)*geometry.hexres*textures_fit_y then
		texture_chosen=math.ceil(love.mouse.getX()/(geometry.hexres*2)+math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))+offset)*textures_fit_x)
		if texture_chosen>#texture then
			texture_chosen=0
		end
		screen_mode='main'
		click_mode='texture'
		love.mouse.setPosition(width-panel+74,256)
	elseif screen_mode=='object' and button==1 and love.mouse.getX()<2*geometry.hexres*textures_fit_x and love.mouse.getY()<math.sqrt(3)*geometry.hexres*textures_fit_y then
		object_chosen=math.ceil(love.mouse.getX()/(geometry.hexres*2)+math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))+offset)*textures_fit_x)
		if object_chosen>#object_graph then
			object_chosen=0
		end
		screen_mode='main'
		click_mode='object'
		love.mouse.setPosition(width-panel+74,406)
	elseif screen_mode=='unit' and button==1 and love.mouse.getX()<2*geometry.hexres*textures_fit_x and love.mouse.getY()<math.sqrt(3)*geometry.hexres*textures_fit_y then
		unit_chosen=math.ceil(love.mouse.getX()/(geometry.hexres*2)+math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))+offset)*textures_fit_x)
		if unit_chosen>#unit_graph then
			unit_chosen=0
		end
		screen_mode='main'
		click_mode='unit'
		love.mouse.setPosition(width-panel+74,556)
	elseif screen_mode=='saveload' and button==1 and love.mouse.getX()<2*geometry.hexres*textures_fit_x and love.mouse.getY()<math.sqrt(3)*geometry.hexres*textures_fit_y then
		local file_chosen=math.ceil(love.mouse.getX()/(geometry.hexres*2)+math.floor(love.mouse.getY()/(geometry.hexres*math.sqrt(3))+offset)*textures_fit_x)
		if saving and file_chosen<#map_savefile then
			filetointeract=map_savefile[file_chosen]
			screen_mode='overwrite'
		elseif saving and file_chosen==#map_savefile then
			filetointeract=""
			screen_mode='save'
		elseif not saving then
			if file_chosen<=#map_savefile then
				filetointeract=map_savefile[file_chosen]
				screen_mode='load'
			else
				screen_mode='main'
			end
		end
	elseif screen_mode=='properties' and button==1 and y<height/2+10 and y>height/2-10 then
		if x<width/3 then
			hexfield[hptarget.x][hptarget.y].unit.hp=0
		elseif x<width*2/3 then
			hexfield[hptarget.x][hptarget.y].unit.hp=
			(optionValue("HP setting")=="integer values" and math.ceil((x-width/3)/(width/3)*hexfield[hptarget.x][hptarget.y].unit.maxhp)) or (x-width/3)/(width/3)*hexfield[hptarget.x][hptarget.y].unit.maxhp
		else
			hexfield[hptarget.x][hptarget.y].unit.hp=hexfield[hptarget.x][hptarget.y].unit.maxhp
		end

		if x>=2*width/3+50 and x<=2*width/3+170 and y>=height/2-30 and y<=height/2+30 then
			screen_mode='maxhpset'
			maxhpnumber=hexfield[hptarget.x][hptarget.y].unit.maxhp or 0
		end
	elseif screen_mode=='properties' and y<height/2+150 and y>height/2+100 and x>width/2-75 and x<width/2+75 then
		screen_mode='main'
	elseif screen_mode=='properties' and button==1 and x<width/2+128 and x>width/2-128 and y<height/2-100 and y>height/2-356 then

		if (math.ceil((x-width/2+128)/32)+8*math.floor((y-height/2+356)/32)<=#buff_graph) then

			if not hexfield[hptarget.x][hptarget.y].unit.bufflist[math.ceil((x-width/2+128)/32)+8*math.floor((y-height/2+356)/32)] then
				hexfield[hptarget.x][hptarget.y].unit.bufflist[math.ceil((x-width/2+128)/32)+8*math.floor((y-height/2+356)/32)]=true
			else
				hexfield[hptarget.x][hptarget.y].unit.bufflist[math.ceil((x-width/2+128)/32)+8*math.floor((y-height/2+356)/32)]=nil
			end
		end

	elseif screen_mode=='overwrite' and button==1 and y<height/2+150 and y>height/2+100 and x>width/3-75 and x<width/3+75 then
		fileHelper.saveTable("maps/"..filetointeract,hexfield)
		lastsavename=filetointeract
		screen_mode='main'
	elseif screen_mode=='save' and button==1 and filetointeract~="" and y<height/2+150 and y>height/2+100 and x>width/3-75 and x<width/3+75 then
		fileHelper.saveTable("maps/"..filetointeract,hexfield)
		lastsavename=filetointeract..".hxm"
		screen_mode='main'
	elseif screen_mode=='load' and button==1 and y<height/2+150 and y>height/2+100 and x>width/3-75 and x<width/3+75 then
		backup()
		lastsavename=filetointeract
		love.window.setTitle(lastsavename.." - Hexfield")
		hexfield = fileHelper.loadTableWithNegativeIndices("maps/"..filetointeract)
		if not hexfield[1][1] then fieldReset() end
		screen_mode='main'
	elseif (screen_mode=='overwrite' or screen_mode=='save' or screen_mode=='load') and button==1 and y<height/2+150 and y>height/2+100 and x>2*width/3-75 and x<2*width/3+75 then
		screen_mode='main'

	elseif (screen_mode=='overwrite' or screen_mode=='load') and button==1 and y<height-75 and y>height-125 and x>width-225 and x<width-75 then
		love.filesystem.remove("maps/"..filetointeract)
		screen_mode='main'
	elseif screen_mode=='maxhpset' and button==1 and y<height/2+150 and y>height/2+100 and x>width/3-75 and x<width/3+75 then
		local newMaxHp = tonumber(maxhpnumber)
		hexfield[hptarget.x][hptarget.y].unit.hp = hexfield[hptarget.x][hptarget.y].unit.hp*newMaxHp/hexfield[hptarget.x][hptarget.y].unit.maxhp
		hexfield[hptarget.x][hptarget.y].unit.maxhp = newMaxHp
		screen_mode='properties'
	elseif screen_mode=='maxhpset' and button==1 and y<height/2+150 and y>height/2+100 and x>2*width/3-75 and x<2*width/3+75 then
		screen_mode='properties'
	elseif screen_mode=='options' and button==1 then
		if x>300 and x<width-300 and y%60>30  then
			local option_index = math.ceil(y/60)
			if option_index<=#options then
				options[option_index].currentValue=options[option_index].currentValue+1
				if options[option_index].currentValue>#options[option_index].values then
					options[option_index].currentValue=1
				end
			end
		end

	end


end

function love.mousereleased(x, y, button )
	if screen_mode=='main' then

		if button==2 then
			camdrag=false
		end

		if button==1 and click_mode=='unit drag' and unitdrag then
			if x<=(width-panel) and x>=0 and y>=0 and y<=height and hexfield[xglow][yglow].unit.type==0 then
				hexfield[xglow][yglow].unit=hexfield[dragtarget.x][dragtarget.y].unit
				hexfield[dragtarget.x][dragtarget.y].unit={type=0,hp=1,r=255,g=255,b=255,bufflist={}}
			elseif x<=(width-panel) and x>=0 and y>=0 and y<=height then
				local tmpunit=hexfield[xglow][yglow].unit
				hexfield[xglow][yglow].unit=hexfield[dragtarget.x][dragtarget.y].unit
				hexfield[dragtarget.x][dragtarget.y].unit=tmpunit
			end
			unitdrag=false
		end

		if button==1 and click_mode=='object drag' and objectdrag then
			if x<=(width-panel) and x>=0 and y>=0 and y<=height and hexfield[xglow][yglow].object.type==0 then
				hexfield[xglow][yglow].object=hexfield[dragtarget.x][dragtarget.y].object
				hexfield[dragtarget.x][dragtarget.y].object={type=0,rotation=0}
			elseif x<=(width-panel) and x>=0 and y>=0 and y<=height then
				local tmpobject=hexfield[xglow][yglow].object
				hexfield[xglow][yglow].object=hexfield[dragtarget.x][dragtarget.y].object
				hexfield[dragtarget.x][dragtarget.y].object=tmpobject
			end
			objectdrag=false
		end

	end
end

function love.mousemoved(x, y, dx, dy)
	if screen_mode=='main' then
		if camdrag then
			view.x=view.x-dx/view.scale
			view.y=view.y-dy/view.scale
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and click_mode=='color' and glow and love.mouse.isDown(1) then --coloring
			hexfield[xglow][yglow].color={drawr,drawg,drawb,drawalpha}
		elseif x<=(width-panel) and x>=0 and y>=0 and y<=height and click_mode=='texture' and glow and love.mouse.isDown(1) then --coloring
			hexfield[xglow][yglow].texture=texture_chosen
		end
	elseif screen_mode=='palette' then
		if x>=100 and x<=355 and love.mouse.isDown(1) then
			if y>90 and y<110 then
				drawr=(x-100)/255
			elseif y>190 and y<210 then
				drawg=(x-100)/255
			elseif y>290 and y<310 then
				drawb=(x-100)/255
			elseif y>390 and y<410 then
				drawalpha=(355-x)/255
			elseif y>500 and y<600 then
				screen_mode='main'
			elseif y>650 and y<750 then
				screen_mode='main'
				for i=-hexsize,hexsize do
						for j=-hexsize,hexsize do
							hexfield[i][j].color={drawr,drawg,drawb,drawalpha}
						end
					end
			end
		end --color settings
	elseif screen_mode=='properties' and y<height/2+10 and y>height/2-10 and love.mouse.isDown(1) then
		if x<width/3 then
			hexfield[hptarget.x][hptarget.y].unit.hp=0
		elseif x<width*2/3 then
			hexfield[hptarget.x][hptarget.y].unit.hp=
			(optionValue("HP setting")=="integer values" and math.ceil((x-width/3)/(width/3)*hexfield[hptarget.x][hptarget.y].unit.maxhp)) or (x-width/3)/(width/3)*hexfield[hptarget.x][hptarget.y].unit.maxhp
		else
			hexfield[hptarget.x][hptarget.y].unit.hp=hexfield[hptarget.x][hptarget.y].unit.maxhp
		end
	end

end

function love.textinput(t)
	if screen_mode=='save' then
			filetointeract = filetointeract .. t
		elseif screen_mode=='maxhpset' then
			if tonumber(t) then
				maxhpnumber = maxhpnumber .. t
			end
		end
end

function love.resize()
	width,height=love.graphics.getDimensions()
	 textures_fit_x=math.floor(width/geometry.hexres/2)
	 textures_fit_y=math.floor(height/geometry.hexres/2)
end

function love.quit()
	autosave()
end