local window = {}

function window.initialize()
	local _, _, flags = love.window.getMode()
	width, height = love.window.getDesktopDimensions(flags.display)
	love.window.setMode (width,height,{fullscreen=false,vsync=true,resizable=true,borderless=false,centered=true})
	love.window.maximize()
	width,height = love.graphics.getDimensions()
end

function window.update()
	width,height=love.graphics.getDimensions()
end

return window