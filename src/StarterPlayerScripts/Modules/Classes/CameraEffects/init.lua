
local TweenService = game:GetService('TweenService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local CurrentCamera = workspace.CurrentCamera

local CameraShakerModule = require(script.CameraShaker)
local CameraShaker = CameraShakerModule.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

-- // Module // --
local Module = { CameraShakerModule = CameraShakerModule, CameraShaker = CameraShaker }

return Module
