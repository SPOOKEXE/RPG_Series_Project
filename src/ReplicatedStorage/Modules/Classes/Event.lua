--[[
	Example Code : Alternatives To BindableEvents
	(allows Instance passing)

	local newSignal = Signal.New('Signal1')
	print(newSignal, getmetatable(newSignal))

	print(Signal:GetSignal('Signal1'))
	newSignal:HideSignal('Signal1') -- Prevents GetSignal

	newSignal:Connect(function(connection, ...)
		print("Got Callback: ", ...)
	end)

	newSignal:Fire()
	task.spawn(function()
		local t = tick()
		newSignal:Wait(1)
		print( string.format("defered %s/1 second", tick()-t) )
	end)

	newSignal:Fire("e")
	newSignal:Disconnect()
	newSignal:Fire()
]]

-- SPOOK_EXE

local HttpService = game:GetService('HttpService')

local activeSignals = {}

-- // Classes // --
local Callback = {}
Callback.__index = Callback

function Callback.New(SuperSignal, callbackFunction : (any) -> (any))

	return setmetatable({
		ClassName = "BaseSignalCallback",
		Super = setmetatable({}, SuperSignal),
		Active = true,
		ID = HttpService:GenerateGUID(false),
		_function = callbackFunction,
	}, Callback)

end

function Callback:Trigger(...)
	if not self.Active then
		error("Trying to trigger a disconnected callback.")
	end
	self._function(...)
end

function Callback:Disconnect()
	if not self.Active then
		error("Trying to disconnect a disconnected callback.")
	end
	self.Active = false
	if self.Super then
		getmetatable(self.Super):RemoveCallback(Callback)
	end
end

local Signal = {}
Signal.__index = Signal

function Signal.New(customID)
	return setmetatable({
		ClassName = "BaseSignal",
		Active = true,
		ID = customID or HttpService:GenerateGUID(false),
		_callbacks = {},
	}, Signal)
end

function Signal:GetSignal(signalID)
	assert(typeof(signalID) == "string", "Passed signalID is not a string.")
	for _, signal in ipairs(activeSignals) do
		if signal.ID == signalID then
			return signal
		end
	end
	return Signal.New(signalID)
end

function Signal:HideSignal(signalID)
	assert(typeof(signalID) == "string", "Passed signalID is not a string.")
	for i, signal in ipairs(activeSignals) do
		if signal.ID == signalID then
			table.remove(activeSignals, i)
			break
		end
	end
end

function Signal:RemoveCallback(callback)
	for i, callbackClass in ipairs(self._callbacks) do
		if callback.ID == callbackClass.ID then
			table.remove(self._callbacks, i)
			break
		end
	end
end

function Signal:Fire(...)
	if not self.Active then
		error("Trying to fire a disconnected Signal.")
	end
	for _, callbackClass in ipairs(self._callbacks) do
		callbackClass:Trigger(...)
	end
end

function Signal:Wait(timePeriod)
	if not self.Active then
		error("Trying to Wait on a disconnected Signal.")
	end
	timePeriod = typeof(timePeriod) == "number" and timePeriod or nil
	local bindableWait = Instance.new('BindableEvent')
	local callback; callback = self:Connect(function()
		callback:Disconnect()
		bindableWait:Fire()
	end)
	bindableWait.Event:Wait()
	bindableWait:Destroy()
	if timePeriod then
		task.wait(timePeriod)
	end
end

function Signal:Connect(...)
	if not self.Active then
		error("Trying to connect a disconnected Signal.")
	end
	local callbacks = {}
	local passed_arguments = {...}
	for _, passed_arg in ipairs(passed_arguments) do
		if typeof(passed_arg) == "function" then
			local new_callback = Callback.New(self, passed_arg)
			table.insert(self._callbacks, new_callback)
			table.insert(callbacks, new_callback)
		end
	end
	return unpack(callbacks)
end

function Signal:Disconnect()
	if not self.Active then
		error("Trying to disconnect a disconnected Signal.")
	end
	self.Active = false
	self:HideSignal(self.ID)
	self.Callbacks = nil
	setmetatable(self, {
		__index = function(_, _)
			return nil
		end,
		__newindex = function(_, _, _)
			error("Cannot edit locked metatable.")
		end,
	})
end

return Signal

-- SPOOK_EXE