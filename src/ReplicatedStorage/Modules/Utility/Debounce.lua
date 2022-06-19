
local debounceCache = {}

-- // Module // --
local Module = {}

function Module:Debounce(debounceName : string, duration : number?)
	duration = typeof(duration) == 'number' and duration or 1
	if typeof(debounceName) == 'string' then
		if debounceCache[debounceName] then
			return false
		end
		debounceCache[debounceName] = true
		task.delay(duration, function()
			debounceCache[debounceName] = nil
		end)
		return true
	end
	return false
end

function Module:__call(_, ...)
	return Module:Debounce(...)
end
setmetatable(Module, Module)

return Module
