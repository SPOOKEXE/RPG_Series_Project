
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local CharacterCreatorConfig = ReplicatedModules.Data.CharacterCreatorConfig

local RemoteService = ReplicatedModules.Services.RemoteService
local CharacterCreationFunction = RemoteService:GetRemote('CharacterCreationFunction', 'RemoteFunction', false)

local PromiseModule = ReplicatedModules.Classes.Promise

local SystemsContainer = {}

-- // Module // --
local Module = {}

-- if they change their character ingame
function Module:SetCharacterData(LocalPlayer, CharacterData)
	if not CharacterCreatorConfig:IsValidCharacterData(CharacterData) then
		return false
	end
	local activeSaveData = SystemsContainer.SaveSelectionSystem:GetActiveSaveData( LocalPlayer )
	if not activeSaveData then
		return false
	end
	if not activeSaveData.CustomCharacter then
		warn('Tried to set custom character data when no character is created!')
		return false
	end
	activeSaveData.CustomCharacter = CharacterData
end

-- ask the client to open the character creator menu
-- and when they cancel / finish check the data here and return if valid
function Module:GetNewlyCreatedCharacter( LocalPlayer )
	local Data = false
	PromiseModule.new(function( resolve, _, _ )
		resolve( CharacterCreationFunction:InvokeClient(LocalPlayer) )
	end):andThen(function(characterData)
		print(characterData)
		if CharacterCreatorConfig:IsValidCharacterData(characterData) then
			Data = characterData
		end
	end):catch(function(_)
		warn('Failed to get character data from '..LocalPlayer.Name..' - probably disconnected.')
	end):await()
	return Data
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems
end

return Module