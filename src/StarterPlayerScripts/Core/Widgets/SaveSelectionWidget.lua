local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')
local LocalModules = require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local GetSaveDataFunction = RemoteService:GetRemote('GetSaveData', 'RemoteFunction', false)
local SaveDataHandlerFunction = RemoteService:GetRemote('SaveDataFunction', 'RemoteFunction', false)

local MovementControllerService = LocalModules.Services.MovementController
local CameraControllerService = LocalModules.Services.CameraController
local ViewportUtilModule = LocalModules.Utility.ViewportUtil

local SaveSlotsConfig = ReplicatedModules.Data.SaveSlotsConfig
local OutfitApplierService = ReplicatedModules.Services.OutfitApplierService

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')
local SaveSelectionFrame = Interface:WaitForChild('SaveSelectionFrame')
local SaveSelectionScroll = SaveSelectionFrame.Scroll
local CreateSaveButton = SaveSelectionFrame.Scroll.CreateSaveFrame.CreateSave

local SystemsContainer = {}

local BASE_CURRENCY_LABEL_STRING = '<font color="rgb(255,165,0)">C%s</font> <font color="rgb(100,100,100)">S%s</font> <font color="rgb(239,184,56)">G%s</font> <font color="rgb(200,200,200)">P%s</font>'
local SaveSelectionCameraCFrame = CFrame.new(Vector3.new(5, 0, 0), Vector3.new())

-- // Module // --
local Module = { Open = false, }
Module.WidgetMaid = ReplicatedModules.Classes.Maid.New()

function Module:GetSaveFrame( saveData )
	-- create a new save slot frame if the target one does not exist
	local SearchName = 'SaveSlot'..saveData.SlotIndex
	local Frame = SaveSelectionScroll:FindFirstChild(SearchName)
	if not Frame then
		Frame = LocalAssets.UI.SaveSlotTemplate:Clone()
		Frame.Name = SearchName
		Frame.LayoutOrder = saveData.SlotIndex
		Frame.Level.Text = 'Level '..(saveData.Level or '#')
		Frame.Currency.Text = string.format(BASE_CURRENCY_LABEL_STRING, unpack(saveData.Currency))

		Frame.Buttons.LoadSave.Activated:Connect(function()
			if SaveDataHandlerFunction:InvokeServer('SelectSave', saveData.SlotIndex) then
				Module:CloseWidget()
			end
		end)

		Frame.Buttons.DeleteSave.Activated:Connect(function()
			warn('Prompt for Delete Save confirmation')
			if SaveDataHandlerFunction:InvokeServer('DeleteSave', saveData.SlotIndex) then
				Module:UpdateWidget()
			end
		end)

		local BlankDummyInstance, _ = ViewportUtilModule:SetupModelViewport(Frame.Viewport, ReplicatedAssets.Models.BlankDummy, SaveSlotsConfig.DummyCameraCFrame, SaveSlotsConfig.DummyModelCFrame)
		OutfitApplierService:ApplyCharacterCreatorOutfitData( BlankDummyInstance, saveData.CustomCharacter, true )
		Frame.Parent = SaveSelectionScroll
		Module.WidgetMaid:Give(Frame)
	end
	return Frame
end

function Module:UpdateWidget()
	-- Get data
	local Data = false
	while (not Data) and Module.Open do
		Data = GetSaveDataFunction:InvokeServer()
		task.wait(0.1)
	end
	-- if no longer opened, return
	if not Module.Open then
		return
	end
	-- Load save choices
	print(Data)
	local frameCache = {}
	for _, saveData in ipairs( Data ) do
		local Frame = Module:GetSaveFrame( saveData )
		table.insert(frameCache, Frame)
	end
	-- Change canvas size
	local offsetNumber = (#frameCache - 2) * 225
	SaveSelectionScroll.CanvasSize = UDim2.fromOffset(0, SaveSelectionScroll.AbsoluteSize.Y + offsetNumber)
	CreateSaveButton.Parent.Visible = #Data < SaveSlotsConfig.MAX_SAVES
	-- Remove any unneeded frames (using frameCache)
	for _, GuiObject in ipairs( SaveSelectionScroll:GetChildren() ) do
		if GuiObject:IsA('Frame') and GuiObject.Name ~= 'CreateSaveFrame' and not table.find(frameCache, GuiObject) then
			GuiObject:Destroy()
		end
	end
end

function Module:OpenWidget()
	if Module.Open then
		return
	end
	print(script.Name, 'Open Widget')
	Module.Open = true
	Module:UpdateWidget()
	MovementControllerService:SetMovementEnabledWithPriority( 99, 'SaveSelection', false )
	CameraControllerService:SetStateWithPriority( 99, 'SaveSelection', Enum.CameraType.Scriptable, false, false, false, SaveSelectionCameraCFrame )
	Module.WidgetMaid:Give(CreateSaveButton.Activated:Connect(function()
		SaveDataHandlerFunction:InvokeServer('CreateSave')
		Module:UpdateWidget()
	end))
	SaveSelectionFrame.Visible = true -- do this unless handled elsewhere
end

function Module:CloseWidget()
	if not Module.Open then
		return
	end
	Module.Open = false
	Module.WidgetMaid:Cleanup()
	SaveSelectionFrame.Visible = false -- do this unless handled elsewhere
	MovementControllerService:PopByID('SaveSelection')
	CameraControllerService:PopByID('SaveSelection')
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems
	-- first widget to open
	Module:OpenWidget()
end

return Module
