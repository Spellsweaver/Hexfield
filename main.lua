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
local geometry = require("hexagonalGeometryHelper")
require("fonts")
--Functions
local deepcopy = require("deepcopy")
local button = require("button")

--Models
local hexfieldModel = require("models/hexfieldModel")
local optionsModel = require("models/optionsModel")
local graphicsModel = require("models/graphicsModel")

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
	geometry.recountDimensions()
	love.window.setTitle ("Hexagonal field")
	hexfieldModel.reset()
	love.filesystem.createDirectory("maps")

	graphicsModel.preload()
	optionsModel.initialize()
	states.switch("map",{reset=true})
end

function love.resize()
	width,height=love.graphics.getDimensions()
	geometry.recountDimensions()
end

function love.quit()
	autosave()
end