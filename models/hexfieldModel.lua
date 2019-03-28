local fileHelper = require("fileHelper")
local deepcopy = require("deepcopy")

local model = {}

local hexfield_backup

model.hexfield = {}
model.hexsize = 50
model.lastsavename = ""

function model.reset()
	lastsavename=""
	love.window.setTitle("Hexfield")
		for i=-model.hexsize,model.hexsize do
			model.hexfield[i]={}
			for j=-model.hexsize,model.hexsize do
				model.hexfield[i][j]=
				{
					color={0,0,0,0},
					texture=1,
					object=
						{
							type=0,
							rotation=0
						},
					unit=
						{
							type=0,
							hp=100,
							maxhp=100,
							r=1,
							g=1,
							b=1,
							bufflist={},
							text='',
						}
				}
			end
		end
end

function model.colorAll(drawr,drawg,drawb,drawalpha)
	model.backup()
	for i=-model.hexsize,model.hexsize do
			for j=-model.hexsize,model.hexsize do
				model.hexfield[i][j].color={drawr,drawg,drawb,drawalpha}
			end
	end
end

function model.backup()
	hexfield_backup=deepcopy(model.hexfield)
end

function model.restore()
	if hexfield_backup then
		local tmp=model.hexfield
		model.hexfield=hexfield_backup
		hexfield_backup=tmp
	end
end

function model.save(filename)
	fileHelper.saveTable("maps/"..filename,model.hexfield)
	love.window.setTitle(filename.." - Hexfield")
	model.lastsavename = filename
end

function model.load(filename)
	model.backup()
	love.window.setTitle(filename.." - Hexfield")
	model.hexfield = fileHelper.loadTableWithNegativeIndices("maps/"..filename)
	if not model.hexfield[1][1] then
		model.reset()
	end
	model.lastsavename = filename
end

return model