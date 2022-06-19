
local Module = {}

function Module:GetUTC()
	return os.time(os.date('!*t'))
end

return Module