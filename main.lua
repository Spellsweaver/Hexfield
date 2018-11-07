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
require("fonts")
--Functions
local deepcopy = require("deepcopy")
local button = require("button")

--Models
local hexfieldModel = require("models/hexfieldModel")
local optionsModel= require("models/optionsModel")

function autosave()
	hexfieldModel.save("autosave.hxm")
	optionsModel.save()
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
	hexfieldModel.reset()

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
	love.filesystem.createDirectory("maps")

	optionsModel.initialize()
	states.switch("map",{reset=true})
end

function love.resize()
	width,height=love.graphics.getDimensions()
	states.resize()
end

function love.quit()
	autosave()
end