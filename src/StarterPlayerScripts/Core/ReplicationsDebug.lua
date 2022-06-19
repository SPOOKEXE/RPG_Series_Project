
--local containerFolder = Instance.new('Folder', workspace)
--containerFolder.Name = LocalPlayer.Name
--ReplicatedModules.Utility.Table:TableToObject(baseData, containerFolder)

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local ReplicatedSystems = require(ReplicatedStorage:WaitForChild('Core'))
local ReplicatedData = ReplicatedSystems.ReplicatedData

-- // Module // --
local Module = {}

function Module:OnNewData(category)
	local Data = ReplicatedData:GetData(category)
	if not Data then
		return
	end

	--print(Data)
	local Folder = workspace:FindFirstChild(category..'_')
	if not Folder then
		Folder = Instance.new('Folder')
		Folder.Name = category..'_'
		Folder.Parent = workspace
	end
	Folder:ClearAllChildren()
	ReplicatedModules.Utility.Table:TableToObject(Data, Folder)
end

function Module:Init(_)
	-- Data Updated
	ReplicatedData.OnUpdate:Connect(function(Category, _)
		--print(Category)
		Module:OnNewData(Category)
	end)
end

return Module
