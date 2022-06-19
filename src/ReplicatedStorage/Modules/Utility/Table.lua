
-- // Module // --
local Module = {}

function Module:DeepCopy(passed_table)
	local clonedTable = {}
	if typeof(passed_table) == "table" then
		for k,v in pairs(passed_table) do
			clonedTable[Module:DeepCopy(k)] = Module:DeepCopy(v)
		end
	else
		clonedTable = passed_table
	end
	return clonedTable
end

-- DICTIONARY
function Module:CountDictionary( Dict )
	local count = 0
	for _, _ in pairs(Dict) do
		count += 1
	end
	return count
end

function Module:GetDictionaryIndexes( Dict )
	local indexes = {}
	for i, _ in pairs(Dict) do
		table.insert(indexes, i)
	end
	return indexes
end

function Module:GetRandomDictionaryIndex(Dict)
	local indexes = Module:GetDictionaryIndexes( Dict )
	return indexes[Random.new():NextInteger(1, #indexes)]
end

function Module:GetRandDictionaryValue(Dict)
	return Dict[ Module:GetRandDictionaryIndex(Dict) ]
end

function Module:RandomizeArray( arrayTable )
	local item = nil
	local rng = Random.new(os.time())
	for i = #arrayTable, 1, -1 do
		item = table.remove(arrayTable, rng:NextInteger(1, i))
		table.insert(arrayTable, item)
	end
end

-- Combine all arrays passed into this function into one singular table.
function Module:CombineArrays(...)
	local combined = {}
	local arrays = {...}
	for index = 1, #arrays do
		if typeof(arrays[index]) == 'table' and #arrays[index] > 0 then
			table.move(arrays[index], 1, #arrays[index], #combined + 1, combined)
		end
	end
	return combined
end

-- Combine all dictionaries passed into this function into one singular dictionary
-- Overlapping indexes outputs warnings
function Module:CombineDictionaries(...)
	local combined = {}
	for _, dictTbl in ipairs( {...} ) do
		for index, val in pairs(dictTbl) do
			if combined[index] then
				warn('Overlapping Index Found ; ', index)
				continue
			end
			combined[index] = val
		end
	end
	return combined
end

-- Returns integer/string, boolean
-- boolean determines if its an array (false) or dictionary (true)
function Module:FindValueInTable(SearchTable, Value)
	if #SearchTable > 0 then
		-- array
		return table.find(SearchTable, Value), false
	else
		-- dictionary
		for index, Val in pairs( SearchTable ) do
			if Val == Value then
				return index, true
			end
		end
	end
	return nil
end

-- OBJECTS -> TABLE // TABLE -> OBJECTS
local OT_Types = {
	['boolean'] = 'BoolValue',
	['string'] = 'StringValue',
	['number'] = 'NumberValue',
}

function Module:TableToObject(Tbl, Prnt, Ignores, Nst)
	Nst = Nst or 0
	if Nst > 30 then
		return
	end
	for k, v in pairs(Tbl) do
		if Ignores and table.find(Ignores, tostring(k)) then
			continue
		end
		local valType = typeof(v)
		if valType == 'table' then
			local Fold = Instance.new('Folder')
			Fold.Name = tostring(k)
			Module:TableToObject(v, Fold, Ignores, Nst + 1)
			Fold.Parent = Prnt
		elseif typeof(k) == 'number' and valType == 'string' then
			local Fold = Instance.new('Folder')
			Fold.Name = v
			Fold.Parent = Prnt
		else
			local c = OT_Types[valType] or OT_Types['string']
			local val = Instance.new(c)
			val.Name = tostring(k)

			local success, _ = pcall(function()
				val.Value = v
			end)

			if not success then
				val.Value = tostring(v)
			end

			val.Parent = Prnt
		end
	end
	return Prnt
end

function Module:ObjectToTable(Prnt, Tbl)
	Tbl = Tbl or {}
	for _, child in ipairs(Prnt:GetChildren()) do
		if child:IsA('Folder') then
			Tbl[child.Name] = Module:ObjectToTable({}, child)
		else
			Tbl[child.Name] = child.Value
		end
	end
	return Tbl
end

return Module
