
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local TimeModule = ReplicatedModules.Utility.Time
local NumbersModule = ReplicatedModules.Utility.Numbers

local DAY_DURATION =  24 * 60 * 60
local REMAINING_TEXT_FORMAT = "Remaining Duration : %s seconds"

local Module = {}

function Module:CompileBanMessage(BannedData)
	if typeof(BannedData.Duration) == 'string' then
		return BannedData.Duration
	end
	local currentUTC = TimeModule:GetUTC()
	local duration = NumbersModule:RoundN(currentUTC - BannedData.Duration, 1)
	return string.format(REMAINING_TEXT_FORMAT, duration)
end

function Module:CheckProfileBanExpired(_, Profile)
	local currentUTC = TimeModule:GetUTC()
	local BannedData = Profile.Data.Banned
	if BannedData and (currentUTC - BannedData.Start) >= BannedData.Duration then
		Profile.Data.Banned = nil
	end
	return (Profile.Data.Banned == nil)
end

function Module:BanPlayer(LocalPlayer, Profile, BanProperties)
	BanProperties = {
		Moderator = BanProperties.Moderator or 'Server',
		Duration = BanProperties.Duration or (1 * DAY_DURATION),
		Reason = BanProperties.Reason or 'Unknown Reason',
		Start = TimeModule:GetUTC(),
	}

	Profile.Data.Banned = BanProperties

	LocalPlayer:Kick('You have been banned for : '..BanProperties.Duration)
end

function Module:Init(_)

end

return Module
