
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RemotesFolder = ReplicatedStorage._remotes

local GetSaveDataFunction = RemotesFolder.GetSaveData
local SaveDataRemote = RemotesFolder.SaveDataRemote

local LatestData = GetSaveDataFunction:InvokeServer()
print(LatestData)

-- create save
SaveDataRemote:FireServer('CreateSave')
LatestData = GetSaveDataFunction:InvokeServer()
print(LatestData)

-- remove save
SaveDataRemote:FireServer('DeleteSave', #LatestData)
LatestData = GetSaveDataFunction:InvokeServer()
print(LatestData)

-- create save
SaveDataRemote:FireServer('CreateSave')
LatestData = GetSaveDataFunction:InvokeServer()
print(LatestData)

-- select save
SaveDataRemote:FireServer('SelectSave', 1)
