--!strict
--[[
	Builds the Charmdesk play space if Rojo did not instance it.
]]

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

Lighting.Ambient = Color3.fromRGB(26, 21, 35)
Lighting.OutdoorAmbient = Color3.fromRGB(36, 28, 48)
Lighting.Brightness = 1.2
Lighting.ClockTime = 20
Lighting.FogColor = Color3.fromRGB(26, 21, 35)
Lighting.FogEnd = 220
Lighting.GlobalShadows = false

if not Workspace:FindFirstChild("Charmdesk") then
	local folder = Instance.new("Folder")
	folder.Name = "Charmdesk"
	folder.Parent = Workspace

	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Anchored = true
	floor.Size = Vector3.new(80, 1, 80)
	floor.Position = Vector3.new(0, 0, 0)
	floor.Color = Color3.fromRGB(26, 21, 35)
	floor.Material = Enum.Material.SmoothPlastic
	floor.Parent = folder

	local desk = Instance.new("Part")
	desk.Name = "Desk"
	desk.Anchored = true
	desk.Size = Vector3.new(18, 1.2, 10)
	desk.Position = Vector3.new(0, 4, -6)
	desk.Color = Color3.fromRGB(92, 64, 51)
	desk.Material = Enum.Material.Wood
	desk.Parent = folder

	local blotter = Instance.new("Part")
	blotter.Name = "Blotter"
	blotter.Anchored = true
	blotter.Size = Vector3.new(12, 0.2, 7)
	blotter.Position = Vector3.new(0, 4.7, -6)
	blotter.Color = Color3.fromRGB(244, 233, 216)
	blotter.Material = Enum.Material.SmoothPlastic
	blotter.Parent = folder

	local core = Instance.new("Part")
	core.Name = "GlintCore"
	core.Shape = Enum.PartType.Ball
	core.Anchored = true
	core.Size = Vector3.new(3.2, 3.2, 3.2)
	core.Position = Vector3.new(0, 7.2, -6)
	core.Color = Color3.fromRGB(230, 184, 77)
	core.Material = Enum.Material.Neon
	core.Parent = folder

	local light = Instance.new("PointLight")
	light.Brightness = 2
	light.Range = 16
	light.Color = Color3.fromRGB(230, 184, 77)
	light.Parent = core

	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 32
	click.Parent = core
	click.MouseClick:Connect(function(player)
		local ev = game.ReplicatedStorage:FindFirstChild("COSGRemotes")
		-- Client owns click cadence; this is a 3D affordance. The HUD button is primary.
		if player and player:IsA("Player") then
			core.Size = Vector3.new(3.6, 3.6, 3.6)
			task.delay(0.08, function()
				if core.Parent then
					core.Size = Vector3.new(3.2, 3.2, 3.2)
				end
			end)
		end
	end)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = Vector3.new(0, 1, 8)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = folder
end

local function camera(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart", 8)
	if hrp and hrp:IsA("BasePart") then
		hrp.CFrame = CFrame.new(0, 6, 14)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		camera(player)
	end)
end)
