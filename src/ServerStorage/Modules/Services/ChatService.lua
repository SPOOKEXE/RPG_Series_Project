
local Players = game:GetService('Players')

local ServerScriptService = game:GetService('ServerScriptService')
local ChatService = require(ServerScriptService:WaitForChild('ChatServiceRunner'):WaitForChild('ChatService'))

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

--local PremiumData = ReplicatedModules.Defined.Premium

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:SetExtraData( LocalPlayer, category, extraData )
	local speakerInstance = ChatService:GetSpeaker(LocalPlayer.Name)
	if not speakerInstance then
		return
	end
	speakerInstance:SetExtraData(category, extraData)
end

function Module:UpdateChatTags( LocalPlayer )
	--[[
		local chatTagTable = {}
		if PremiumData:OwnsGamepass(LocalPlayer, PremiumData.References.VIP) then
			table.insert(chatTagTable, { TagText = "VIP", TagColor = Color3.fromRGB(219, 199, 16) })
		end
		if LocalPlayer.MembershipType == Enum.MembershipType.Premium then
			table.insert(chatTagTable, { TagText = "Premium", TagColor = Color3.fromRGB(114, 219, 16) })
		end
		Module:SetExtraData(LocalPlayer, 'Tags', chatTagTable)
	]]
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		task.defer(function()
			Module:UpdateChatTags( LocalPlayer )
		end)
		LocalPlayer.CharacterAdded:Connect(function(_)
			Module:UpdateChatTags( LocalPlayer )
		end)
	end

	Players.PlayerAdded:Connect(function(LocalPlayer)
		Module:UpdateChatTags( LocalPlayer )
	end)
end

return Module
