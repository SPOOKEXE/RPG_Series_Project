
local Players = game:GetService('Players')

local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedSystems = require(ReplicatedStorage:WaitForChild('Core'))
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local ProfileService = ServerModules.Services.ProfileService
local ReplicatedData = ReplicatedSystems.ReplicatedData

local GameProfileStore = ProfileService.GetProfileStore('PlayerData1', {
	Banned = false,

	Tags = {},
	PurchaseHistory = {},
}).Mock

local SystemsContainer = {}

local ProfileCache = {}
local Loading = {}

-- // Module // --
local Module = {}

-- Get player key from userid
function Module:GetPlayerKey(Id)
	return tostring(Id)
end

-- Wipes a player's progress
function Module:WipePlayerProgress(LocalPlayer)
	GameProfileStore:WipeProfileAsync(Module:GetPlayerKey(LocalPlayer.UserId))
end

-- Write custom data to the player's data.
-- Can be used to "reconcile" custom data for specific players using the tag table (or metatags).
function Module:CustomPlayerDataWrite(LocalPlayer, Profile)
	
end

-- Get the player's profile if it is available (unless yielded)
function Module:GetProfileFromPlayer(LocalPlayer, Yield)
	if Yield then
		local startTick = tick()
		repeat
			task.wait(0.1)
		until ProfileCache[LocalPlayer.UserId] or (tick() - startTick) > 10
	end
	return ProfileCache[LocalPlayer.UserId]
end

-- Load the profile from the given ID (will prevent more requests via a lock mechanism)
function Module:LoadProfileFromId(Id)
	if Loading[Id] then
		repeat task.wait(0.1)
		until not Loading[Id]
	end
	if ProfileCache[Id] then
		return ProfileCache[Id]
	end
	Loading[Id] = true
	local profile = GameProfileStore:LoadProfileAsync(tonumber(Id) and Module:GetPlayerKey(Id) or Id, "ForceLoad")
	ProfileCache[Id] = profile
	Loading[Id] = nil
	return profile
end

-- Load player's profile
function Module:LoadPlayerProfile(LocalPlayer)
	local profile = Module:LoadProfileFromId(LocalPlayer.UserId)
	if profile then
		profile:Reconcile()
		profile:AddUserId(LocalPlayer.UserId) -- GDPR compliance
		profile:ListenToRelease(function()
			ProfileCache[LocalPlayer.UserId] = nil
			if not profile.Data.Banned then
				LocalPlayer:Kick('Profile loaded on a different server.')
			end
		end)
		if LocalPlayer:IsDescendantOf(Players) then
			Module:CustomPlayerDataWrite(LocalPlayer, profile)
			local IsBanned = SystemsContainer.BanSystem:CheckProfileBanExpired(LocalPlayer, profile)
			if IsBanned then
				profile:Release()
				local BanMessage = SystemsContainer.BanSystem:CompileBanMessage(profile.Data.Banned)
				LocalPlayer:Kick(BanMessage)
				return false
			end
			ProfileCache[LocalPlayer.UserId] = profile
		else
			profile:Release()
			ProfileCache[LocalPlayer.UserId] = nil
		end
	end
	return profile
end

-- When a player joins the game
function Module:OnPlayerAdded(LocalPlayer)
	if ProfileCache[LocalPlayer] then
		return
	end
	local playerProfile = Module:LoadPlayerProfile(LocalPlayer)
	if not playerProfile then
		warn('PlayerData did not load: ', LocalPlayer.Name)
		return
	end
	ReplicatedData:SetData('PlayerData', playerProfile.Data, {LocalPlayer})
	return playerProfile
end

-- initializer
function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	if SystemsContainer.SoftShutdown:IsShutdownServer() then
		return false
	end

	Players.PlayerRemoving:Connect(function(LocalPlayer)
		local Profile = ProfileCache[LocalPlayer.UserId]
		if Profile then
			Profile:Release()
			ProfileCache[LocalPlayer.UserId] = nil
		end
	end)

	for _, LocalPlayer in ipairs(Players:GetPlayers()) do
		task.defer(function()
			Module:OnPlayerAdded(LocalPlayer)
		end)
	end

	Players.PlayerAdded:Connect(function(LocalPlayer)
		Module:OnPlayerAdded(LocalPlayer)
	end)
end

return Module
