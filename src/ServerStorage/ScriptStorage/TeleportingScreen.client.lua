
local TeleportService = game:GetService('TeleportService')
local ReplicatedFirst = game:GetService('ReplicatedFirst')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer :: Player

local screenGui = TeleportService:GetArrivingTeleportGui()
if screenGui then
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	screenGui.Parent = LocalPlayer:WaitForChild('PlayerGui')
	return
end

local function GenerateBasicData( BackgroundProperties, LabelProperties, UIStrokeProperties )
	return {
		Background = { Properties = BackgroundProperties, },
		Label = { Properties = LabelProperties, UIStroke = UIStrokeProperties, },
	}
end

local TeleportMatchCache = {
	Default = GenerateBasicData(
		{ Image = 'rbxassetid://0', },
		{ TextColor3 = Color3.new(1, 1, 1), Position = UDim2.fromScale(0.023, 0.818), Size = UDim2.fromScale(0.3, 0.2), },
		{ Enabled = true, Color = Color3.new(), Thickness = 3, }
	),

	['9775667497'] = GenerateBasicData(
		{ Image = 'rbxassetid://0', },
		{ TextColor3 = Color3.new(1, 1, 1), Position = UDim2.fromScale(0.023, 0.818), Size = UDim2.fromScale(0.3, 0.2), },
		{ Enabled = true, Color = Color3.new(), Thickness = 3, }
	),
}

local JoinData = LocalPlayer:GetJoinData()
print(JoinData)
local GuiData = TeleportMatchCache[game.PlaceId]
if JoinData and JoinData.SourcePlaceId then
	if GuiData then
		print(GuiData)
	else
		warn('No Custom Load Screen for PlaceId ', game.PlaceId)
	end
end



