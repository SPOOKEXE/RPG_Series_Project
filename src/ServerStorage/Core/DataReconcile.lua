
local SystemsContainer = {}

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

function Module:Init( otherSystems )
	SystemsContainer = otherSystems
end

return Module
