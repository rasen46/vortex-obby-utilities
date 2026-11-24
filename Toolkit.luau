--[[
	Obby toolkit (standalone version)
	by rasen46

	last update: 11/24/2026
	v1.0.8 
]]

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserSettings = game:GetService("UserGameSettings")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = Workspace.CurrentCamera

local dVect = Vector3.new(0,-0.0001,0)

local Configuration = {
	KEYBINDS = {
		-- alljump
		[Enum.KeyCode.F] = "SetCheckpoint",
		[Enum.KeyCode.R] = "GoToLastCheck",
		[Enum.KeyCode.V] = "RemoveLastCheck",

		-- noclip
		[Enum.KeyCode.N] = "NoclipSlow",
		[Enum.KeyCode.M] = "NoclipSpeed",
		[Enum.KeyCode.B] = "NoclipSpeedReset",
		[Enum.KeyCode.One] = "Noclip",
		[Enum.KeyCode.Space] = "NoclipUp",
		[Enum.KeyCode.LeftControl] = "NoclipDown",
		
		-- alignment keys 
		[Enum.KeyCode.G] = "LeftAlignment",
		[Enum.KeyCode.H] = "RightAlignment",
		[Enum.KeyCode.U] = "UpAlignment",
		[Enum.KeyCode.J] = "DownAlignment",
	},

	AJ = {
		Size = Vector3.new(0.25, 0.25, 0.25),
		Color3 = Color3.new(1, 1, 1),
		Transparency = 0.5,
		ShowIndicators = true,
		CentertoHRP = true,
	},

	NC = {
		NoclipSpeedDefault = 50,
		NoclipSpeedIncrement = 5,
	},
	
	AK = {
        HorizontalRotation = 45,
        VerticalRotation = 30,
        MaxVertical = 80,
	},
}

local keys = {
	W = false,
	A = false,
	S = false,
	D = false,
	up = false,
	down = false,
}

local noclip = false
local speed = Configuration.NC.NoclipSpeedDefault
local targetCF

local cCount = 0
local Checkpoints = {}
local CheckpointParts = {}

local Camera = workspace.CurrentCamera

local Camera_X = 0
local Camera_Y = 0
local Camera_Z = 0
local Camera_Distance = 20
local TargetCamDist = 20

local rightclick = false

local spawnLocation = workspace:FindFirstChild("SpawnLocation")
local spawnCFrame = spawnLocation and spawnLocation.CFrame or CFrame.new(0, 0, 0)

if not spawnLocation then
	warn("Could not find any part named SpawnLocation, defaulting to 0, 0, 0")
end

local function createAJPart()
	local part = Instance.new("Part")

	part.Anchored = true
	part.CanCollide = false

	part.Size = Configuration.AJ.Size
	part.Color = Configuration.AJ.Color3
	part.Transparency = Configuration.AJ.ShowIndicators and Configuration.AJ.Transparency or 1

	part.Parent = Workspace

	return part
end

UIS.InputBegan:Connect(function(inp, pro)
	if pro then
		return
	end

	local key = inp.KeyCode.Name
	local keyEvent = Configuration.KEYBINDS[inp.KeyCode]
	local CurChar = player.Character
	local HRP = CurChar:FindFirstChild("HumanoidRootPart")
	local HRPCFrame = HRP.CFrame

	if keys[key] ~= nil then
		keys[key] = true
	end

	if keyEvent == "Noclip" then
		noclip = not noclip
		if noclip then
			targetCF = HRP.CFrame
		end
	elseif keyEvent == "NoclipUp" then
		keys.up = true
	elseif keyEvent == "NoclipDown" then
		keys.down = true
	elseif keyEvent == "SetCheckpoint" then
		cCount += 1

		local n = createAJPart()
		n.CFrame = if Configuration.AJ.CentertoHRP then HRPCFrame else (HRPCFrame + Vector3.new(0, 2.5, 0))

		CheckpointParts[cCount] = n
		Checkpoints[cCount] = { Pivot = HRPCFrame, Velocity = HRP.AssemblyLinearVelocity }
	elseif keyEvent == "GoToLastCheck" then
		local data = Checkpoints[cCount]
			or {
				Pivot = spawnLocation.CFrame
					+ Vector3.new(0, 2.5, 0)
					+ Vector3.new(0, (if spawnLocation.Size then spawnLocation.Size.Y else 0), 0),
				Velocity = Vector3.zero,
			}

		if not data then
			return
		end

		HRP.CFrame = data.Pivot
		HRP.AssemblyLinearVelocity = data.Velocity
	elseif keyEvent == "RemoveLastCheck" then
		if not Checkpoints[cCount] then
			return
		end

		CheckpointParts[cCount]:Destroy()
		CheckpointParts[cCount] = nil
		Checkpoints[cCount] = nil

		cCount -= 1
	elseif keyEvent == "NoclipSlow" then
		speed -= Configuration.NC.NoclipSpeedIncrement
	elseif keyEvent == "NoclipSpeed" then
		speed += Configuration.NC.NoclipSpeedIncrement
	elseif keyEvent == "NoclipSpeedReset" then
		speed = Configuration.NC.NoclipSpeedDefault
	elseif keyEvent == "LeftAlignment" then
		local rounded = math.ceil(Camera_X / Configuration.AK.HorizontalRotation) * Configuration.AK.HorizontalRotation
		if rounded == Camera_X then
			Camera_X += Configuration.AK.HorizontalRotation
		else
			Camera_X = rounded
		end
	elseif keyEvent == "RightAlignment" then
		local rounded = math.floor(Camera_X / Configuration.AK.HorizontalRotation) * Configuration.AK.HorizontalRotation
		if rounded == Camera_X then
			Camera_X -= Configuration.AK.HorizontalRotation
		else
			Camera_X = rounded
		end
	elseif keyEvent == "UpAlignment" then
	    Camera_Y += Configuration.AK.VerticalRotation
	elseif keyEvent == "DownAlignment" then
	    Camera_Y -= Configuration.AK.VerticalRotation
	end
	
	Camera_Y = math.clamp(Camera_Y, -Configuration.AK.MaxVertical, Configuration.AK.MaxVertical)
	speed = math.max(0, speed)
end)

UIS.InputEnded:Connect(function(inp)
	local key = inp.KeyCode.Name
	local keyEvent = Configuration.KEYBINDS[inp.KeyCode]
	
	if inp.UserInputType == Enum.UserInputType.MouseButton2 and Camera_Distance > 0 then
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		rightclick = false
	end

	if keys[key] ~= nil then
		keys[key] = false
	elseif keyEvent == "NoclipUp" then
		keys.up = false
	elseif keyEvent == "NoclipDown" then
		keys.down = false
	end
end)

UIS.InputChanged:Connect(function(Input, GameProcessedEvent)
	if GameProcessedEvent then
		return
	end

	if Input.UserInputType == Enum.UserInputType.MouseWheel then
		TargetCamDist = math.clamp(Camera_Distance - (Input.Position.Z * 2), 0, 128) 

		if TargetCamDist < 0.5 then
		    Camera_Distance = 0
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		else
			UIS.MouseBehavior = Enum.MouseBehavior.Default
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
    local character = player.Character
	local HRP = character:FindFirstChild("HumanoidRootPart")
	if not character or not HRP then
		return
	end
	
	local Delta = UIS:GetMouseDelta()

	Camera_X -= Delta.X * UserSettings.MouseSensitivity * 0.25
	Camera_Y = math.clamp(Camera_Y - Delta.Y * UserSettings.MouseSensitivity * 0.25, -Configuration.AK.MaxVertical, Configuration.AK.MaxVertical)

	local Origin = HRP.Position
+ Vector3.new(0,1.5,0)

	Camera.CFrame = CFrame.new(Origin)
		* CFrame.Angles(0, math.rad(Camera_X), 0)
		* CFrame.Angles(math.rad(Camera_Y), 0, math.rad(Camera_Z))
		* CFrame.new(0, 0, Camera_Distance)

	if Camera_Distance > 0 and UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
		Camera.CFrame += Camera.CFrame.RightVector * 1.5
	elseif Camera_Distance ~= 0 then
	   UIS.MouseBehavior = rightclick and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
	end
	
	Camera_Distance = math.lerp(Camera_Distance, TargetCamDist, 1 - math.exp(-100 * dt))

	if not noclip then
		return
	end

	local cameraCF = Workspace.CurrentCamera.CFrame
	local forward = Vector3.new(cameraCF.LookVector.X, 0, cameraCF.LookVector.Z)
	local right = Vector3.new(cameraCF.RightVector.X, 0, cameraCF.RightVector.Z)

	if forward.Magnitude > 0 then
		forward = forward.Unit
	end
	if right.Magnitude > 0 then
		right = right.Unit
	end

	local direction = Vector3.zero
	local mDir = character.Humanoid.MoveDirection

	direction += Vector3.new(mDir.X, 0, mDir.Z)

	if keys.up then
		direction += Vector3.yAxis
	end
	if keys.down then
		direction -= Vector3.yAxis
	end

	if direction.Magnitude > 0 then
		direction = direction.Unit
	end
	local newCF = targetCF + direction * speed * dt

	targetCF = newCF
	HRP.Position = newCF.Position
	HRP.AssemblyLinearVelocity = dVect
end)
