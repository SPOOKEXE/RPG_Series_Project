
local RelicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedCore = require(RelicatedStorage:WaitForChild('Core'))

local ReplicatedData = ReplicatedCore.ReplicatedData

--local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:LeaderboardUpdate( Category, Data )
	if not Data then
		return
	end
	print('Leaderboard Update;', Category, Data)
end

function Module:Init(_)
	--SystemsContainer = otherSystems

	ReplicatedData.OnUpdate:Connect(function(Category, Data)
		if Category == 'CrumbLeaderboard' or Category == 'BreadLeaderboard' or Category == 'StrikerLeaderboard' then
			Module:LeaderboardUpdate( Category, Data )
		end
	end)

	task.defer(function()
		Module:LeaderboardUpdate( 'CrumbLeaderboard', ReplicatedData:GetData('CrumbLeaderboard') )
		Module:LeaderboardUpdate( 'BreadLeaderboard', ReplicatedData:GetData('BreadLeaderboard') )
		Module:LeaderboardUpdate( 'StrikerLeaderboard', ReplicatedData:GetData('StrikerLeaderboard') )
	end)
end

return Module

