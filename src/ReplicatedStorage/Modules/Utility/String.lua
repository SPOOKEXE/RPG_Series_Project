
local Module = {}

function Module:ConvertToBytesTable(str)
	local bytes = {}
	for strIndex = 1, #str do
		local character = string.sub(str, strIndex, strIndex)
		local byte = string.byte(character)
		table.insert(bytes, byte)
	end
	return bytes
end

function Module:ConvertToTotalBytes(str)
	local total = 0
	for _, n in ipairs(Module:ConvertToBytesTable(str)) do
		total += n
	end
	return total
end

function Module:SpaceStringByPrimary(str) -- splits string at the start of a new capital or at the end of a number sequence
	local regions = {}
	local currentIndex = 1
	local hasNumber = false
	local function Split(Index)
		local leftRegion = string.sub(str, 1, Index - 1)
		local rightRegion = string.sub(str, Index, #str)
		table.insert(regions, leftRegion)
		str = rightRegion
	end
	while true do
		currentIndex += 1
		if currentIndex > #str then
			table.insert(regions, str)
			break
		end
		local char = string.sub(str, currentIndex, currentIndex)
		if string.byte(char) > 64 and string.byte(char) < 91 then -- capital letters
			hasNumber = false
			Split(currentIndex)
			currentIndex = 1
		elseif string.byte(char) > 48 and string.byte(char) < 57 and not hasNumber then -- numbers
			hasNumber = true
			Split(currentIndex)
			currentIndex = 1
		end
	end
	return table.concat(regions, ' ')
end

return Module
