local matrix = {}
matrix.__index = matrix

--[[compData is 4x4 2 dimensional array]]--
function matrix.new(inheritedFromVector, compData)
	if not compData then
		compData = {
			{1,0,0,0},
			{0,1,0,0},
			{0,0,1,0},
			{0,0,0,1}
		}
	end
	if inheritedFromVector then
		compData = {
			{compData.X},
			{compData.Y},
			{compData.Z},
			{1}
		}
	end
	return setmetatable(compData, matrix)
end

--[[perform matrix multiplication]]--

function matrix.multiply(m1, m2)
	local mtx = {}
	for i = 1,#m1 do
		mtx[i] = {}
		for j = 1,#m2[1] do
			local num = m1[i][1] * m2[1][j]
			for n = 2,#m1[1] do
				num += m1[i][n] * m2[n][j]
			end
			mtx[i][j] = num
		end
	end
	return matrix.new(false, mtx)
end

--[[convert the homogonous coordinate vector to a 3 dimensional roblox vector]]--
function matrix:m2v3()
	local w = self[4][1]+1e-7
	return Vector3.new(self[1][1]/w, self[2][1]/w, self[3][1]/w)
end

--[[create a rotational matrix, axis is a string of X, Y, or Z]]--
function matrix:rotate(axis, step)
	if axis == "X" then
		local mtx = {
			{1,0,0,0};
			{0, math.cos(step), -math.sin(step), 0};
			{0,math.sin(step), math.cos(step), 0};
			{0,0,0,1}
		}
		return matrix.new(false, mtx)
	end
	if axis == "Y" then
		local mtx = {
			{math.cos(step),0,math.sin(step),0};
			{0, 1,0, 0};
			{-math.sin(step),0, math.cos(step), 0};
			{0,0,0,1}
		}
		return matrix.new(false, mtx)
	end
	if axis == "Z" then
		local mtx = {
			{math.cos(step),-math.sin(step),0,0};
			{math.sin(step), math.cos(step),0, 0};
			{0,0,1, 0};
			{0,0,0,1}
		}
		return matrix.new(false, mtx)
	end
end

--[[create a perspective matrix, n is near clipping plane and f is far clipping plane with clip bounds of -1 to 1]]--
function matrix:perspective(fov,n,f)
	--https://www.scratchapixel.com/lessons/3d-basic-rendering/perspective-and-orthographic-projection-matrix/opengl-perspective-projection-matrix
	local frustum_h = math.tan(math.rad(fov)/2)*n
	local frustum_w = frustum_h*(script.Parent.Dimensions.Value.X/script.Parent.Dimensions.Value.Y)
	local l = frustum_w*(-1.0)
	local r = frustum_w*(1.0)
	local b = frustum_h*(-1.0)
	local t = frustum_h*(1.0)
	local mtx = {
		{(2*n)/(r-l),0,(r+l)/(r-l),0};
		{0,(2*n)/(t-b),(t+b)/(t-b),0};
		{0,0,-(f+n)/(f-n),-(2*f*n)/(f-n)};
		{0,0,-1, 0}
	}
	return matrix.new(false, mtx)
end

--[[x,y,z are the scale factors for each axis]]
function matrix:scale(x,y,z)
	local mtx = {
		{x,0,0,0};
		{0,y,0,0};
		{0,0,z,0};
		{0,0,0,1}
	}
	return matrix.new(false, mtx)
end

--[[lookat matrix, parameters are roblox vector3s]]--
local function randomUnitVector()
	local sqrt = math.sqrt(-2 * math.log(math.random()))
	local angle = 2 * math.pi * math.random()

	return Vector3.new(
		sqrt * math.cos(angle),
		sqrt * math.sin(angle),
		math.sqrt(-2 * math.log(math.random())) * math.cos(2 * math.pi * math.random())
	).Unit
end

function matrix:lookAt(eye, target, temp)
	local forward = (eye-target).Unit
	local right = temp:Cross(forward)
	local up = forward:Cross(right)
	local coordSpace = matrix.new(false, {
		{right.X, right.Y, right.Z, 0};
		{up.X, up.Y, up.Z, 0};
		{forward.X, forward.Y, forward.Z, 0};
		{0,0,0,1}
	})
	local invertedCameraPosition = matrix.new(false, {
		{1,0,0,-eye.X};
		{0,1,0,-eye.Y};
		{0,0,1,-eye.Z};
		{0,0,0,1}
	})
	return self.multiply(coordSpace, invertedCameraPosition)
end

return matrix
