hook.Add("OnContextMenuOpen", "Prisel.AdminMenu.ContextOpen", function()
  Prisel.Admin.ShowMenu()
  return false
end)

hook.Add("OnContextMenuClose", "Prisel.AdminMenu.ContextClose", function()
  Prisel.Admin.HideMenu()
  hook.Remove("HUDPaint","Prisel.ShowContent.Base")
  gui.EnableScreenClicker(false)
end)

net.Receive("Prisel.AdminLocker.RequestPlayerSanctions", function()
  local pTarget = net.ReadEntity()
  if not IsValid(pTarget) then return end

  local iSanctions = net.ReadUInt(8)
  print("Sanctions: " .. iSanctions)
  local tSanctions = {}
  for i = 1, iSanctions do
    local iId = net.ReadUInt(32)
    local sReason = net.ReadString()
    local sAdminSteamID64 = net.ReadString()
    local iSanctionType = net.ReadUInt(8)
    tSanctions[i] = {
      iId = iId,
      sReason = sReason,
      sAdminSteamID64 = sAdminSteamID64,
      iSanctionType = iSanctionType,
    }
  end

  PrintTable(tSanctions)

  Prisel.Admin.Sanctions[pTarget:SteamID64()] = {}
  Prisel.Admin.Sanctions[pTarget:SteamID64()] = tSanctions
end)