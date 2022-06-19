-- // Module // --
local Module = {}

function Module:GetUserDataBezier( arrayTable, alpha )
	local pointsTable = arrayTable
	repeat task.wait()
		local ntb = {}
		for k, v in ipairs(pointsTable) do
			if k ~= 1 then
				ntb[k-1] = pointsTable[k-1]:Lerp(v, alpha)
			end
		end
		pointsTable = ntb
	until #pointsTable == 1
	return pointsTable[1]
end

return Module
