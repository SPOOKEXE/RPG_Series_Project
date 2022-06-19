
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local remoteContainerName = '_remotes'

local function GetOrCreateFolder(Parent)
	local Folder = Parent and Parent:FindFirstChild(remoteContainerName)
	if not Folder then
		Folder = Instance.new('Folder')
		Folder.Name = remoteContainerName
		Folder.Parent = Parent
	end
	return Folder
end

local function SearchForNameAndClass(Name, Class, Parent)
	for _, item in pairs(Parent:GetChildren()) do
		if (item.Name == Name) and (item.ClassName == Class) then
			return item
		end
	end
	return nil
end

-- // Module // --
local Module = {}

if RunService:IsServer() then
	local clientRemoteFolder = GetOrCreateFolder(ReplicatedStorage)
	local serverRemoteFolder = GetOrCreateFolder(game:GetService('ServerStorage'))

	function Module:GetRemote(remoteName : string, remoteType : string, isClientBased : boolean?)
		local targetParent = (isClientBased and serverRemoteFolder or clientRemoteFolder)
		local remoteObject = SearchForNameAndClass(remoteName, remoteType, targetParent)
		if not remoteObject then
			remoteObject = Instance.new(remoteType)
			remoteObject.Name = remoteName
			remoteObject.Parent = targetParent
		end
		return remoteObject
	end
else
	local ClientRemotes = ReplicatedStorage:WaitForChild(remoteContainerName)

	function Module:GetRemote(remoteName : string, remoteType : string, isClientBased : boolean?)
		if isClientBased then
			local Remote = SearchForNameAndClass(remoteName, remoteType, ReplicatedStorage)
			if not Remote then
				Remote = Instance.new(remoteType)
				Remote.Name = remoteName
				Remote.Parent = ClientRemotes
			end
			return Remote
		else
			local Remote = nil
			local startTick = tick()
			while not Remote do
				if (tick() - startTick) > 6 then
					warn("Infinite Yield Waiting for Remote: ", remoteName, remoteType, RunService:IsClient() and "Client" or "Server")
				end
				Remote = SearchForNameAndClass(remoteName, remoteType, ClientRemotes)
			end
			return Remote
		end
	end
end

return Module
