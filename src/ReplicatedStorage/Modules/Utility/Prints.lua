
local Module = { }

function Module:PrintSpecial( passed )
	if not passed then
		return
	end
	if type(passed) == 'userdata' then
		if passed.ClassName == 'InputObject' then
			print(passed.KeyCode, passed.UserInputType, passed.UserInputState, passed.Position, passed.Delta)
		end
	end
end

local cache = { }
function Module:WarnOnce( ... )
	local msg = table.concat({ ... }, '')
	if cache[msg] then
		return
	end
	cache[msg] = true
	warn(msg)
end

return Module

