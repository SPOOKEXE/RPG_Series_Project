
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')

local CharacterCreatorFolder = ReplicatedAssets.CharacterCreator

-- // Module // --
local Module = {}

Module.Options = {
	{
		Title = {
			Text = 'Hair Style',
			TextColor3 = Color3.new(1, 1, 1),
		},
		Directory = CharacterCreatorFolder.HairStyles,
	},
	{
		Title = {
			Text = 'Faces',
			TextColor3 = Color3.new(1, 1, 1),
		},
		Directory = CharacterCreatorFolder.Faces,
	},
	{
		Title = {
			Text = 'Shirt',
			TextColor3 = Color3.new(1, 1, 1),
		},
		Directory = CharacterCreatorFolder.Shirts,
	},
	{
		Title = {
			Text = 'Pants',
			TextColor3 = Color3.new(1, 1, 1),
		},
		Directory = CharacterCreatorFolder.Pants,
	},
	{
		Title = {
			Text = 'Body Color',
			TextColor3 = Color3.new(1, 1, 1),
		},
		Directory = CharacterCreatorFolder.BodyColors,
	},
}

function Module:IsValidCharacterData(characterData)
	if #characterData ~= #Module.Options then
		return false
	end

	for optionIndex, number in ipairs( characterData ) do
		local totalItemsInDirectory = #Module.Options[optionIndex].Directory:GetChildren()
		if (number % 1 ~= 0) or number < 1 or number > totalItemsInDirectory then
			return false
		end
	end
	return true
end

return Module
