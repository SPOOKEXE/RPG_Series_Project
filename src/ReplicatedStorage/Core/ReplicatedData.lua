
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local HttpService = game:GetService('HttpService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Debounce = ReplicatedModules.Utility.Debounce

local DataRemote = ReplicatedModules.Services.RemoteService:GetRemote('DataRemote', 'RemoteEvent', false)

local Module = {}

warn(string.format('[%s] Replicated Data', RunService:IsServer() and 'Server' or 'Client'))

if RunService:IsServer() then
	local onDataUpdated = ReplicatedModules.Classes.Event.New("onDataUpdated")
	Module.OnDataUpdated = onDataUpdated

	local comparisonCache = { Private = {}, Public = {} }
	local activeReplications = { Private = {}, Public = {} }
	Module.Cache = activeReplications

	-- Check if data has updated
	function Module:CheckDataUpdated( Category, Data, PlayerTable )
		local newCacheString = HttpService:JSONEncode(Data)
		if PlayerTable then
			local cacheIndex = Category..tostring(PlayerTable)
			if (not comparisonCache.Private[cacheIndex]) or (newCacheString ~= comparisonCache.Private[cacheIndex]) then
				comparisonCache.Private[cacheIndex] = newCacheString
				return true
			end
		elseif (not comparisonCache.Public[Category]) or (newCacheString ~= comparisonCache.Public[Category]) then
			comparisonCache.Public[Category] = newCacheString
			return true
		end
		return false
	end

	-- Send Data to the specified client
	local replicateBlacklist = {"Tags"}
	function Module:SendData(Category, Data, LocalPlayer)
		if LocalPlayer then
			DataRemote:FireClient(LocalPlayer, Category, Data)
		else
			DataRemote:FireAllClients(Category, Data)
		end
	end

	-- Get the data out of the replications table
	function Module:GetData(Category, LocalPlayer)
		-- print(string.format("Get %s Data: %s", LocalPlayer and "Private" or "Public", Category))
		if LocalPlayer then
			-- private data
			for i, DataTable in ipairs(activeReplications.Private) do
				local Cat, Dat, Players = unpack(DataTable)
				if Cat == Category and table.find(Players, LocalPlayer) then
					return Dat, i
				end
			end
		else
			-- public data
			return activeReplications.Public[ Category ]
		end
	end

	-- Set the data into the replications table
	function Module:SetData( Category, Data, PlayerTable )
		if PlayerTable then
			if typeof(PlayerTable) == "Instance" then
				PlayerTable = { PlayerTable }
			end
			-- private data for a select group of players
			table.insert(activeReplications.Private, { Category, Data, PlayerTable })
		else
			-- public data
			activeReplications.Public[ Category ] = Data
		end
	end

	--[[
		remove first instance of this category data
		acts like a "stack" in case of the categories stacking ontop of each other
		with the oldest being at the bottom
	]]
	function Module:RemoveFirst( Category )
		if activeReplications.Public[ Category ] then
			activeReplications.Public[ Category ] = nil
		end
		for index, replicationInfo in ipairs( activeReplications.Private ) do
			if replicationInfo[1] == Category then
				table.remove(activeReplications.Private, index)
				break
			end
		end
	end

	-- remove all instances of this category data
	function Module:RemoveAll( Category )
		if activeReplications.Public[ Category ] then
			activeReplications.Public[ Category ] = nil
		end
		-- properly deletes everything
		local index = 1
		while index <= #activeReplications.Private do
			local replicationInfo = activeReplications.Private[index]
			if replicationInfo[1] == Category then
				table.remove(activeReplications.Private, index)
			else
				index += 1
			end
		end
	end

	-- update the specified player or update all players if not specified for
	-- every data in the replications data (public & private)
	function Module:Update( LocalPlayer )
		for publicCategory, publicData in pairs( activeReplications.Public ) do
			if not Module:CheckDataUpdated( publicCategory, publicData, false ) then
				continue
			end
			Module:SendData(publicCategory, publicData, LocalPlayer)
		end
		for _, replicationInfo in ipairs( activeReplications.Private ) do
			local Category, Data, PlayerTable = unpack( replicationInfo )
			if not Module:CheckDataUpdated( Category, Data, PlayerTable ) then
				continue
			end
			if LocalPlayer then
				if table.find( PlayerTable, LocalPlayer ) then
					Module:SendData(Category, Data, LocalPlayer)
				end
			else
				for _, LocalPlayer in ipairs(PlayerTable) do
					Module:SendData(Category, Data, LocalPlayer)
				end
			end
		end
	end

	-- when the player asks to forcively update their data
	-- if they haven't asked in the last 2 seconds then
	-- update their data
	DataRemote.OnServerEvent:Connect(function(LocalPlayer)
		if not Debounce(LocalPlayer.Name.."_FORCE_UPDATE", 2) then
			return
		end
		Module:Update( LocalPlayer )
	end)

	-- when a player is added, update immedietely
	-- and when their character resets
	function Module:PlayerAdded(LocalPlayer)
		task.defer(function()
			Module:Update(LocalPlayer)
		end)
		LocalPlayer.CharacterAdded:Connect(function()
			Module:Update(LocalPlayer)
		end)
	end

	function Module:Init( _ )
		-- update all players
		for _ , LocalPlayer in ipairs(Players:GetPlayers()) do
			Module:PlayerAdded(LocalPlayer)
		end
		-- update joining players
		Players.PlayerAdded:Connect(function(LocalPlayer)
			Module:PlayerAdded(LocalPlayer)
		end)
		-- auto update players
		task.defer(function()
			while true do
				Module:Update()
				task.wait(0.25)
			end
		end)
	end
else
	local LocalPlayer = Players.LocalPlayer

	local activeCache = { }
	Module.Cache = activeCache

	local OnDataUpdate = ReplicatedModules.Classes.Event.New('DataUpdate')
	Module.OnUpdate = OnDataUpdate

	-- get the data from the category
	-- yield until data is available if the argument passed as true
	function Module:GetData(Category, Yield)
		if Yield then
			repeat task.wait(0.1) until activeCache[Category]
		end
		return activeCache[Category]
	end

	function Module:Init( _ )
		-- when this client receives data
		DataRemote.OnClientEvent:Connect(function(Category, Data)
			print(Category)
			if activeCache[Category] then
				for k,v in pairs(Data) do
					activeCache[Category][k] = v
				end
			else
				activeCache[Category] = Data
			end
			Module.OnUpdate:Fire(Category, Data)
		end)
		-- force update till player data is given
		task.defer(function()
			repeat task.wait(0.5)
				print("Requesting Player Data")
				DataRemote:FireServer()
			until Module:GetData('PlayerData')
			print("Got Player Data")
			Module.OnUpdate:Fire('PlayerData', Module:GetData('PlayerData'))
		end)
	end
end

return Module