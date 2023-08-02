
util.AddNetworkString("PriselV3::PlayerAdmin")

local playerStaffTimes = {}

net.Receive("PriselV3::PlayerAdmin", function(_, ply)

	local action = net.ReadUInt(2)

	if action == 1 then
		if not ply:PIsStaff() then return end
		local bool = net.ReadBool()
		if ply:HasAdminMode() == bool then return end
		ply:SetAdminMode(bool)
		for k, v in ipairs(player.GetAll()) do
			if v:PIsStaff() then
				DarkRP.notify(v, 0, 4, ("%s %s"):format(ply:Nick(), bool and "a rejoint le mode staff !" or "a quitté le mode staff !"))
			end
		end
		if not bool then
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetNoDraw(false)
			ply:DrawWorldModel(true)
			ply:SetRenderMode(RENDERMODE_NORMAL)
			ply:GodDisable()
			DarkRP.Library.HideWeapons(ply, false)
			DarkRP.Library.SendWebhook("https://discord.com/api/webhooks/1133863518077194240/bQGG3FKZSF6AmSBX6_8_wi6KgNNmESdyHmvjdNZv-w790FIbBTtZ946dvE07ePbcTIah",
				("Le joueur %s [%s] était en **mode administrateur pendant %s**"):format(ply:Nick(), ply:SteamID(), DarkRP.Library.FormatSeconds(CurTime() - playerStaffTimes[ply:SteamID64()])),
				{
					{["name"] = "Action", ["value"] = "Sortie du mode administrateur", ["inline"] = true},
					{["name"] = "Joueur", ["value"] = ply:Nick(), ["inline"] = true},
					{["name"] = "SteamID", ["value"] = ply:SteamID(), ["inline"] = true},
					{["name"] = "Rank", ["value"] = ply:GetUserGroup(), ["inline"] = true},
					{["name"] = "Durée", ["value"] = DarkRP.Library.FormatSeconds(CurTime() - playerStaffTimes[ply:SteamID64()]), ["inline"] = true}
				}
			)
			playerStaffTimes[ply:SteamID64()] = nil
		else
			ply:SetMoveType(MOVETYPE_NOCLIP)
			ply:SetNoDraw(true)
			ply:DrawWorldModel(false)
			ply:SetRenderMode(RENDERMODE_TRANSALPHA)
			ply:GodEnable()
			DarkRP.Library.HideWeapons(ply, true)
			playerStaffTimes[ply:SteamID64()] = CurTime()
			DarkRP.Library.SendWebhook("https://discord.com/api/webhooks/1133863518077194240/bQGG3FKZSF6AmSBX6_8_wi6KgNNmESdyHmvjdNZv-w790FIbBTtZ946dvE07ePbcTIah",
				("Le joueur %s est maintenant en **mode administrateur** à %s"):format(ply:Nick(), os.date("%H:%M:%S")),
				{
					{["name"] = "Action", ["value"] = "Entrée dans le mode administrateur", ["inline"] = true},
					{["name"] = "Joueur", ["value"] = ply:Nick(), ["inline"] = true},
					{["name"] = "SteamID", ["value"] = ply:SteamID(), ["inline"] = true},
					{["name"] = "Rank", ["value"] = ply:GetUserGroup(), ["inline"] = true},
				}
			)
		end
	end

end)

hook.Add("PlayerDisconnected", "PriselV3::PlayerAdmin", function(ply)
	if ply:HasAdminMode() then
		ply:SetAdminMode(false)
		DarkRP.Library.SendWebhook("https://discord.com/api/webhooks/1133863518077194240/bQGG3FKZSF6AmSBX6_8_wi6KgNNmESdyHmvjdNZv-w790FIbBTtZ946dvE07ePbcTIah",
			("(DECONNECTION) Le joueur %s [%s] était en **mode administrateur pendant %s**"):format(ply:Nick(), ply:SteamID(), DarkRP.Library.FormatSeconds(CurTime() - playerStaffTimes[ply:SteamID64()])),
			{
				{["name"] = "Action", ["value"] = "Sortie du mode administrateur", ["inline"] = true},
				{["name"] = "Joueur", ["value"] = ply:Nick(), ["inline"] = true},
				{["name"] = "SteamID", ["value"] = ply:SteamID(), ["inline"] = true},
				{["name"] = "Rank", ["value"] = ply:GetUserGroup(), ["inline"] = true},
				{["name"] = "Durée", ["value"] = DarkRP.Library.FormatSeconds(CurTime() - playerStaffTimes[ply:SteamID64()]), ["inline"] = true}
			}
		)
		playerStaffTimes[ply:SteamID64()] = nil
	end
end)