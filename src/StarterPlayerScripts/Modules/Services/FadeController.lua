
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local MaidClass = ReplicatedModules.Classes.Maid

local FadeScreenGui = Instance.new('ScreenGui')
FadeScreenGui.Name = 'ScreenFadeGui'
FadeScreenGui.IgnoreGuiInset = true
FadeScreenGui.ResetOnSpawn = false
FadeScreenGui.Parent = LocalPlayer:WaitForChild('PlayerGui')

local LinearFadeFrame = Instance.new('Frame')
LinearFadeFrame.Name = 'LinearFadeFrame'
LinearFadeFrame.BackgroundTransparency = 1
LinearFadeFrame.Size = UDim2.fromScale(1, 1)
LinearFadeFrame.BorderSizePixel = 0
LinearFadeFrame.Parent = FadeScreenGui

-- // Module // --
local Module = {}

Module.RunningTweenID = false
Module.TweenMaidInstance = MaidClass.New()

local function StartNewTweenID()
	Module.TweenMaidInstance:Cleanup()
	local ID = HttpService:GenerateGUID(false)
	Module.RunningTweenID = ID
	return ID
end

local function IsRunningID( passedID )
	return Module.RunningTweenID == passedID
end

-- // MAIN // --
function Module:YieldForID( passedID )
	while Module.RunningTweenID == passedID do
		task.wait(0.1)
	end
end

function Module:LinearFadeIn( Duration )
	Duration = Duration or 0.25

	local ID = StartNewTweenID()
	local tweenInfo = TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local TweenInstance = TweenService:Create(LinearFadeFrame, tweenInfo, {Transparency = 0})

	Module.TweenMaidInstance:Give(TweenInstance.Completed:Connect(function()
		if IsRunningID(ID) then
			Module.TweenMaidInstance:Cleanup()
		end
	end))

	Module.TweenMaidInstance:Give(function()
		LinearFadeFrame.Transparency = 0
	end)

	Module.ActiveTweenInstance = TweenInstance
	TweenInstance:Play()

	return ID, TweenInstance
end

function Module:LinearFadeOut(Duration)
	Duration = Duration or 0.25

	local ID = StartNewTweenID()
	local tweenInfo = TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local TweenInstance = TweenService:Create(LinearFadeFrame, tweenInfo, {Transparency = 1})

	Module.TweenMaidInstance:Give(TweenInstance.Completed:Connect(function()
		if IsRunningID(ID) then
			Module.TweenMaidInstance:Cleanup()
		end
	end))

	Module.TweenMaidInstance:Give(function()
		LinearFadeFrame.Transparency = 1
	end)

	Module.ActiveTweenInstance = TweenInstance
	TweenInstance:Play()

	return ID, TweenInstance
end

function Module:SquareSlicesFadeIn()
	
end

function Module:SquareSlicesFadeOut()
	
end

return Module

