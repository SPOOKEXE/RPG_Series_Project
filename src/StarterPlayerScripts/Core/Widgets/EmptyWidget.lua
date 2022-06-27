
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')
local LocalModules = require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local SystemsContainer = {}

-- // Module // --
local Module = { Open = false }
Module.WidgetMaid = ReplicatedModules.Classes.Maid.New()

function Module:UpdateWidget()
	
end

function Module:OpenWidget()
	if Module.Open then
		return
	end
	Module.Open = true
end

function Module:CloseWidget()
	if not Module.Open then
		return
	end
	Module.Open = false
	Module.WidgetMaid:Cleanup()
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems
end

return Module
