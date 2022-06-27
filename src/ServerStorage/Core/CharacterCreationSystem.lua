
local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:IsValidCharacterData(LocalPlayer, Profile, CharacterData)
	warn('Implement character creation character data validation function')
	return false
end

function Module:SetCharacterData(LocalPlayer, Profile, CharacterData)
	if not Module:IsValidCharacterData(LocalPlayer, Profile, CharacterData) then
		return false
	end
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems
end

return Module