local TweenService = game:GetService('TweenService')

local baseTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

-- // Module // --
local Module = {}

local baseButton = Instance.new('ImageButton')
baseButton.Name = 'Button'
baseButton.AnchorPoint = Vector2.new(0.5, 0.5)
baseButton.Position = UDim2.fromScale(0.5, 0.5)
baseButton.Size = UDim2.fromScale(1, 1)
baseButton.BackgroundTransparency = 1
baseButton.Selectable = true
baseButton.ImageTransparency = 1
baseButton.ZIndex = 50
function Module:CreateActionButton(properties)
	local button = baseButton:Clone()
	if typeof(properties) == 'table' then
		for k, v in pairs(properties) do
			button[k] = v
		end
	end
	return button
end

function Module:SetLabelDisplayProperties( Parent, propertiesTable )
	for guiObjectName, labelProperties in pairs( propertiesTable ) do
		local targetGuiObject = Parent:FindFirstChild( guiObjectName )
		if targetGuiObject and targetGuiObject:IsA('Frame') then
			targetGuiObject = targetGuiObject:FindFirstChild('Label')
		end
		if not targetGuiObject then
			continue
		end
		for propertyName, propertyValue in pairs(labelProperties) do
			targetGuiObject[propertyName] = propertyValue
		end
	end
end

function Module:FadeGuiObjects( Parent, endTransparency, customTweenInfo )
	local Objs = Parent:GetDescendants()
	if Parent:IsA('GuiObject') then
		table.insert(Objs, Parent)
	end
	local tweenInfo = (customTweenInfo or baseTweenInfo)
	for _, GuiObject in ipairs( Objs ) do
		local objectGoal = nil
		if GuiObject:IsA('Frame') then
			objectGoal = {BackgroundTransparency = endTransparency}
		elseif GuiObject:IsA('TextLabel') then
			objectGoal = {BackgroundTransparency = endTransparency, TextTransparency = endTransparency}
		elseif GuiObject:IsA('UIStroke') then
			objectGoal = {Transparency = endTransparency}
		elseif GuiObject:IsA('ImageLabel') or GuiObject:IsA('ImageButton') then
			objectGoal = {BackgroundTransparency = endTransparency, ImageTransparency = endTransparency}
		end
		TweenService:Create(GuiObject, tweenInfo, objectGoal):Play()
	end
end

return Module
