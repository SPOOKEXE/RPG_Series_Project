-- local ServerCore = require(game:GetService('ServerStorage'):WaitForChild('Core'))
return function(_, target_players, amount)
	if #target_players == 0 then
		return false, "No players specified"
	end
	return string.format("Not Implemented! Tried adding %s coins to %s players", amount, #target_players)
	--[[
	local message_additions = {}
	for _, target_player in ipairs( target_players ) do
		if ServerCore.DataService:AddCoins(target_player, amount) then
			table.insert(message_additions, target_player.Name)
		end
	end
	return table.concat(message_additions, ' + ')..' has recieved their money!']]
end