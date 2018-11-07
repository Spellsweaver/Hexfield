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
local window = require("windowHelper")

function autosave()
	hexfieldModel.save("autosave.hxm")
	optionsModel.save()
	return false
end

function love.load()
	states.setup()
	window.initialize()
	geometry.recountDimensions()
	love.window.setTitle ("Hexagonal field")
	hexfieldModel.reset()
	love.filesystem.createDirectory("maps")
	graphicsModel.preload()
	optionsModel.initialize()
	states.switch("map")
end

function love.resize()
	window.update()
	geometry.recountDimensions()
end

function love.quit()
	autosave()
end