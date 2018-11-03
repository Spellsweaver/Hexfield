local function button(options)
	--draws a button with text that is highlit whenever you hover over them
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

return button