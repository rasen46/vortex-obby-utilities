--[[
    uses Katie's basic camera 
    https://devforum.roblox.com/t/how-you-can-make-your-own-basic-custom-camera/3986144

	Alignment key Utility (standalone version)
	by rasen46

	last update: 11/24/2026
	v1.0.0 (somewhat buggy) (batch release 1.0.0)

]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local UserSettings = game:GetService("UserGameSettings")

local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Head = Character:WaitForChild("Head")

local Camera_X = 0
local Camera_Y = 0
local Camera_Z = 0
local Camera_Distance = 20
local TargetCamDist = 20

-- configs (ye im too lazy to put them in a table, this way of laying out configs is probably easier to edit anyways)

local HorizontalRotation = 45
local VerticalRotation = 30
local MaxVertical = 80

local leftAlignment = Enum.KeyCode.G
local rightAlignment = Enum.KeyCode.H
local upAlignment = Enum.KeyCode.U
local downAlignment = Enum.KeyCode.J

local rightclick = false

Camera.CameraType = Enum.CameraType.Scriptable

local function UpdateCharacter(NewCharacter)
	Character = NewCharacter
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	Head = Character:WaitForChild("Head")
end

local function UpdateCamera(DeltaTime)
	local Delta = UserInputService:GetMouseDelta()

	Camera_X -= Delta.X * UserSettings.MouseSensitivity * 0.25
	Camera_Y = math.clamp(Camera_Y - Delta.Y * UserSettings.MouseSensitivity * 0.25, -MaxVertical, MaxVertical)

	local Origin = HumanoidRootPart.Position
+ Vector3.new(0,1.5,0)

	Camera.CFrame = CFrame.new(Origin)
		* CFrame.Angles(0, math.rad(Camera_X), 0)
		* CFrame.Angles(math.rad(Camera_Y), 0, math.rad(Camera_Z))
		* CFrame.new(0, 0, Camera_Distance)

	if Camera_Distance > 0 and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		Camera.CFrame += Camera.CFrame.RightVector * 1.5
	elseif Camera_Distance ~= 0 then
	   UserInputService.MouseBehavior = rightclick and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
	end
	
	Camera_Distance = math.lerp(Camera_Distance, TargetCamDist, 1 - math.exp(-100 * DeltaTime))
end

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
	if GameProcessedEvent then
		return
	end

	if Input.KeyCode == leftAlignment then
		local rounded = math.ceil(Camera_X / HorizontalRotation) * HorizontalRotation
		if rounded == Camera_X then
			Camera_X += HorizontalRotation
		else
			Camera_X = rounded
		end
	elseif Input.KeyCode == rightAlignment then
		local rounded = math.floor(Camera_X / HorizontalRotation) * HorizontalRotation
		if rounded == Camera_X then
			Camera_X -= HorizontalRotation
		else
			Camera_X = rounded
		end
	elseif Input.KeyCode == downAlignment then
		Camera_Y -= VerticalRotation
	elseif Input.KeyCode == upAlignment then
		Camera_Y += VerticalRotation
	end

	Camera_Y = math.clamp(Camera_Y, -MaxVertical, MaxVertical)

	if Input.UserInputType == Enum.UserInputType.MouseButton2 and Camera_Distance > 0 then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		rightclick = true
	end
end)

UserInputService.InputEnded:Connect(function(Input, GameProcessedEvent)
	if Input.UserInputType == Enum.UserInputType.MouseButton2 and Camera_Distance > 0 then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		rightclick = false
	end
end)

UserInputService.InputChanged:Connect(function(Input, GameProcessedEvent)
	if GameProcessedEvent then
		return
	end

	if Input.UserInputType == Enum.UserInputType.MouseWheel then
		TargetCamDist = math.clamp(Camera_Distance - (Input.Position.Z * 2), 0, 128) 

		if TargetCamDist < 0.5 then
		    Camera_Distance = 0
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end
end)

Player.CharacterAdded:Connect(UpdateCharacter)
RunService.RenderStepped:Connect(UpdateCamera)
