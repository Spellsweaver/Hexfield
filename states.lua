--states.lua
--
--By S. Baranov (spellsweaver@gmail.com)
--For love2d 11.1
-------------
--How to use
-------------
--local states = require("states")
--run states.setup in love.load
--for each of your states, create a file that returns a table of functions
--functions correspond to regular love2d callback
--".open" function is run whenever you switch to a state
--to switch states, use states.switch(newState,params)
--newState is the name of the state file, params will be caught by newState.open callback
--State library redirects love2d callbacks to according functions within state files
--If you want to have state-independant callbacks, put them in your main.lua file, they will override the state callbacks
--if you want to use both state callbacks and state-independant callback in main, use it like this
--function love.update(dt)
--	--your code goes here
--	states.update(dt)
--end

--------------

local states = {}

--private variables
local stateFiles = {}

local currentState = "default"

local love2dCallbacksList =
	--except load
	{
		"keypressed",
		"keyreleased",
		"filedropped",
		"directorydropped",
		"draw",
		"update",
		"wheelmoved",
		"mousepressed",
		"mousemoved",
		"mousereleased",
		"textinput",
		"focus",
		"lowmemory",
		"mousefocus",
		"resize",
		"quit",
		"threaderror",
		"visible"
	}

--private functions
local function defaultInitialize(stateFile)
	--fill in dummy functions instead of omitted ones
	for _,callback in pairs(love2dCallbacksList) do
		stateFile[callback] = stateFile[callback] or function() end
		--open callback is run when switching state
		stateFile.open = stateFile.open or function() end
	end
end

local function add(stateName)
	stateFiles[stateName] = require(stateName)
	defaultInitialize(stateFiles[stateName])
end

--public functions
function states.setup()
	for _,callback in pairs(love2dCallbacksList) do
		states[callback] = 		
		function(p1,p2,p3,p4)
			stateFiles[currentState][callback](p1,p2,p3,p4)
		end
		love[callback] = love[callback] or states[callback]
	end
end

function states.switch(newState,params)
	if not stateFiles[newState] then
		add(newState)
	end

	currentState = newState
	local params = type(params)=="table" and params or {}
	stateFiles[newState].open(params)
end

return states