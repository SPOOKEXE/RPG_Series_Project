local ContextActionService = game:GetService('ContextActionService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local ControlsModule = require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild("PlayerModule")):GetControls()

-- local ReplicatedStorage = game:GetService('ReplicatedStorage')
-- local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local PriorityList = {}
local PriorityIndexes = {}

-- // Module // --
local MovementController = {}

function MovementController:GetOverrideData()
	table.sort(PriorityIndexes)
	local Index = PriorityIndexes[#PriorityIndexes]
	return Index and PriorityList[Index][1]
end

function MovementController:OnUpdate()
	local HighestData = MovementController:GetOverrideData()
	if (not HighestData) or HighestData[2] then
		ControlsModule:Enable()
	else
		ControlsModule:Disable()
	end
end

function MovementController:FindByID(ID)
	for priorityNumber, array in pairs(PriorityList) do
		for i, activePriorityData in ipairs( array ) do
			if activePriorityData[1] == ID then
				return i
			end
		end
	end
	return nil
end

function MovementController:PopByID(ID)
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
	MovementController:OnUpdate()
end

function MovementController:SetMovementEnabledWithPriority( priority, ID, IsEnabled )
	if not PriorityList[priority] then
		PriorityList[priority] = {}
		table.insert(PriorityIndexes, priority)
	end
	table.insert(PriorityList[priority], 1, {ID, IsEnabled})
	MovementController:OnUpdate()
end

function MovementController:SetMovementEnabled( ID, IsEnabled )
	return MovementController:SetMovementEnabledWithPriority(1, ID, IsEnabled)
end

return MovementController

