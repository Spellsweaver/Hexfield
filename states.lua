--States.lua
--By S. Baranov (spellsweaver@gmail.com)
--
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
--All of the love2d callbacks are supposed to be moved to state files,
--EXCEPT: love.load, love.quit, love.resize that remain in mail.lua

--------------

--private variables
local stateFiles = {}

local currentState = "default"

local love2dCallbacksList =
	--only callbacks for which the state matters
	--no resize, quit, etc
	--no load here too
	{
		"keypressed",
		"draw",
		"update",
		"wheelmoved",
		"mousepressed",
		"mousereleased",
		"textinput"
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
		love[callback] = function(p1,p2,p3,p4)
			stateFiles[currentState][callback](p1,p2,p3,p4)
		end
	end
end

function states.switch(newState,params)
	if stateFile[newState] then
		currentState = newState
		stateFile[newState].open(params)
	else
		add(newState)
	end

end

return states