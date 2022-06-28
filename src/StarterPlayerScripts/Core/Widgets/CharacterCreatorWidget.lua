
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')
local LocalModules = require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local CharacterCreatorConfig = ReplicatedModules.Data.CharacterCreatorConfig
local UserInterfaceUtil = LocalModules.Utility.UserInterfaceUtil

local RemoteService = ReplicatedModules.Services.RemoteService
local CharacterCreationFunction = RemoteService:GetRemote('CharacterCreationFunction', 'RemoteFunction', false)

local MovementControllerService = LocalModules.Services.MovementController
local CameraControllerService = LocalModules.Services.CameraController

local OutfitApplierService = ReplicatedModules.Services.OutfitApplierService

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')
local CharacterCreatorFrame = Interface:WaitForChild('CharacterCreatorFrame')
local CreateSaveFrame = CharacterCreatorFrame:WaitForChild('List'):WaitForChild('CreateSaveFrame')

local SystemsContainer = {}

-- // Module // --
local Module = { Open = false }
Module.WidgetMaid = ReplicatedModules.Classes.Maid.New()
Module.Callback = Instance.new('BindableEvent')

Module.ActiveIndexesTable = false
Module.DummyAvatar = false

function Module:UpdateWidget()
	if not Module.Open then
		return
	end
	-- update dummy character
	if Module.ActiveIndexesTable and Module.DummyAvatar then
		OutfitApplierService:ApplyCharacterCreatorOutfitData( Module.DummyAvatar, Module.ActiveIndexesTable, true )
	end
end

function Module:OpenWidget()
	if Module.Open then
		return
	end
	Module.Open = true

	Module.WidgetMaid:Give(function()
		Module.Callback:Fire(false)
	end)

	local CharacterCreatorModel = ReplicatedAssets.CharacterCreator.CharacterCreatorModel:Clone()
	Module.DummyAvatar = CharacterCreatorModel.Dummy
	MovementControllerService:SetMovementEnabledWithPriority( 99, 'CharacterCreator', false )
	CameraControllerService:SetStateWithPriority( 100, 'CharacterCreator', Enum.CameraType.Scriptable, false, false, false, CharacterCreatorModel.CameraCFrame.CFrame )
	CharacterCreatorModel.Parent = workspace

	Module.WidgetMaid:Give(function()
		MovementControllerService:PopByID('CharacterCreator')
		CameraControllerService:PopByID('CharacterCreator')
	end)

	-- generate all frames and events needed
	Module.ActiveIndexesTable = table.create(#CharacterCreatorConfig.Options, 1)
	-- print(Module.ActiveIndexesTable)
	for layoutIndex, optionData in ipairs( CharacterCreatorConfig.Options ) do
		local DirectoryItems = optionData.Directory and optionData.Directory:GetChildren()
		if not DirectoryItems then
			warn('Could not find character creator asset directory ; ', optionData.Directory)
			continue
		end

		local NewOptionFrame = LocalAssets.UI.CharCreatorOptionTemplate:Clone()
		NewOptionFrame.Name = 'Option'..layoutIndex
		NewOptionFrame.LayoutOrder = layoutIndex
		UserInterfaceUtil:SetLabelDisplayProperties( NewOptionFrame, optionData )
		NewOptionFrame.Parent = CharacterCreatorFrame.List

		UserInterfaceUtil:CreateActionButton({Parent = NewOptionFrame.Left}).Activated:Connect(function()
			Module.ActiveIndexesTable[layoutIndex] -= 1
			if Module.ActiveIndexesTable[layoutIndex] < 1 then
				Module.ActiveIndexesTable[layoutIndex] = #DirectoryItems
			end
			NewOptionFrame.Number.Text = '#'..Module.ActiveIndexesTable[layoutIndex]
			Module:UpdateWidget()
		end)

		UserInterfaceUtil:CreateActionButton({Parent = NewOptionFrame.Right}).Activated:Connect(function()
			Module.ActiveIndexesTable[layoutIndex] += 1
			if Module.ActiveIndexesTable[layoutIndex] > #DirectoryItems then
				Module.ActiveIndexesTable[layoutIndex] = 1
			end
			NewOptionFrame.Number.Text = '#'..Module.ActiveIndexesTable[layoutIndex]
			Module:UpdateWidget()
		end)

		Module.WidgetMaid:Give(NewOptionFrame)
	end

	-- Change canvas size
	local offsetNumber = (#CharacterCreatorConfig.Options - 2) * 225
	CharacterCreatorFrame.List.CanvasSize = UDim2.fromOffset(0, CharacterCreatorFrame.List.AbsoluteSize.Y + offsetNumber)

	Module.WidgetMaid:Give(CreateSaveFrame.Complete.Activated:Connect(function()
		Module.Callback:Fire(Module.ActiveIndexesTable)
	end))

	Module:UpdateWidget()
	CharacterCreatorFrame.Visible = true
end

function Module:CloseWidget()
	if not Module.Open then
		return
	end
	Module.Open = false
	CharacterCreatorFrame.Visible = false
	Module.WidgetMaid:Cleanup()
	Module.ActiveIndexesTable = false
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	CharacterCreatorFrame.Visible = false

	-- when asked by the server,
	-- open the frames and such and get a new character loadout
	CharacterCreationFunction.OnClientInvoke = function()
		print('client invoked ; ', debug.traceback())
		Module:OpenWidget()
		local Data = Module.Callback.Event:Wait()
		Module:CloseWidget()
		return Data
	end

	LocalPlayer.AncestryChanged:Connect(function()
		Module:CloseWidget() -- cleanup
	end)
end

return Module
