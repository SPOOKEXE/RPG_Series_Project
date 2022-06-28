
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

-- local ReplicatedStorage = game:GetService('ReplicatedStorage')
-- local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local CurrentCamera = workspace.CurrentCamera

local PriorityList = {}
local PriorityIndexes = {}

-- // Module // --
local CameraController = {}

function CameraController:GetOverrideData()
	table.sort(PriorityIndexes)
	local Index = PriorityIndexes[#PriorityIndexes]
	return Index and PriorityList[Index][1]
end

-- potential change;
-- have all values be set to whatever is the relative highest value for that property
-- eg; top item does not have MaxZoom value so go down to second highest table and check if that does, otherwise repeat
function CameraController:OnUpdate()
	local Data = CameraController:GetOverrideData() or {}
	local _, CameraType, CameraMode, MaxZoom, MinZoom, CFrameValue = unpack(Data)
	if CameraType then
		CurrentCamera.CameraType = CameraType
	else
		CurrentCamera.CameraType = Enum.CameraType.Custom
	end
	if CameraMode then
		LocalPlayer.CameraMode = CameraMode
	else
		LocalPlayer.CameraMode = Enum.CameraMode.Classic
	end
	if MaxZoom then
		LocalPlayer.CameraMaxZoomDistance = MaxZoom
	else
		LocalPlayer.CameraMaxZoomDistance = 128
	end
	if MinZoom then
		LocalPlayer.CameraMinZoomDistance = MinZoom
	else
		LocalPlayer.CameraMaxZoomDistance = 0.5
	end
	if MaxZoom then
		LocalPlayer.CameraMaxZoomDistance = MaxZoom
	else
		LocalPlayer.CameraMaxZoomDistance = 128
	end
	if CFrameValue then
		CurrentCamera.CFrame = CFrameValue
	end
end

function CameraController:FindByID(ID)
	for _, array in pairs(PriorityList) do
		for i, activePriorityData in ipairs( array ) do
			if activePriorityData[1] == ID then
				return i
			end
		end
	end
	return nil
end

function CameraController:PopByID(ID)
	for priorityNumber, array in pairs(PriorityList) do
		local index = 1
		while index <= #array do
			if array[index][1] == ID then
				table.remove(array, index)
				continue
			end
			index += 1
		end
		if #array == 0 then
			PriorityList[priorityNumber] = nil
			table.remove(PriorityIndexes, table.find(PriorityIndexes, priorityNumber))
		end
	end
	CameraController:OnUpdate()
end

function CameraController:SetStateWithPriority( priority, ID, CameraType, CameraMode, MaxZoom, MinZoom, CFrameValue )
	if not PriorityList[priority] then
		PriorityList[priority] = {}
		table.insert(PriorityIndexes, priority)
	end
	table.insert(PriorityList[priority], {ID, CameraType, CameraMode, MaxZoom, MinZoom, CFrameValue})
	CameraController:OnUpdate()
end

function CameraController:SetState(...)
	CameraController:SetCameraStateWithPriority(1, ...)
end

return CameraController

