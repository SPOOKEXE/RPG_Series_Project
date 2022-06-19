
local Module = {}

function Module:DoesMatchProperties( InstanceTarget, Properties )
	for propName, propValue in pairs(Properties) do
		local success, _ = pcall(function()
			if InstanceTarget[propName] ~= propValue then
				error("invalid")
			end
		end)
		if not success then
			return false
		end
	end
	return true
end

function Module:SetProperties(object, properties)
	if typeof(properties) == "table" then
		for k, v in pairs(properties) do
			pcall(function()
				object[k] = v
			end)
		end
	end
	return object
end

function Module:CreateClass(ClassName, Properties)
	return Module:SetProperties(Instance.new(ClassName), Properties)
end

function Module:FindNameAndClassOrCreate(InstanceName, InstanceClass, Parent)
	for _, Inst in ipairs( Parent:GetChildren() ) do
		if Inst.Name == InstanceName and Inst.ClassName == InstanceClass then
			return Inst
		end
	end
	local _Obj = Instance.new(InstanceClass)
	_Obj.Name = InstanceName
	_Obj.Parent = Parent
	return _Obj
end

return Module
