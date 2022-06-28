local TweenService = game:GetService('TweenService')

-- // Module // --
local Module = {}

function Module:ScaleModel(Model, scale)
	local primary = Model and Model.PrimaryPart
	if not primary then
		error("No Primary Part set on model ".. (Model and Model:GetFullName() or "No Model"))
	end
	local primaryCF = primary.CFrame
	for _, v in ipairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Size *= scale
			if v == primary then
				continue
			end
			v.CFrame = (primaryCF + (primaryCF:Inverse() * v.Position * scale))
		end
	end
end

function Module:WeldConstraint(WeldMe, ToThis)
	local constraint = Instance.new('WeldConstraint')
	constraint.Name = 'WeldConstraintInstance'
	constraint.Part0 = WeldMe
	constraint.Part1 = ToThis
	constraint.Parent = ToThis
	return constraint
end

local tweenCache = {}
function Module:TweenModel(Model, endCFrame, tweenInfo, Yield)
	local cfValue = Instance.new('CFrameValue')
	cfValue.Name = Model:GetFullName()
	cfValue.Value = Model:GetPrimaryPartCFrame()
	cfValue.Changed:Connect(function()
		Model:SetPrimaryPartCFrame(cfValue.Value)
	end)
	cfValue.Parent = script

	local Tween = tweenCache[Model]
	if Tween then
		Tween:Cancel()
		tweenCache[Model] = nil
	end

	Tween = TweenService:Create(cfValue, tweenInfo or TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Value = endCFrame})

	Tween.Completed:Connect(function()
		if tweenCache[Model] == Tween then
			tweenCache[Model] = nil
		end
		cfValue:Destroy()
	end)

	Tween:Play()

	if Yield then
		Tween.Completed:Wait()
	end
end

return Module
