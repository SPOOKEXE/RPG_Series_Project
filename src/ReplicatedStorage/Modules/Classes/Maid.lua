
local Maid = {}
Maid.__index = Maid

function Maid.New()
	return setmetatable({_tasks = {}}, Maid)
end

function Maid:Cleanup()
	for _, _task in ipairs( self._tasks ) do
		if typeof(_task) == 'RBXScriptConnection' then
			_task:Disconnect()
		elseif typeof(_task) == 'function' then
			task.defer(_task)
		elseif typeof(_task) == 'Instance' then
			task.defer(function()
				_task:Destroy()
			end)
		elseif typeof(_task) == 'table' and _task.Destroy then
			task.defer(_task.Destroy)
		else
			warn('Invalid task type; ', typeof(_task), _task)
		end
	end
	self._tasks = {}
end

function Maid:Give( ... )
	local tasks = {...}
	for _, _task in ipairs( tasks ) do
		if table.find(self._tasks, _task) then
			warn('Task already exists in the Maid : '..tostring(_task))
		else
			table.insert(self._tasks, _task)
		end
	end
end

return Maid
