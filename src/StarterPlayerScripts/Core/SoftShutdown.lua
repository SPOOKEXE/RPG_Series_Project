local TeleportService = game:GetService('TeleportService')
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService('TweenService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalFolder = LocalPlayer:WaitForChild('PlayerScripts')
local LocalAssets = LocalFolder:WaitForChild('Assets')
local LocalModules = require(LocalFolder:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local ShutdownRemote = RemoteService:GetRemote('SoftShutdown', 'RemoteEvent', false)
local ShutdownInfoFunc = RemoteService:GetRemote('ShutdownInfo', 'RemoteFunction', false)

local HasShutdown = false

local SystemsContainer = {}

local ShutdownUI = LocalAssets.UI.SoftShutdown:Clone()
ShutdownUI.Enabled = true

-- // Module // --
local Module = {}

function Module:OnSoftShutdown() : nil
	if HasShutdown then
		return
	end
	HasShutdown = true

	for _,I in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
		I.Parent = script
	end
	LocalAssets.Sounds.SoftShutdownSound:Play()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	TeleportService:SetTeleportGui(script.Parent)
	ShutdownUI.Parent = LocalPlayer.PlayerGui
	local SpinTween = TweenService:Create(ShutdownUI.Frame.UIGradient, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {Rotation = -45})
	local SpinTween2 = TweenService:Create(ShutdownUI.Frame.UIGradient, TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 1), {Rotation = 90})
	SpinTween.Completed:Connect(function()
		SpinTween2:Play()
	end)
	SpinTween2.Completed:Connect(function()
		SpinTween:Play()
	end)
	for i = 5, 0, -1 do
		ShutdownUI.Time.Text = 'Teleporting within '..i..' seconds.'
		ShutdownUI.Time.Detail.Text = ShutdownUI.Time.Text
		task.wait(1)
	end
	ShutdownUI.Time.Text = 'Teleporting'
	ShutdownUI.Time.Detail.Text = ShutdownUI.Time.Text
	task.wait(2)
	TweenService:Create(ShutdownUI.Curtain, TweenInfo.new(1.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {Position = UDim2.new(0,0,0,0)}):Play()
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	task.defer(function()
		if ShutdownInfoFunc:InvokeServer() then
			print('Shutdown Server')
			Module:OnSoftShutdown()
		else
			print('Live Server')
			ShutdownRemote.OnClientEvent:Connect(function()
				Module:OnSoftShutdown()
			end)
		end
	end)
end

return Module
