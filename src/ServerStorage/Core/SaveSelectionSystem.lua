
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedCore = require(ReplicatedStorage:WaitForChild('Core'))
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local ReplicatedData = ReplicatedCore.ReplicatedData

local RemoteService = ReplicatedModules.Services.RemoteService
local TimeUtility = ReplicatedModules.Utility.Time

local SystemsContainer = {}

local GetSaveDataFunction = RemoteService:GetRemote('GetSaveData', 'RemoteFunction', false)
local SaveDataHandlerFunction = RemoteService:GetRemote('SaveDataFunction', 'RemoteFunction', false)

local ActiveSaveCache = {}

local MAX_SAVES = 3
local INCORRECT_DATA_VERSION = 'The incorrect reconcile function has been called, expected Version [%s] got Version [%s]'

local function CheckDataVersion( ReconcileVersion, Profile )
	if Profile.Data.Version >= ReconcileVersion then
		error(string.format(INCORRECT_DATA_VERSION, ReconcileVersion, Profile.Data.Version))
	end
end

-- // Module // --
local Module = {}

local function CheckMissingIndexes( Profile )
	local Sample = Module:GenerateSaveData()
	for _, saveTable in ipairs( Profile.Data.Saves ) do
		for saveDataIndex, saveDataValue in pairs(Sample) do
			if not saveTable[saveDataIndex] then
				warn('Index was missing ; ', saveDataIndex)
				saveTable[saveDataIndex] = saveDataValue
			end
		end
	end
end

local ReconcileGameData = {
	[1] = function(Profile) -- from version 0 to version 1 (this one doesnt run)
		-- edit inventory, etc
	end,
	--[[
		[2] = function(Profile) -- from version 1 to version 2
			-- edit inventory, etc
		end,
	]]
}

local ReconcileFromPrevious = {
	[1] = function(Profile) -- from version 0 to version 1 (this one doesnt run)
		CheckDataVersion( 0, Profile ) -- make sure version matches the reconcile function's requisite
		CheckMissingIndexes( Profile ) -- check for indexes that aren't found
		if ReconcileGameData[1] then
			ReconcileGameData[1](Profile)
		end
		Profile.Data.Version = 1 -- set the new version
	end,
	--[[
		[2] = function(Profile) -- from version 1 to version 2
			CheckDataVersion( 1, Profile )
			CheckMissingIndexes( Profile )
			if ReconcileGameData[1] then
				ReconcileGameData[1](Profile)
			end
			Profile.Data.Version = 2
		end
	]]
}

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

		-- progression data
		--[[
			MenusUnlocked = {
				HasDoneTutorial = false,

				Magic = false,
				Inventory = false,
				Boosters = false,
				Achievements = false,
				Codes = false,
				PlayerProfile = false,
				Premium = false,
				Attributes = false,
				TradeStart = false,
				TopLeftInfo = false,
				Hotbar = false,
				Quests = false,

				ExtraMenu = true,
				Settings = true,
				LogMenu = true,
			},
		]]
	}

	Template.CreationUTC = TimeUtility:GetUTC()

	return Template
end

function Module:ReconcileSaveData(Profile, GameVersion)
	local currentProfileVersion = Profile.Data.Version
	while currentProfileVersion < GameVersion do
		local reconcileFunction = ReconcileFromPrevious[currentProfileVersion + 1]
		if not reconcileFunction then
			warn('Could not find reconcile function for data version ', currentProfileVersion + 1)
			return false, 'Could not find reconcile function #'..currentProfileVersion + 1
		end
		local success, err = pcall(function()
			reconcileFunction(Profile)
		end)
		if success then
			-- backup incase the version does not increment
			if Profile.Data.Version ~= currentProfileVersion + 1 then
				Profile.Data.Version += 1
			end
			currentProfileVersion = Profile.Data.Version
			local userIdtext = '{'..table.concat(Profile.UserIds, '-')..'}'
			warn('Profile '..userIdtext..' has reconciled to data Version '..currentProfileVersion)
		else
			warn('Could not reconcile profile to latest data version. ', err)
			return false, err
		end
	end
	return true
end

function Module:CheckReconcileStatus(Profile, GameDataVersion)
	local currentProfileVersion = Profile.Data.Version
	if currentProfileVersion == GameDataVersion then
		print('Profile is matching with the current data version.')
		return true
	end
	if currentProfileVersion < GameDataVersion then
		return Module:ReconcileSaveData(Profile, GameDataVersion)
	end
	warn("This server is outdated! There is apparently data that has a greater version than this server's highest version!")
	return true
end

function Module:GetClientSaveSelectionData( LocalPlayer )
	local Profile = SystemsContainer.DataSystem:GetProfileFromPlayer(LocalPlayer, true)
	if not Profile then
		return false, 'Profile failed to load.'
	end
	-- change the format here to whatever is needed
	local profileSelectionData = {}
	for slotIndex, slotData in ipairs( Profile.Data.Saves ) do
		table.insert(profileSelectionData, {
			SlotIndex = slotIndex,
			-- level / currency
			Level = slotData.Level,
			Currency = slotData.Currency,
			-- render character data
			Inventory = slotData.Inventory,
			ActiveEquipped = slotData.ActiveEquipped,
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
	if #Profile.Data.Saves >= MAX_SAVES then
		return false
	end
	local newSaveData = Module:GenerateSaveData()
	table.insert(Profile.Data.Saves, newSaveData)
	return newSaveData, #Profile.Data.Saves -- (Data, Index)
end

function Module:DeleteSaveIndex( LocalPlayer, SaveIndex )
	local Profile = SystemsContainer.DataSystem:GetProfileFromPlayer(LocalPlayer)
	if not Profile then
		return false
	end
	local saveData = Profile.Data.Saves[SaveIndex]
	if saveData then
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