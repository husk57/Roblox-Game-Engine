local module = {}
local dimensions = script.Parent.Dimensions.Value

local vec3New = Vector3.new
local max,min,clamp,pow,floor,sqrt = math.max,math.min,math.clamp,math.pow,math.floor,math.sqrt
local a,b,c,minX,maxX,minY,maxY,tempB1,tempC1,divisorBeta,dividendBeta,beta,divisorGamma,dividendGamma,gamma,alpha,interpolatedZCoord,interpolatedNormal,interpolatedFragPos,interpolatedTexCoords,viewRay,lightRay,diffuse,spec,ambient,baseColor,col,interpolatedInverseWCoord,bufferAddress,attKc,attKl,attKq,d,attenuation,v1Arr,v2Arr,v3Arr
local function computeTriangle(zbuffer, backbuffer, vertexs, lightPos, viewPosition, texLoader)
	--find bounding box dimensions
	v1Arr = vertexs[1]
	v2Arr = vertexs[2]
	v3Arr = vertexs[3]
	a = vec3New(floor(v1Arr[1].X), floor(v1Arr[1].Y), 0)
	b = vec3New(floor(v2Arr[1].X), floor(v2Arr[1].Y), 0)
	c = vec3New(floor(v3Arr[1].X), floor(v3Arr[1].Y), 0)

	minX = min(a.X, b.X, c.X)
	maxX = max(a.X, b.X, c.X)
	minY = min(a.Y, b.Y, c.Y)
	maxY = max(a.Y, b.Y, c.Y)
--[[ this is a hack, it fakes clipping ]]--
	minX = clamp(minX, 1, dimensions.X)
	maxX = clamp(maxX, 1, dimensions.X)
	minY = clamp(minY, 1, dimensions.Y)
	maxY = clamp(maxY, 1, dimensions.Y)
--[[ this is a hack, it fakes clipping ]]--
	local v0 = v2Arr[1] - v1Arr[1]
	local v1 = v3Arr[1] - v1Arr[1]

	local d00 = v0:Dot(v0)
	local d01 = v0:Dot(v1)
	local d11 = v1:Dot(v1)
	local denom = 1/(d00 * d11 - d01 * d01)
	--bound loop
	for pX=minX, maxX do
		for pY=minY, maxY do
			local v2 = vec3New(pX,pY,0) - v1Arr[1]
			local d20 = v2:Dot(v0)
			local d21 = v2:Dot(v1)
			beta = (d11 * d20 - d01 * d21) * denom
			gamma = (d00 * d21 - d01 * d20) * denom
			alpha = 1-beta-gamma
			if beta >= 0 and gamma >= 0 and beta+gamma <= 1 then
				bufferAddress = dimensions.Y*(pY-1)+pX
				interpolatedZCoord = vec3New(v1Arr[1].Z, v2Arr[1].Z, v3Arr[1].Z):Dot(vec3New(alpha, beta, gamma))
				if zbuffer[bufferAddress] > interpolatedZCoord then
					zbuffer[bufferAddress] = interpolatedZCoord
					interpolatedNormal = (v1Arr[3]*alpha + v2Arr[3]*beta + v3Arr[3]*gamma).Unit
					interpolatedFragPos = v1Arr[2]*alpha + v2Arr[2]*beta + v3Arr[2]*gamma
					interpolatedTexCoords = v1Arr[4]*alpha + v2Arr[4]*beta + v3Arr[4]*gamma
					--https://computergraphics.stackexchange.com/questions/4079/perspective-correct-texture-mapping
					interpolatedInverseWCoord = vec3New(v1Arr[5], v2Arr[5], v3Arr[5]):Dot(vec3New(alpha, beta, gamma))

					viewRay = (viewPosition-interpolatedFragPos).Unit
					lightRay = viewRay--(viewPosition-interpolatedFragPos).Unit
					diffuse = max(interpolatedNormal:Dot(lightRay), 0)
					spec = pow(max((viewRay-2*(viewRay:Dot(interpolatedNormal))*interpolatedNormal).Unit:Dot(lightRay), 0), 80)
					ambient = 0.1
					--https://computergraphics.stackexchange.com/questions/4079/perspective-correct-texture-mapping
					baseColor = texLoader:sample(interpolatedTexCoords / interpolatedInverseWCoord)

					attKc = 1
					attKl = 0.09
					attKq = 0.032
					d = (viewPosition-interpolatedFragPos).Magnitude
					--https://learnopengl.com/Lighting/Light-casters
					attenuation = 1/(attKc+attKl*d+attKq*d*d)
					col = baseColor*(diffuse*attenuation+spec*attenuation+ambient*attenuation)
					--more efficient way of doing x^0.5, proper is x^(1/2.2)
					col = vec3New(sqrt(col.X), sqrt(col.Y), sqrt(col.Z)) 
					backbuffer[dimensions.Y*(pY-1)+(dimensions.X - pX +1)] = vec3New(clamp(col.X, 0, 1), clamp(col.Y, 0, 1), clamp(col.Z, 0, 1))
				end
			end
		end
	end
end

function bresenham(x1, y1, x2, y2,backbuffer)
	local delta_x = x2 - x1
	local err
	local ix = delta_x > 0 and 1 or -1
	delta_x = 2 * math.abs(delta_x)

	local delta_y = y2 - y1
	local iy = delta_y > 0 and 1 or -1
	delta_y = 2 * math.abs(delta_y)
	if x1 < dimensions.X and x1 > 0 and y1 < dimensions.Y and y1 > 0 then
		backbuffer[dimensions.Y*(y1-1)+(dimensions.X - x1 +1)] = Vector3.new(0.5,1,0)
	end

	if delta_x >= delta_y then
		err = delta_y - delta_x / 2

		while x1 ~= x2 do
			if (err > 0) or ((err == 0) and (ix > 0)) then
				err = err - delta_x
				y1 = y1 + iy
			end

			err = err + delta_y
			x1 = x1 + ix
			if x1 < dimensions.X and x1 > 0 and y1 < dimensions.Y and y1 > 0 then
				backbuffer[dimensions.Y*(y1-1)+(dimensions.X - x1 +1)] = Vector3.new(0.5,1,0)
			end
		end
	else
		err = delta_x - delta_y / 2

		while y1 ~= y2 do
			if (err > 0) or ((err == 0) and (iy > 0)) then
				err = err - delta_y
				x1 = x1 + ix
			end

			err = err + delta_x
			y1 = y1 + iy
			if x1 < dimensions.X and x1 > 0 and y1 < dimensions.Y and y1 > 0 then
				backbuffer[dimensions.Y*(y1-1)+(dimensions.X - x1 +1)] = Vector3.new(0.5,1,0)
			end
		end
	end
end
local cfNew = CFrame.new
local screenCoords,worldCoords,normals,texCoords,vertexs = {}, {}, {}, {}, {}
local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33,transform,assemblyFlags,localMatrix,v,vW,vWorldSpace,clipCoords
function module.processShapeAssembly(zbuffer, backbuffer, face, cfClipMatrix, clipMatrix, modelMatrix, texture, lightSrc, viewPosition,wireframe)
	assemblyFlags = {false,false,false}
	clipCoords = {}
	local bsPosition = Vector3.new()
	local bsRadius = 0
	for j=1, 3 do
		localMatrix = face[j][1]
		v = cfClipMatrix*localMatrix
		--https://cdn.discordapp.com/attachments/563971279426682891/916846218099953674/FT_2021-12-04_161929.315.png
		vW = vec3New(clipMatrix[4][1], clipMatrix[4][2], clipMatrix[4][3]):Dot(face[j][1])+clipMatrix[4][4]

		assemblyFlags[j] = -vW < v.X and v.X < vW and -vW < v.Y and v.Y < vW and -vW < v.Z and v.Z < vW
		v = vec3New(v.X/vW, v.Y/vW, v.Z/vW)
		bsPosition += v
		clipCoords[j] = v
		--[[lighting calculations are done in world space,
		while a bit misleading the modelMatrix represents the world space transformations.
		more over, the worldCoords part is to get the interpolated world coordinate to be used
		in specular lighting calculations and the transformed normal is so that the lighting calculations 
		respect world space transformations.]]

		x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = (modelMatrix:inverse()):GetComponents()
		transform = cfNew(0,0,0,m11,m21,m31,m12,m22,m32,m13,m23,m33)
		normals[j] = transform*face[j][3]
		normals[j] = vec3New(normals[j].X/vW, normals[j].Y/vW, normals[j].Z/vW)
		texCoords[j] = vec3New(face[j][2].X/vW, face[j][2].Y/vW, 0)

		vWorldSpace = modelMatrix*localMatrix
		worldCoords[j] = vWorldSpace

		--for the x and y entries they are mapping functions which map -1 to 1 to 0 to width or height
		screenCoords[j] = vec3New((v.X+1)*dimensions.X*0.5, (v.Y+1)*dimensions.Y*0.5, v.Z)
		--https://computergraphics.stackexchange.com/questions/4079/perspective-correct-texture-mapping
		vertexs[j] = {screenCoords[j], worldCoords[j], normals[j], texCoords[j], 1/vW}
	end
	bsPosition /= 3
	for i=1,3 do
		local dist = (clipCoords[i]-bsPosition).Magnitude
		if dist > bsRadius then
			bsRadius = dist
		end
	end
	--more intuitive is not(not a, not b, not c). however with de morgan laws it simplifies to just oring them all
	if assemblyFlags[1] or assemblyFlags[2] or assemblyFlags[3] and (worldCoords[1]-viewPosition):Dot((worldCoords[2]-worldCoords[1]):Cross(worldCoords[3]-worldCoords[1])) < 0 then
		computeTriangle(zbuffer, backbuffer, vertexs, lightSrc, viewPosition, texture)
		if wireframe then
			--AB
			bresenham(floor(screenCoords[1].X), floor(screenCoords[1].Y), floor(screenCoords[2].X), floor(screenCoords[2].Y),backbuffer)
			--AC
			bresenham(floor(screenCoords[1].X), floor(screenCoords[1].Y), floor(screenCoords[3].X), floor(screenCoords[3].Y),backbuffer)
			--BC
			bresenham(floor(screenCoords[2].X), floor(screenCoords[2].Y), floor(screenCoords[3].X), floor(screenCoords[3].Y),backbuffer)
		end
	end
end

return module
