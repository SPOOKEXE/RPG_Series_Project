
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedCore = require(ReplicatedStorage:WaitForChild('Core'))
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local ReplicatedData = ReplicatedCore.ReplicatedData

local SaveSlotsConfig = ReplicatedModules.Data.SaveSlotsConfig
local RemoteService = ReplicatedModules.Services.RemoteService
local TimeUtility = ReplicatedModules.Utility.Time

local SystemsContainer = {}

local GetSaveDataFunction = RemoteService:GetRemote('GetSaveData', 'RemoteFunction', false)
local SaveDataHandlerFunction = RemoteService:GetRemote('SaveDataFunction', 'RemoteFunction', false)

local ActiveSaveCache = {}

-- // Module // --
local Module = {}

function Module:GenerateSaveData()

	local Template = {
		CreationUTC = -1,

		CustomCharacter = false, -- ends up being { Race = "", Hair = 3, Shirt = 4, Pants = 7, Face = 2 }

		Level = 1, -- player's level
		Experience = 0, -- player's experience
		Currency = { 0, 0, 0, 0 }, -- currency; copper, silver, gold, platinum

		Inventory = {}, -- inventory, create a UUID cache table to be used with the game so its faster (don't save it tho)
		ActiveEquipped = {}, -- items that are equipped (by UUID)

		-- attributes
		Attributes = { }, -- Attribute Tree

		-- skills
		SkillPoints = 0, -- Skill Unlocking Points
		Skills = { }, -- Skill Tree

		-- quests
		Quests = { },
		CompletedQuests = { },

		-- codes system
		RedeemedCodes = { },
		CodeTimers = { },

		-- achievements
		Achievements = { },
	}

	Template.CreationUTC = TimeUtility:GetUTC()

	return Template
end

function Module:GetClientSaveSelectionData( LocalPlayer )
	local Profile = SystemsContainer.DataSystem:GetProfileFromPlayer(LocalPlayer, true)
	if not Profile then
		return false, 'Profile failed to load.'
	end
	-- change the format here to whatever is needed
	local profileSelectionData = {}
	for slotIndex, saveData in ipairs( Profile.Data.Saves ) do
		table.insert(profileSelectionData, {
			SlotIndex = slotIndex,
			-- level / currency
			Level = saveData.Level,
			Currency = saveData.Currency,
			-- render character data
			Inventory = saveData.Inventory,
			ActiveEquipped = saveData.ActiveEquipped,
			CustomCharacter = saveData.CustomCharacter
		})
	end
	return profileSelectionData
end

function Module:SetActiveSaveNumber( LocalPlayer, SaveNumber )
	if typeof(SaveNumber) == 'number' then
		ActiveSaveCache[LocalPlayer] = SaveNumber
	end
end

function Module:GetActiveSaveData( LocalPlayer, Yield )
	local activeSaveNumber = ActiveSaveCache[LocalPlayer]
	while Yield and LocalPlayer and (LocalPlayer.Parent == Players) and (not ActiveSaveCache[LocalPlayer]) do
		task.wait(0.1)
	end
	local Profile = SystemsContainer.DataSystem:GetProfileFromPlayer(LocalPlayer)
	if activeSaveNumber and Profile then
		return Profile.Data.Saves[activeSaveNumber] or false
	end
	return false
end

function Module:CreateNewSaveSlot( LocalPlayer )
	local Profile = SystemsContainer.DataSystem:GetProfileFromPlayer(LocalPlayer)
	if not Profile then
		return false
	end
	if #Profile.Data.Saves >= SaveSlotsConfig.MAX_SAVES then
		return false
	end
	local newCharacterData = SystemsContainer.CharacterCreationSystem:GetNewlyCreatedCharacter( LocalPlayer )
	print(newCharacterData)
	if not newCharacterData then
		return false
	end
	local newSaveData = Module:GenerateSaveData()
	newSaveData.CustomCharacter = newCharacterData
	table.insert(Profile.Data.Saves, newSaveData)
	return newSaveData, #Profile.Data.Saves -- (Data, Index)
end

function Module:DeleteSaveIndex( LocalPlayer, SaveIndex )
	local Profile = SystemsContainer.DataSystem:GetProfileFromPlayer(LocalPlayer)
	if not Profile then
		return false
	end
	local saveData = Profile.Data.Saves[SaveIndex]
	if saveData and saveData.Level > 2 then
		table.remove( Profile.Data.Saves, SaveIndex)
		saveData.DeletedUTC = TimeUtility:GetUTC()
		table.insert( Profile.Data.DeletedSaves, saveData )
	end
end

function Module:LoadPlayerIntoGame( LocalPlayer )
	local activeSaveData = Module:GetActiveSaveData(LocalPlayer)
	if not activeSaveData then
		return false
	end
	ReplicatedData:SetData('PlayerData', activeSaveData, {LocalPlayer})
end

function Module:ReturnToMenu( LocalPlayer )
	ReplicatedData:RemoveAllForPlayer('PlayerData', LocalPlayer)
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	Players.PlayerRemoving:Connect(function(LocalPlayer)
		ActiveSaveCache[LocalPlayer] = nil
	end)

	GetSaveDataFunction.OnServerInvoke = function(LocalPlayer)
		return Module:GetClientSaveSelectionData(LocalPlayer)
	end

	SaveDataHandlerFunction.OnServerInvoke = function(LocalPlayer, Job, Arg)
		if Job == 'SelectSave' then
			Module:SetActiveSaveNumber(LocalPlayer, Arg)
			Module:LoadPlayerIntoGame(LocalPlayer)
			return true
		elseif Job == 'CreateSave' then
			Module:CreateNewSaveSlot(LocalPlayer)
			return true
		elseif Job == 'DeleteSave' then
			Module:DeleteSaveIndex(LocalPlayer, Arg)
			return true
		elseif Job == 'ReturnToMenu' then
			Module:ReturnToMenu(LocalPlayer)
			return true
		end
		return false
	end
end

return Module