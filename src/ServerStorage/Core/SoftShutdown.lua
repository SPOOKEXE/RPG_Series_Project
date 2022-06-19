
local Players = game:GetService('Players')
local TeleportService = game:GetService('TeleportService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService

local ShutdownRemote = RemoteService:GetRemote('SoftShutdown', 'RemoteEvent', false)
local ShutdownInfoFunc = RemoteService:GetRemote('ShutdownInfo', 'RemoteFunction', false)
local ServerShutdownBindable = RemoteService:GetRemote('ActivateSoftShutdown', 'BindableEvent', true)

local IsRedirectServer = (game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0)
local HasShutdown = false
local TeleportsStarted = false
local Reserved = nil

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:IsShutdownServer()
	return IsRedirectServer
end

function Module:Teleport(PlayerTable)
	task.wait(2)
	if Reserved then
		TeleportService:TeleportToPrivateServer(game.PlaceId, Reserved, PlayerTable)
	else
		TeleportService:TeleportPartyAsync(game.PlaceId, PlayerTable)
	end
end

function Module:StartTeleports()
	if TeleportsStarted then
		return
	end
	TeleportsStarted = true
	if #Players:GetPlayers() > 0 then
		task.defer(function()
			Module:Teleport(Players:GetPlayers())
		end)
	end
	Players.PlayerAdded:Connect(function(LocalPlayer)
		Module:Teleport({LocalPlayer})
	end)
end

function Module:OnSoftShutdown()
	if HasShutdown then
		return
	end
	HasShutdown = true

	ShutdownRemote:FireAllClients()

	local s, e = pcall(function()
		Reserved = TeleportService:ReserveServer(game.PlaceId)
	end)

	if not s then
		warn('SoftShutdown Error; ', e)
	end

	Module:StartTeleports()

	while #Players:GetPlayers() > 0 do
		task.wait(1)
	end
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	warn(IsRedirectServer and 'Shutdown Server' or 'Live/Studio Server')

	ShutdownInfoFunc.OnServerInvoke = function()
		return IsRedirectServer
	end

	if game:GetService('RunService'):IsStudio() then
		return
	end

	if IsRedirectServer  then
		Module:StartTeleports()
		ShutdownRemote:FireAllClients()
		return
	end

	game:BindToClose(function()
		Module:OnSoftShutdown()
	end)

	ServerShutdownBindable.Event:Connect(function()
		Module:OnSoftShutdown()
	end)
end

return Module
