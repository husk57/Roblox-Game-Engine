local module = {}

function module.load(data)
	local lineArray = string.split(data, string.char(10))
	local verticies = {	}
	local texCoords = {}
	local normals = {}
	local faces = {}
	--first is maximum, second is minimum
	local boundingBox = {Vector3.new(), Vector3.new()}
	for i=1,#lineArray do
		local lineFeed = string.split(lineArray[i], string.char(32))
		if lineFeed[1] == "v" then
			verticies[#verticies+1] = Vector3.new(tonumber(lineFeed[2]), tonumber(lineFeed[3]), tonumber(lineFeed[4]))
		end
		if lineFeed[1] == "vt" then
			texCoords[#texCoords+1] = Vector3.new(tonumber(lineFeed[2]), tonumber(lineFeed[3]), 0)
		end
		if lineFeed[1] == "vn" then			
			normals[#normals+1] = Vector3.new(tonumber(lineFeed[2]), tonumber(lineFeed[3]), tonumber(lineFeed[4]))
		end
		if lineFeed[1] == "f" then
			local vert1Idxs = string.split(lineFeed[2], string.char(47))
			local vert2Idxs = string.split(lineFeed[3], string.char(47))
			local vert3Idxs = string.split(lineFeed[4], string.char(47))
		faces[#faces+1] = {
				{
					verticies[tonumber(vert1Idxs[1])],
					texCoords[tonumber(vert1Idxs[2])],
					normals[tonumber(vert1Idxs[3])]
				},
				{
					verticies[tonumber(vert2Idxs[1])],
					texCoords[tonumber(vert2Idxs[2])],
					normals[tonumber(vert2Idxs[3])]
				},
				{
					verticies[tonumber(vert3Idxs[1])],
					texCoords[tonumber(vert3Idxs[2])],
					normals[tonumber(vert3Idxs[3])]
				},
		}
		end
	end
	local serialVertsX = {}
	local serialVertsY = {}
	local serialVertsZ = {}
	for i=1,#faces do
		for j=1,3 do
			serialVertsX[#serialVertsX+1] = faces[i][j][1].X
			serialVertsY[#serialVertsY+1] = faces[i][j][1].Y
			serialVertsZ[#serialVertsZ+1] = faces[i][j][1].Z
		end
	end
	boundingBox[1] = Vector3.new(math.max(unpack(serialVertsX)),math.max(unpack(serialVertsY)),math.max(unpack(serialVertsZ)))
	boundingBox[2] = Vector3.new(math.min(unpack(serialVertsX)),math.min(unpack(serialVertsY)),math.min(unpack(serialVertsZ)))
	return {
		["verticies"] = verticies,
		["texCoords"] = texCoords,
		["normals"] = normals,
		["faces"] = faces,
		["boundingBox"] = boundingBox
	}
end

return module
