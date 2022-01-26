local module = {}
module.__index = module
local triangles = require(script.Parent.Triangles)
local mat4x4 = require(script.Parent.Matrix4x4Tools)
local objLoader = require(script.Parent.OBJLoader)
local textureLoader = require(script.Parent.TextureLoader)
local dimensions = script.Parent.Dimensions.Value

--[[dependencies
{zbuffer, backbuffer, triangleCount, light source (world space), curCamPos (world space)}
]]--

function module.new(huskFile)
	local lineArray = string.split(require(huskFile), string.char(10))

	local metaData = {
		["type"] = string.split(lineArray[1], string.char(34))[2],
		["mesh"] = objLoader.load(require(huskFile[string.split(lineArray[2], string.char(34))[2]])),
		["texture"] = textureLoader.new(huskFile[string.split(lineArray[3], string.char(34))[2]])
	}
	local positions = string.split(string.split(lineArray[4], string.char(40))[2]:gsub("%)", ""), string.char(44))
	positions = Vector3.new(tonumber(positions[1]), tonumber(positions[2]), tonumber(positions[3]))
	local orientation = string.split(string.split(lineArray[5], string.char(40))[2]:gsub("%)", ""), string.char(44))
	orientation = Vector3.new(tonumber(orientation[1]), tonumber(orientation[2]), tonumber(orientation[3]))
	local scale = string.split(string.split(lineArray[6], string.char(40))[2]:gsub("%)", ""), string.char(44))
	scale = Vector3.new(tonumber(scale[1]), tonumber(scale[2]), tonumber(scale[3]))
	metaData.Position = positions
	metaData.Orientation = orientation
	metaData.Scale = scale
	metaData.modelMatrix = CFrame.new(metaData.Position.X,metaData.Position.Y,metaData.Position.Z,metaData.Scale.X,0,0,0,metaData.Scale.Y,0,0,0,metaData.Scale.Z)
	return setmetatable(metaData, module)
end

function module:processData(viewMatrix, projMatrix, dependencies)
	local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = (viewMatrix*self.modelMatrix):GetComponents()
	local vm = mat4x4.new(false,{
		{m11,m12,m13,x};
		{m21,m22,m23,y};
		{m31,m32,m33,z};
		{0,0,0,1}
	})
	local clipMatrix = mat4x4.multiply(projMatrix, vm)
	local cfClipMatrix = CFrame.new(clipMatrix[1][4],clipMatrix[2][4], clipMatrix[3][4], 
		clipMatrix[1][1], clipMatrix[1][2],clipMatrix[1][3],
		clipMatrix[2][1], clipMatrix[2][2],clipMatrix[2][3],
		clipMatrix[3][1], clipMatrix[3][2],clipMatrix[3][3])
	for i=1,#self.mesh.faces do
		triangles.processShapeAssembly(dependencies[1],dependencies[2],self.mesh.faces[i], cfClipMatrix, clipMatrix, self.modelMatrix, self.texture, dependencies[3], dependencies[4],dependencies[5], self.mesh.boundingBox)
	end
	
end

return module
