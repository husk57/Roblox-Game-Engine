local dimensions = script.Parent.Dimensions.Value

local width = dimensions.X
local height = dimensions.Y
local renderTarget = dimensions.Z

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

script.Parent.Canvas.Size = UDim2.fromOffset(width, height)

repeat wait() until game.Players.LocalPlayer.Character
for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
	if v:IsA("BasePart") then
		v.Anchored = true
	end
end
script.Parent.Canvas.Size = UDim2.fromOffset(renderTarget, renderTarget)
local triangles = require(script.Parent.Triangles)
local texLoader = require(script.Parent.TextureLoader)
local objLoader = require(script.Parent.OBJLoader)
local huskLoader = require(script.Parent.HuskLoader)
local model = objLoader.load(require(script.Parent.HuskFiles.player.coderHusk))
local texture1 = texLoader.new(script.Parent.HuskFiles.player.coderHuskTexture)
local mat4x4 = require(script.Parent.Matrix4x4Tools)
local playerHuskObject = huskLoader.new(script.Parent.HuskFiles.player)
local planeHuskObject = huskLoader.new(script.Parent.HuskFiles.plane)
local colorPallete = require(script.Parent.ColorPallete)
local greedyCanvas = require(script.Parent.GreedyCanvas).new(script.Parent.Dimensions.Value.X, script.Parent.Dimensions.Value.Y)
greedyCanvas:SetParent(script.Parent.Canvas)

local camPos = Vector3.new(1.226,2.675,-1.022)--Vector3.new(0,4.084,-5.529)
local camFront = Vector3.new(0,0,-1)
local camUp = Vector3.new(0,1,0)
local pitch = -35.989---40
local yaw = 138.425--90.01
local camSpeed = 1*2
local turnSpeed = 0.5*2
local holding = {false, false, false, false, false, false, false}
local strFormat, round, floor = string.format, math.round, math.floor

game:GetService("UserInputService").InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.W then
		holding[1] = true
	end
	if key.KeyCode == Enum.KeyCode.S then
		holding[2] = true
	end
	if key.KeyCode == Enum.KeyCode.A then
		holding[3] = true
	end
	if key.KeyCode == Enum.KeyCode.D then
		holding[4] = true
	end
	if key.KeyCode == Enum.KeyCode.E then
		holding[5] = true
	end
	if key.KeyCode == Enum.KeyCode.Q then
		holding[6] = true
	end
	if key.KeyCode == Enum.KeyCode.C then
		holding[7] = true
	end
	if key.KeyCode == Enum.KeyCode.K then
		holding[8] = true
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.W then
		holding[1] = false
	end
	if key.KeyCode == Enum.KeyCode.S then
		holding[2] = false
	end
	if key.KeyCode == Enum.KeyCode.A then
		holding[3] = false
	end
	if key.KeyCode == Enum.KeyCode.D then
		holding[4] = false
	end
	if key.KeyCode == Enum.KeyCode.E then
		holding[5] = false
	end
	if key.KeyCode == Enum.KeyCode.Q then
		holding[6] = false
	end
	if key.KeyCode == Enum.KeyCode.C then
		holding[7] = false
	end
	if key.KeyCode == Enum.KeyCode.K then
		holding[8] = false
	end
end)

local pastMouse = Vector2.new(0,0)
local step = os.clock()

local backbuffer = {}
local zbuffer = {}
local projMatrix = mat4x4.new():perspective(70, 0.1, 100)

game:GetService("RunService").Heartbeat:Connect(function(dt)
	local curCamPos = camPos

	local step = os.clock()
	script.Parent.Angles.Text = "Yaw: "..string.format("%.3f",yaw)..", Pitch: "..string.format("%.3f",pitch)
	script.Parent.CameraPosition.Text = "Camera Position: "..string.format("%.3f",camPos.X)..", "..string.format("%.3f",camPos.Y)..", "..string.format("%.3f",camPos.Z)
	local mouse = game.Players.LocalPlayer:GetMouse()
	local deltaMouse = Vector2.new((mouse.X/2)/dimensions.X, -(mouse.Y/2)/dimensions.Y)
	if holding[1] then
		camPos += camSpeed * camFront * dt
	end
	if holding[2] then
		camPos -= camSpeed * camFront * dt
	end
	if holding[3] then
		camPos -= (camFront:Cross(camUp)).Unit * camSpeed * dt
	end
	if holding[4] then
		camPos += (camFront:Cross(camUp)).Unit * camSpeed * dt
	end
	if holding[5] then
		camPos += camUp * camSpeed * dt
	end
	if holding[6] then
		camPos -= camUp * camSpeed * dt
	end
	if holding[7] then
		local xoffset = deltaMouse.X - pastMouse.X
		local yoffset = deltaMouse.Y - pastMouse.Y
		yaw += math.deg(xoffset * turnSpeed)
		pitch += math.deg(yoffset * turnSpeed)
	end
	if(pitch > 89) then
		pitch = 89
	else if(pitch < -89) then
			pitch = -89
		end
	end
	pastMouse = deltaMouse
	camFront = Vector3.new(math.cos(math.rad(yaw)) * math.cos(math.rad(pitch)), math.sin(math.rad(pitch)), math.sin(math.rad(yaw)) * math.cos(math.rad(pitch)))
	local temp = camFront:Cross((camUp:Cross(camFront)).Unit)
	local forward = -camFront.Unit
	local right = temp:Cross(forward)
	local up = forward:Cross(right)
	local viewMatrix = CFrame.new(0,0,0,right.X,right.Y,right.Z,up.X,up.Y,up.Z,forward.X,forward.Y,forward.Z) * CFrame.new(-camPos)
	for x=1,dimensions.X do
		for y=1,dimensions.Y do
			backbuffer[dimensions.Y*(y-1)+(dimensions.X - x +1)] = Vector3.new(0.1, 0.1, 0.1)
			zbuffer[dimensions.Y*(y-1)+(dimensions.X - x +1)] = 1
		end
	end
	local dependencies = {zbuffer,backbuffer, curCamPos, curCamPos, holding[8]}

	playerHuskObject.Orientation = Vector3.new(playerHuskObject.Orientation.X, playerHuskObject.Orientation.Y+(90*dt), playerHuskObject.Orientation.Z)
	playerHuskObject.modelMatrix = CFrame.new(playerHuskObject.Position.X,playerHuskObject.Position.Y,playerHuskObject.Position.Z,playerHuskObject.Scale.X,0,0,0,playerHuskObject.Scale.Y,0,0,0,playerHuskObject.Scale.Z)
	playerHuskObject.modelMatrix *= CFrame.fromEulerAnglesXYZ(math.rad(playerHuskObject.Orientation.X), math.rad(playerHuskObject.Orientation.Y), math.rad(playerHuskObject.Orientation.Z))

	playerHuskObject:processData(viewMatrix, projMatrix, dependencies)
	planeHuskObject:processData(viewMatrix, projMatrix, dependencies)
	for x=1,dimensions.X do
		for y=1,dimensions.Y do
			greedyCanvas:SetPixel(dimensions.X - x +1, y, colorPallete[bit32.bor(bit32.arshift(round((round(backbuffer[dimensions.Y*(y-1)+(dimensions.X - x +1)].X*8)/8)*255), -16),bit32.arshift(round((round(backbuffer[dimensions.Y*(y-1)+(dimensions.X - x +1)].Y*8)/8)*255), -8),round((round(backbuffer[dimensions.Y*(y-1)+(dimensions.X - x +1)].Z*8)/8)*255))])
		end
	end
	greedyCanvas:Render()
end)