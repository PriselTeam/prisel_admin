util.AddNetworkString("Prisel::ClearPropsPlayer")
util.AddNetworkString("Prisel::ClearPlayerVehicles")
util.AddNetworkString("Prisel::SellPlayerDoor")

net.Receive("Prisel::ClearPropsPlayer", function(len, ply)
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

