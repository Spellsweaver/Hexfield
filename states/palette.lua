local states = require("states")
local button = require("button")

local palette = {}
--this screen serves as color selector

local r,g,b,alpha = 1,1,1,0.5
local clickMode
local rememberedMouseX,rememberedMouseY

function palette.open(params)
	r = params.r or r
	g = params.g or g
	b = params.b or b
	alpha = params.alpha or alpha
	clickMode = params.clickMode or 'color'
	rememberedMouseX,rememberedMouseY = params.rememberedMouseX or 0,params.rememberedMouseY or 0
end

function palette.keypressed(key,scancode)
	if key == "escape" then
		states.switch("map")
	end
end

function palette.draw()
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
	love.graphics.line(100+r*255,93,100+r*255,108);
	love.graphics.line(100+g*255,193,100+g*255,208);
	love.graphics.line(100+b*255,293,100+b*255,308);
	love.graphics.line(355-alpha*255,393,355-alpha*255,408);
	love.graphics.setColor(r,g,b,1)
	love.graphics.rectangle('fill',width/2,0,width/2,height);

	button({x=100,y=500,width=255,height=100,lineWidth=3,text='APPLY'})
	button({x=100,y=650,width=255,height=100,lineWidth=3,text='PAINT ALL'})
end

function palette.mousepressed( x, y, button )
	if button==1 then
		if x>=100 and x<=355 then
			if y>90 and y<110 then
				r=(x-100)/255
			elseif y>190 and y<210 then
				g=(x-100)/255
			elseif y>290 and y<310 then
				b=(x-100)/255
			elseif y>390 and y<410 then
				alpha=(355-x)/255
			elseif y>500 and y<600 then
				states.switch("map",{drawr=r,drawg=g,drawb=b,drawalpha=alpha,clickMode=clickMode})
				love.mouse.setPosition(rememberedMouseX,rememberedMouseY)
			elseif y>650 and y<750 then
				states.switch("map",{drawr=r,drawg=g,drawb=b,drawalpha=alpha,clickMode=clickMode,colorall=true})
				love.mouse.setPosition(rememberedMouseX,rememberedMouseY)
			end
		end
	end
end

function palette.mousemoved(x,y,dx,dy)
	if x>=100 and x<=355 and love.mouse.isDown(1) then
		if y>90 and y<110 then
			r=(x-100)/255
		elseif y>190 and y<210 then
			g=(x-100)/255
		elseif y>290 and y<310 then
			b=(x-100)/255
		elseif y>390 and y<410 then
			alpha=(355-x)/255
		end
	end
end

return palette