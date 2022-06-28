
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')

local DataDefinitionModules = require(ReplicatedStorage.Modules.Data)
local UtilityModules = require(ReplicatedStorage.Modules.Utility)

local CharacterCreatorConfig = DataDefinitionModules.CharacterCreatorConfig

local function WeldAccessoryToHead( AccessoryInstance, HeadInstance, IsDummyModel )
	if AccessoryInstance:IsA('Model') then
		if AccessoryInstance.PrimaryPart then
			AccessoryInstance:SetPrimaryPartCFrame( HeadInstance.CFrame )
			UtilityModules.Models:WeldConstraint(AccessoryInstance.PrimaryPart, HeadInstance)
		else
			warn('No PrimaryPart set for accessory ', AccessoryInstance:GetFullName())
		end
	elseif AccessoryInstance:IsA('Accessory') then
		if IsDummyModel then -- due to problems
			AccessoryInstance.Handle.CFrame = HeadInstance.CFrame
			UtilityModules.Models:WeldConstraint(AccessoryInstance.Handle, HeadInstance)
		end
	end
end

-- // Module // --
local Module = {}

Module.BaseOutfitApplier = {
	-- hair style folder
	{
		RemoveAll = function(Character)
			for _, item in ipairs(Character:GetChildren()) do
				if item:GetAttribute('BaseOutfitAccessory') then
					item:Destroy()
				end
			end
		end,
		Add = function(Character, HairStyleFolderInstance, IsDummyCharacter)
			local HeadInstance = Character:FindFirstChild('Head')
			for _, HairStyleInstance in ipairs( HairStyleFolderInstance:GetChildren() ) do
				HairStyleInstance = HairStyleInstance:Clone()
				HairStyleInstance:SetAttribute('BaseOutfitAccessory', true)
				WeldAccessoryToHead( HairStyleInstance, HeadInstance, IsDummyCharacter )
				HairStyleInstance.Parent = Character
			end
		end,
	},
	-- faces folder
	{
		RemoveAll = function(Character)
			local Head = Character:FindFirstChild('Head')
			if not Head then
				return
			end
			for _, item in ipairs( Head:GetChildren() ) do
				if item:IsA('Decal') and item:GetAttribute('BaseOutfitFace') then
					item:Destroy()
				end
			end
		end,
		Add = function(Character, FaceDecalFolderInstance, _)
			local Head = Character:FindFirstChild('Head')
			if not Head then
				return
			end
			for _, FaceDecalInstance in ipairs( FaceDecalFolderInstance:GetChildren() ) do
				FaceDecalInstance = FaceDecalInstance:Clone()
				FaceDecalInstance:SetAttribute('BaseOutfitFace', true)
				FaceDecalInstance.Parent = Head
			end
		end,
	},
	-- shirt folder
	{
		RemoveAll = function(Character)
			for _, item in ipairs( Character:GetChildren() ) do
				if item:IsA('Shirt') and item:GetAttribute('BaseOutfitShirt') then
					item:Destroy()
				end
			end
		end,
		Add = function(Character, ShirtsFolderInstance, _)
			for _, ShirtInstance in ipairs( ShirtsFolderInstance:GetChildren() ) do
				ShirtInstance = ShirtInstance:Clone()
				ShirtInstance:SetAttribute('BaseOutfitShirt', true)
				ShirtInstance.Parent = Character
			end
		end,
	},
	-- pants folder
	{
		RemoveAll = function(Character)
			for _, item in ipairs( Character:GetChildren() ) do
				if item:IsA('Pants') and item:GetAttribute('BaseOutfitPants') then
					item:Destroy()
				end
			end
		end,
		Add = function(Character, PantsFolderInstance, _)
			for _, PantsInstance in ipairs( PantsFolderInstance:GetChildren() ) do
				PantsInstance = PantsInstance:Clone()
				PantsInstance:SetAttribute('BaseOutfitPants', true)
				PantsInstance.Parent = Character
			end
		end,
	},
	-- body color folder
	{
		RemoveAll = function(Character)
			for _, item in ipairs( Character:GetChildren() ) do
				if item:IsA('BodyColor') and item:GetAttribute('BaseOutfitBodyColor') then
					item:Destroy()
				end
			end
		end,
		Add = function(Character, BodyColorFolderInstance, _)
			for _, BodyColorInstance in ipairs( BodyColorFolderInstance:GetChildren() ) do
				BodyColorInstance = BodyColorInstance:Clone()
				BodyColorInstance:SetAttribute('BaseOutfitBodyColor', true)
				BodyColorInstance.Parent = Character
			end
		end,
	},
}

function Module:ApplyCharacterCreatorOutfitData( characterModel, characterDataArray, isDummyCharacter )
	for dataIndex, accessoryNumber in ipairs( characterDataArray ) do
		local optionData = CharacterCreatorConfig.Options[dataIndex]
		if not optionData then
			warn('Invalid option passed ; ', dataIndex, accessoryNumber, ' max option count is ', #CharacterCreatorConfig.Options)
			continue
		end

		local assetFolder = optionData.Directory and optionData.Directory:FindFirstChild(accessoryNumber)
		if not assetFolder then
			warn('Could not find asset folder ', accessoryNumber, ' under directory ', assetFolder and assetFolder:GetFullName() or 'No Folder was found')
			continue
		end

		local applyFunctionTable = Module.BaseOutfitApplier[dataIndex]
		if not applyFunctionTable then
			warn('No model apply function for outfit ', dataIndex,  optionData.Directory:GetFullName())
			continue
		end

		local success, err = pcall(applyFunctionTable.RemoveAll, characterModel)
		if not success then
			warn('RemoveAll Failed ; ', dataIndex, err)
			continue
		end

		success, err = pcall(applyFunctionTable.Add, characterModel, assetFolder, isDummyCharacter)
		if not success then
			warn('Add Instances Failed ; ', dataIndex, err)
			continue
		end
		-- print('Success ', dataIndex, accessoryNumber)
	end
end

return Module

