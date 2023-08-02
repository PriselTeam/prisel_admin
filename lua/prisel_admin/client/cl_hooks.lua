hook.Add("OnContextMenuOpen", "Prisel.AdminMenu.ContextOpen", function()
  Prisel.Admin.ShowMenu()
  return false
end)

hook.Add("OnContextMenuClose", "Prisel.AdminMenu.ContextClose", function()
  Prisel.Admin.HideMenu()
  hook.Remove("HUDPaint","Prisel.ShowContent.Base")
  gui.EnableScreenClicker(false)
end)