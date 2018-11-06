local states = require("states")
local button = require("button")

local properties = {}

local target

function properties.open(params)
	target = params.target
end

function properties.draw()
	love.graphics.setLineWidth(11)
	love.graphics.setColor(1,0,0)
	love.graphics.line(width/3, height/2, 2*width/3, height/2)
	love.graphics.setColor(0,1,0)
	love.graphics.line(width/3, height/2, width/3*(1+target.hp/target.maxhp), height/2)

	button({x=width/2-75,y=height/2+100,width=150,height=50,lineWidth=3,text='OK'})
	local hpString
	if optionValue("HP setting")=="percentage" then
		hpString=string.format("%.1f",(100*target.hp/target.maxhp)).."%"
	elseif optionValue("HP setting")=="integer values" then
		hpString=string.format("%d",target.hp)
	elseif optionValue("HP setting")=="real values" then
		hpString=string.format("%.1f",target.hp)
	end
	love.graphics.print(hpString,width/2-15,height/2+20);

	button({x=width*2/3+50,y=height/2-30,width=120,height=60,lineWidth=3,text='Max HP = '..target.maxhp})

	love.graphics.setColor(1,1,1)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle('line',width/2-128,height/2-356,256,256)

	for i=1,#buff_graph do

		if (love.mouse.getX()>((i-1)%8)*32+width/2-128 and love.mouse.getX()<((i-1)%8)*32+width/2-96 and love.mouse.getY()>(math.ceil(i/8)-1)*32+height/2-356 and love.mouse.getY()<(math.ceil(i/8)-1)*32+height/2-324) 
		or target.bufflist[i] then
			love.graphics.setColor(1,1,1)
			love.graphics.rectangle('fill',((i-1)%8)*32+width/2-128,(math.ceil(i/8)-1)*32+height/2-356,32,32)
		end
		love.graphics.draw(buff_graph[i],((i-1)%8)*32+width/2-128,(math.ceil(i/8)-1)*32+height/2-356,0,2)
	end
end

function properties.mousepressed(x,y,button)
	if button==1 and y<height/2+10 and y>height/2-10 then
		if x>=2*width/3+50 and x<=2*width/3+170 and y>=height/2-30 and y<=height/2+30 then
			states.switch("maxhpset",{target=target})
		elseif x<width/3 then
			target.hp=0
		elseif x<width*2/3 then
			target.hp=
			(optionValue("HP setting")=="integer values" and math.ceil((x-width/3)/(width/3)*target.maxhp)) or (x-width/3)/(width/3)*target.maxhp
		else
			target.hp=target.maxhp
		end
	elseif y<height/2+150 and y>height/2+100 and x>width/2-75 and x<width/2+75 then
		states.switch("map")
	elseif button==1 and x<width/2+128 and x>width/2-128 and y<height/2-100 and y>height/2-356 then
		if (math.ceil((x-width/2+128)/32)+8*math.floor((y-height/2+356)/32)<=#buff_graph) then
			if not target.bufflist[math.ceil((x-width/2+128)/32)+8*math.floor((y-height/2+356)/32)] then
				target.bufflist[math.ceil((x-width/2+128)/32)+8*math.floor((y-height/2+356)/32)]=true
			else
				target.bufflist[math.ceil((x-width/2+128)/32)+8*math.floor((y-height/2+356)/32)]=nil
			end
		end
	end
end

function properties.mousemoved(x, y, dx, dy)
	if y<height/2+10 and y>height/2-10 and love.mouse.isDown(1) then
		if x<width/3 then
			target.hp=0
		elseif x<width*2/3 then
			target.hp=
			(optionValue("HP setting")=="integer values" and math.ceil((x-width/3)/(width/3)*target.maxhp)) or (x-width/3)/(width/3)*target.maxhp
		else
			target.hp=target.maxhp
		end
	end

end

function properties.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	end
end

return properties