
local Players = game:GetService('Players')

local DataStoreService = game:GetService('DataStoreService')
local CrumbsLeaderboardStore = DataStoreService:GetOrderedDataStore('CrumbsLeaderboard1')
local BreadsLeaderboardStore = DataStoreService:GetOrderedDataStore('BreadsLeaderboard1')
local StrikerLeaderboardStore = DataStoreService:GetOrderedDataStore('StrikerLeaderboard1')

local RelicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedCore = require(RelicatedStorage:WaitForChild('Core'))

local ReplicatedData = ReplicatedCore.ReplicatedData

local SystemsContainer = {}

local SaveData = false

-- // Module // --
local Module = {}

function Module:GetPlayerKey( PlayerUserId )
	return "KEY_"..PlayerUserId
end

function Module:UpdateLocalLeaderboards()
	-- set async current data
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		if not SaveData then
			continue
		end
		local keyString = Module:GetPlayerKey( LocalPlayer.UserId )
		local saveData = SystemsContainer.DataService:GetActiveSaveFromPlayer(LocalPlayer)
		if not saveData then
			continue
		end
		CrumbsLeaderboardStore:UpdateAsync(keyString, function(_)
			return saveData.Crumbs
		end)
		BreadsLeaderboardStore:UpdateAsync(keyString, function(_)
			return saveData.Bread
		end)
		StrikerLeaderboardStore:UpdateAsync(keyString, function(_)
			return saveData.PropKills
		end)
	end

	-- get ordered data
	local OrderedCrumbsStats = false
	local BreadsLeaderboardStats = false
	local StrikerLeaderboardStats = false
	pcall(function()
		OrderedCrumbsStats = CrumbsLeaderboardStore:GetSortedAsync(true, 50, 1)
	end)
	pcall(function()
		BreadsLeaderboardStats = BreadsLeaderboardStore:GetSortedAsync(true, 50, 1)
	end)
	pcall(function()
		StrikerLeaderboardStats = StrikerLeaderboardStore:GetSortedAsync(true, 50, 1)
	end)

	-- load leaderboard
	print(OrderedCrumbsStats, BreadsLeaderboardStats, StrikerLeaderboardStats)
	ReplicatedData:SetData('CrumbLeaderboard', OrderedCrumbsStats)
	ReplicatedData:SetData('BreadLeaderboard', BreadsLeaderboardStats)
	ReplicatedData:SetData('StrikerLeaderboard', StrikerLeaderboardStats)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
	task.spawn(function()
		while true do
			Module:UpdateLocalLeaderboards()
			task.wait(60)
		end
	end)
end

return Module

