---------------------------
--Hexagonal field
---------------------------
--by spellsweaver@gmail.com
----------------------------
--1.3.5
----------------------------
--Libraries
local utf8 = require("utf8")
local states = require("states")
local fileHelper = require("fileHelper")
--Functions
local deepcopy = require("deepcopy")
local button = require("button")
require("fonts")

function autosave()
	fileHelper.saveTable("maps/autosave.hxm", hexfield)
	fileHelper.saveTable("options.json", options)
	return false
end

function love.load()
	states.setup()
	local _, _, flags = love.window.getMode()
	width, height = love.window.getDesktopDimensions(flags.display)
	love.window.setMode (width,height,{fullscreen=false,vsync=true,resizable=true,borderless=false,centered=true})
	love.window.maximize()
	width,height = love.graphics.getDimensions()
	love.window.setTitle ("Hexagonal field")

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

	states.switch("map",{reset=true})

end

function love.resize()
	width,height=love.graphics.getDimensions()
	states.resize()
end

function love.quit()
	autosave()
end