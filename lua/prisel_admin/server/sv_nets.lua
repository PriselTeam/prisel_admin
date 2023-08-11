
util.AddNetworkString("PriselV3::PlayerAdmin")
util.AddNetworkString("Prisel::ClearPropsPlayer")
util.AddNetworkString("Prisel::ClearPlayerVehicles")
util.AddNetworkString("Prisel::SellPlayerDoor")
util.AddNetworkString("Prisel.AdminLocker.RequestPlayerSanctions")
util.AddNetworkString("Prisel.AdminLocker.AddSanction")

local playerStaffTimes = {}

local playerCooldowns = {}

net.Receive("PriselV3::PlayerAdmin", function(_, ply)
	playerCooldowns[ply:SteamID64()] = playerCooldowns[ply:SteamID64()] or 0
	if playerCooldowns[ply:SteamID64()] > CurTime() then return end
	playerCooldowns[ply:SteamID64()] = CurTime() + 1

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

net.Receive("Prisel::ClearPropsPlayer", function(len, ply)
	playerCooldowns[ply:SteamID64()] = playerCooldowns[ply:SteamID64()] or 0
	if playerCooldowns[ply:SteamID64()] > CurTime() then return end
	playerCooldowns[ply:SteamID64()] = CurTime() + 1
  if not ply:HasAdminMode() then return end

    local targetName = net.ReadString()
    local targetPlayer = DarkRP.findPlayer(targetName)

    if IsValid(targetPlayer) then
        local count = 0
        for k, v in ipairs( ents.FindByClass( "prop_*" ) ) do
          if v:IsVehicle() then continue end
            if v:CPPIGetOwner() == targetPlayer then
                v:Remove()
                count = count + 1
            end
        end

        DarkRP.notify(ply, 0, 4, "Supprimé " .. count .. " props de " .. targetPlayer:Nick() .. ".")
    else
        DarkRP.notify(ply, 1, 4, "Joueur " .. targetName .. " introuvable.")
    end
end)

net.Receive("Prisel::ClearPlayerVehicles", function(len, ply)
	playerCooldowns[ply:SteamID64()] = playerCooldowns[ply:SteamID64()] or 0
	if playerCooldowns[ply:SteamID64()] > CurTime() then return end
	playerCooldowns[ply:SteamID64()] = CurTime() + 1
    if not ply:HasAdminMode() then return end

    local targetName = net.ReadString()
    local targetPlayer = DarkRP.findPlayer(targetName)

    if IsValid(targetPlayer) then
        local count = 0
        for k, v in ipairs( ents.FindByClass( "prop_vehicle_jeep" ) ) do
            if v:CPPIGetOwner() == targetPlayer then
                v:Remove()
                count = count + 1
            end
        end

        DarkRP.notify(ply, 0, 4, "Supprimé " .. count .. " véhicules de " .. targetPlayer:Nick() .. ".")
    else
        DarkRP.notify(ply, 1, 4, "Joueur " .. targetName .. " introuvable.")
    end
end)

net.Receive("Prisel::SellPlayerDoor", function(len, ply)
	playerCooldowns[ply:SteamID64()] = playerCooldowns[ply:SteamID64()] or 0
	if playerCooldowns[ply:SteamID64()] > CurTime() then return end
	playerCooldowns[ply:SteamID64()] = CurTime() + 1
  if not ply:HasAdminMode() then return end

  local targetName = net.ReadString()
  local targetPlayer = DarkRP.findPlayer(targetName)

  if IsValid(targetPlayer) then
      local count = 0
      for _, ent in ipairs(ents.GetAll()) do
          if not ent:isDoor() then continue end
          if not ent:isKeysOwnable() then continue end
          if ent:getDoorOwner() == targetPlayer then
              ent:keysUnOwn()
              count = count + 1
          end
      end

      if count > 0 then
          DarkRP.notify(ply, 0, 4, "Vendu " .. count .. " portes de " .. targetPlayer:Nick() .. ".")
      else
          DarkRP.notify(ply, 1, 4, "Aucune porte appartenant à " .. targetPlayer:Nick() .. " trouvée.")
      end
  else
      DarkRP.notify(ply, 1, 4, "Joueur " .. targetName .. " introuvable.")
  end
end)

net.Receive("Prisel.AdminLocker.RequestPlayerSanctions", function(_, ply)
	playerCooldowns[ply:SteamID64()] = playerCooldowns[ply:SteamID64()] or 0
	if playerCooldowns[ply:SteamID64()] > CurTime() then return end
	playerCooldowns[ply:SteamID64()] = CurTime() + 0.3
	if not ply:PIsStaff() then return end
	if not ply:HasAdminMode() then return end

	local pTarget = net.ReadEntity()
	if not IsValid(pTarget) then return end

	local tSanctions = pTarget:GetSanctions(function(tSanctions, iCount)
		if istable(tSanctions) then
			net.Start("Prisel.AdminLocker.RequestPlayerSanctions")
				net.WriteEntity(pTarget)
				net.WriteUInt(iCount, 8)
				for _, tSanction in ipairs(tSanctions) do
					net.WriteUInt(tSanction.id, 32)
					net.WriteString(tSanction.reason)
					net.WriteString(tSanction.admin_id)
					net.WriteUInt(tSanction.sanction_type, 8)
					net.WriteBool(tSanction.active)
					net.WriteUInt(tSanction.timestamp, 32)
				end
			net.Send(ply)
		end
	end)
end)

net.Receive("Prisel.AdminLocker.AddSanction", function(_, ply)
	playerCooldowns[ply:SteamID64()] = playerCooldowns[ply:SteamID64()] or 0
	if playerCooldowns[ply:SteamID64()] > CurTime() then return end
	playerCooldowns[ply:SteamID64()] = CurTime() + 1

	if not ply:PIsStaff() then return end
	if not ply:HasAdminMode() then return end

	local pTarget = net.ReadEntity()
	if not IsValid(pTarget) then return end
	local iSanctionType = net.ReadUInt(8)
	local sReason = net.ReadString()

	pTarget:AddSanction(sReason, ply:SteamID64(), iSanctionType)
end)

net.Receive("Prisel.AdminLocker.ActiveSanction", function(_, ply)
	playerCooldowns[ply:SteamID64()] = playerCooldowns[ply:SteamID64()] or 0
	if playerCooldowns[ply:SteamID64()] > CurTime() then return end
	playerCooldowns[ply:SteamID64()] = CurTime() + 1

	if not ply:PIsStaff() then return end
	if not ply:HasAdminMode() then return end
	if not Prisel.Admin.Config.StaffHG[ply:GetUserGroup()] then return end

	local pTarget = net.ReadEntity()
	if not IsValid(pTarget) then return end
	local iSanctionID = net.ReadUInt(32)

	print(pTarget, iSanctionID)
end)