local adminGUI = {}
local adminPanel
local canClose = true
local playerTBL = {}
local timeStaff = 0

function Prisel.Admin.OpenPlayerInfo(player)
  if not LocalPlayer():PIsStaff() then return end
  if not LocalPlayer():HasAdminMode() then return end

  Prisel.Admin.HideMenu()

  local infoPlayer = vgui.Create("Prisel.Frame")
  infoPlayer:SetSize(DarkRP.ScrW*0.5, DarkRP.ScrH*0.8)
  infoPlayer:SetPos(DarkRP.ScrW / 2 - infoPlayer:GetWide()/2, DarkRP.ScrH / 2 - infoPlayer:GetTall()/2)
  infoPlayer:SetTitle("Informations du joueur")
  infoPlayer:ShowCloseButton(true)
  infoPlayer:MakePopup()

  local avatar = vgui.Create("Prisel.AvatarRounded", infoPlayer)
  avatar:SetSize(infoPlayer:GetWide()*0.15, infoPlayer:GetWide()*0.15)
  avatar:SetPos(infoPlayer:GetWide()*0.02, infoPlayer:GetTall()*0.115)
  avatar:SetPlayer(player, 128)

  local nameLabel = vgui.Create("DLabel", infoPlayer)
  nameLabel:SetPos(infoPlayer:GetWide()*0.2, infoPlayer:GetTall()*0.12)
  nameLabel:SetSize(infoPlayer:GetWide()*0.3, infoPlayer:GetTall()*0.05)
  nameLabel:SetFont(DarkRP.Library.Font(15, 0, "Montserrat Bold"))
  nameLabel:SetText(player:HasAdminMode() and (player:Nick() .." [MODE ADMIN]") or player:Nick())
  nameLabel:SetTextColor(player:HasAdminMode() and DarkRP.Config.Colors.Blue or color_white)
  nameLabel:SetContentAlignment(4)
  nameLabel:SizeToContents()
  nameLabel.dec = false

  function nameLabel:Think()
    if not IsValid(player) then
      if not self.dec then
        self:SetText(self:GetText().." (Déconnecté)")
        self:SetTextColor(DarkRP.Config.Colors.Red)
        self:SizeToContents()
        self.dec = true
      end
    end
  end
  
  local rankLabel = vgui.Create("DLabel", infoPlayer)
  rankLabel:SetPos(infoPlayer:GetWide()*0.2, infoPlayer:GetTall()*0.21)
  rankLabel:SetSize(infoPlayer:GetWide()*0.45, infoPlayer:GetTall()*0.05)
  rankLabel:SetFont(DarkRP.Library.Font(8, 0, "Montserrat Bold"))
  rankLabel:SetText(string.upper(player:GetUserGroup()))
  rankLabel:SetTextColor(color_white)
  rankLabel:SetContentAlignment(4)

  local jobLabel = vgui.Create("DLabel", infoPlayer)
  jobLabel:SetPos(infoPlayer:GetWide()*0.2, infoPlayer:GetTall()*0.235)
  jobLabel:SetSize(infoPlayer:GetWide()*0.45, infoPlayer:GetTall()*0.05)
  jobLabel:SetFont(DarkRP.Library.Font(8, 0, "Montserrat Bold"))
  jobLabel:SetText(player:getDarkRPVar("job") or "Aucun métier")
  jobLabel:SetTextColor(color_white)
  jobLabel:SetContentAlignment(4)

  local moneyLabel = vgui.Create("DLabel", infoPlayer)
  moneyLabel:SetPos(infoPlayer:GetWide()*0.2, infoPlayer:GetTall()*0.26)
  moneyLabel:SetSize(infoPlayer:GetWide()*0.45, infoPlayer:GetTall()*0.05)
  moneyLabel:SetFont(DarkRP.Library.Font(8, 0, "Montserrat Bold"))
  moneyLabel:SetText("Argent : "..DarkRP.formatMoney(player:getDarkRPVar("money") or 0))
  moneyLabel:SetTextColor(color_white)
  moneyLabel:SetContentAlignment(4)

  local timeLabel = vgui.Create("DLabel", infoPlayer)
  timeLabel:SetPos(infoPlayer:GetWide()*0.2, infoPlayer:GetTall()*0.16)
  timeLabel:SetSize(infoPlayer:GetWide()*0.45, infoPlayer:GetTall()*0.05)
  timeLabel:SetFont(DarkRP.Library.Font(8, 0, "Montserrat Bold"))
  timeLabel:SetText("Temps de jeu total : "..DarkRP.Library.FormatSeconds(player:GetUTimeTotalTime(), true))
  timeLabel:SetTextColor(color_white)
  timeLabel:SetContentAlignment(4)
  
  function timeLabel:Think()
    if not IsValid(player) then return end
    self:SetText("Temps de jeu total : "..DarkRP.Library.FormatSeconds(player:GetUTimeTotalTime(), true))
  end

  local sessionTimeLabel = vgui.Create("DLabel", infoPlayer)
  sessionTimeLabel:SetPos(infoPlayer:GetWide()*0.2, infoPlayer:GetTall()*0.185)
  sessionTimeLabel:SetSize(infoPlayer:GetWide()*0.45, infoPlayer:GetTall()*0.05)
  sessionTimeLabel:SetFont(DarkRP.Library.Font(8, 0, "Montserrat Bold"))
  sessionTimeLabel:SetText("Session : "..DarkRP.Library.FormatSeconds(player:GetUTimeSessionTime(), true))
  sessionTimeLabel:SetTextColor(color_white)
  sessionTimeLabel:SetContentAlignment(4)
  
  function sessionTimeLabel:Think()
    if not IsValid(player) then return end
    self:SetText("Session : "..DarkRP.Library.FormatSeconds(player:GetUTimeSessionTime(), true))
  end

  local function CreateButton(parent, text, color, callback)
    local button = vgui.Create("Prisel.Button", parent)
    button:SetSize(DarkRP.ScrW * 0.09, DarkRP.ScrH * 0.035)
    button:SetText(text)
    button:SetFont(DarkRP.Library.Font(7, 0, "Montserrat Bold"))
    button:SetBackgroundColor(color)
    button.DoClick = callback
    return button
  end

  local iconLayoutButton = vgui.Create("DIconLayout", infoPlayer)
  iconLayoutButton:SetSize(infoPlayer:GetWide() * 0.8, infoPlayer:GetTall() * 0.05)
  iconLayoutButton:SetPos(infoPlayer:GetWide() * 0.2, infoPlayer:GetTall() * 0.32)
  iconLayoutButton:SetSpaceY(5)
  iconLayoutButton:SetSpaceX(5)

  CreateButton(iconLayoutButton, "Copier SteamID", DarkRP.Config.Colors.Blue, function()
    SetClipboardText(player:SteamID())
    notification.AddLegacy(("SteamID de %s copié !"):format(player:Nick()), NOTIFY_GENERIC, 2)
    surface.PlaySound("buttons/button15.wav")
  end)

  CreateButton(iconLayoutButton, "Copier SteamID64", DarkRP.Config.Colors.Blue, function()
    SetClipboardText(player:SteamID64())
    notification.AddLegacy(("SteamID64 de %s copié !"):format(player:Nick()), NOTIFY_GENERIC, 2)
    surface.PlaySound("buttons/button15.wav")
  end)

  CreateButton(iconLayoutButton, "Copier Profil Steam", DarkRP.Config.Colors.Blue, function()
    SetClipboardText("https://steamcommunity.com/profiles/" .. player:SteamID64())
    notification.AddLegacy(("Steam Profile de %s copié !"):format(player:Nick()), NOTIFY_GENERIC, 2)
    surface.PlaySound("buttons/button15.wav")
  end)

  CreateButton(iconLayoutButton, "Copier Nom RP", DarkRP.Config.Colors.Blue, function()
    SetClipboardText(player:Nick())
    notification.AddLegacy(("Nom RP de %s copié !"):format(player:Nick()), NOTIFY_GENERIC, 2)
    surface.PlaySound("buttons/button15.wav")
  end)

  local iconLayoutActions = vgui.Create("DIconLayout", infoPlayer)
  iconLayoutActions:SetSize(infoPlayer:GetWide() * 0.8, infoPlayer:GetTall() * 0.05)
  iconLayoutActions:SetPos(infoPlayer:GetWide() * 0.2, infoPlayer:GetTall() * 0.39)
  iconLayoutActions:SetSpaceY(5)
  iconLayoutActions:SetSpaceX(5)

  CreateButton(iconLayoutActions, "Téléporter", DarkRP.Config.Colors.Green, function()
    local command = ("sam goto \"%s\""):format(player:Nick())
    LocalPlayer():ConCommand(command)
  end)

  CreateButton(iconLayoutActions, "Bring", DarkRP.Config.Colors.Green, function()
    local command = ("sam bring \"%s\""):format(player:Nick())
    LocalPlayer():ConCommand(command)
  end)

  CreateButton(iconLayoutActions, "Spectate", DarkRP.Config.Colors.Green, function()
    local command = ("FSpectate \"%s\""):format(player:Nick())
    LocalPlayer():ConCommand(command)
  end)

  CreateButton(iconLayoutActions, "TP Salle admin", DarkRP.Config.Colors.Green, function()
    -- LocalPlayer():ConCommand("FSPectate " .. player:Nick())
  end)

  local iconLayoutBase = vgui.Create("DIconLayout", infoPlayer)
  iconLayoutBase:SetSize(infoPlayer:GetWide() * 0.8, infoPlayer:GetTall() * 0.05)
  iconLayoutBase:SetPos(infoPlayer:GetWide() * 0.2, infoPlayer:GetTall() * 0.46)
  iconLayoutBase:SetSpaceY(5)
  iconLayoutBase:SetSpaceX(5)

  CreateButton(iconLayoutBase, "Clear Props", DarkRP.Library.ColorNuance(DarkRP.Config.Colors.Blue, 25), function()
    net.Start("Prisel::ClearPropsPlayer")
    net.WriteString(player:Nick())
    net.SendToServer()
  end)

  CreateButton(iconLayoutBase, "Clear Vehicles", DarkRP.Library.ColorNuance(DarkRP.Config.Colors.Blue, 25), function()
    net.Start("Prisel::ClearPlayerVehicles")
    net.WriteString(player:Nick())
    net.SendToServer()
  end)

  CreateButton(iconLayoutBase, "Sell Doors", DarkRP.Library.ColorNuance(DarkRP.Config.Colors.Blue, 25), function()
    net.Start("Prisel::SellPlayerDoor")
    net.WriteString(player:Nick())
    net.SendToServer()
  end)

  CreateButton(iconLayoutBase, "Changer Nom RP", DarkRP.Library.ColorNuance(DarkRP.Config.Colors.Blue, 25), function()
    local name = Derma_StringRequest("Changer le nom RP", "Changer le nom RP", "", function(text)
      local commands = ("sam forcename \"%s\" \"%s\""):format(player:Nick(), text)
      LocalPlayer():ConCommand(commands)
    end)
  end)

  local iconLayoutActionsRisk = vgui.Create("DIconLayout", infoPlayer)
  iconLayoutActionsRisk:SetSize(infoPlayer:GetWide() * 0.8, infoPlayer:GetTall() * 0.05)
  iconLayoutActionsRisk:SetPos(infoPlayer:GetWide() * 0.2, infoPlayer:GetTall() * 0.53)
  iconLayoutActionsRisk:SetSpaceY(5)
  iconLayoutActionsRisk:SetSpaceX(5)

  CreateButton(iconLayoutActionsRisk, "Jail", DarkRP.Config.Colors.Red, function()
    local time = Derma_StringRequest("Temps du jail", "Temps du jail en minutes", "", function(text)
      if not tonumber(text) then return end
      local reason = Derma_StringRequest("Raison du jail", "Raison du jail", "", function(text2)
        local commands = ("sam jail \"%s\" %s \"%s\""):format(player:Nick(), text, text2)
        LocalPlayer():ConCommand(commands)
      end)
    end)
  end)

  CreateButton(iconLayoutActionsRisk, "Kick", DarkRP.Config.Colors.Red, function()
    local reason = Derma_StringRequest("Raison du kick", "Raison du kick", "", function(text)
      local commands = ("sam kick \"%s\" \"%s\""):format(player:Nick(), text)
      LocalPlayer():ConCommand(commands)
    end)
  end)

  CreateButton(iconLayoutActionsRisk, "Ban", DarkRP.Config.Colors.Red, function()
    local reason = Derma_StringRequest("Raison du ban", "Raison du ban", "", function(text)
      local time = Derma_StringRequest("Durée du ban", "Durée du ban ( en minutes ) ( 0 pour indéfini )", "", function(text2)
        local commands = ("sam ban \"%s\" %s \"%s\""):format(player:Nick(), text2, text)
        LocalPlayer():ConCommand(commands)
      end)
    end)
  end)
end

function Prisel.Admin.AdminMode()
  timer.Simple(0.2, function()
    if not LocalPlayer():PIsStaff() then return end
    if not LocalPlayer():HasAdminMode() then 
      hook.Remove("HUDPaint", "Prisel.AdminMode.PlayerInfos")
    return end
    local isNoclip = LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP
    hook.Add("HUDPaint", "Prisel.AdminMode.PlayerInfos", function()
      if not LocalPlayer():PIsStaff() then return end
      if not LocalPlayer():HasAdminMode() then 
        hook.Remove("HUDPaint", "Prisel.AdminMode.PlayerInfos")
      return end
      isNoclip = LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP
      draw.SimpleTextOutlined("Mode Administration", DarkRP.Library.Font(12, 0, "Montserrat Bold"), DarkRP.ScrW / 2, DarkRP.ScrH * 0.02, DarkRP.Config.Colors.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
      draw.SimpleTextOutlined("Temps de staff : "..DarkRP.Library.FormatSeconds(CurTime()-timeStaff, true), DarkRP.Library.Font(10, 0, "Montserrat Bold"), DarkRP.ScrW *0.995, DarkRP.ScrH * 0.02, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
    
      for k, v in ipairs(player.GetAll()) do
        if v == LocalPlayer() then continue end
        if not v:IsValid() then continue end

        if LocalPlayer():GetPos():Distance(v:GetPos()) > 2500 then continue end

        local pPos = (v:GetPos() + Vector(0, 0, 80)):ToScreen()
        pPos.y = pPos.y - 40

        draw.SimpleTextOutlined(v:Nick(), DarkRP.Library.Font(6, 0, "Montserrat Bold"), pPos.x, pPos.y, DarkRP.Library.ColorNuance(DarkRP.Config.Colors.Blue, 25), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        draw.SimpleTextOutlined(v:Health().."%", DarkRP.Library.Font(6, 0, "Montserrat Bold"), pPos.x, pPos.y + 15, DarkRP.Config.Colors.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        draw.SimpleTextOutlined(v:Armor().."%", DarkRP.Library.Font(6, 0, "Montserrat Bold"), pPos.x, pPos.y + 30, DarkRP.Config.Colors.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        draw.SimpleTextOutlined(string.upper(v:GetUserGroup()), DarkRP.Library.Font(6, 0, "Montserrat Bold"), pPos.x, pPos.y + 45, DarkRP.Config.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
      end
    end)
  end)
end

function Prisel.Admin.CreatePanelAdmin()
  if not LocalPlayer():PIsStaff() then return end
  if not LocalPlayer():HasAdminMode() then return end

  for _, v in ipairs(adminGUI) do
    if not v:IsValid() then continue end
    v:AlphaTo(0, 0.3, 0, function()
      if not v:IsValid() then return end
      v:Remove()
    end)
  end

  playerTBL = player.GetAll()

  adminPanel = vgui.Create("Prisel.Frame")
  adminPanel:SetSize(DarkRP.ScrW * 0.26, DarkRP.ScrH)
  adminPanel:SetPos(-DarkRP.ScrW * 0.26, 0)
  adminPanel:SetTitle("Menu d'Administration")
  adminPanel:ShowCloseButton(false)
  adminPanel.IsRounded = false
  adminPanel:MakePopup()
  adminPanel:MoveTo(0, 0, 0.3, 0, -1, function()
    if not adminPanel:IsValid() then return end
  end)

  local width = adminPanel:GetWide()
  local height = adminPanel:GetTall()

  local noservice = vgui.Create("Prisel.Button", adminPanel)
  noservice:SetSize(width * 0.9, height * 0.05)
  noservice:Dock(BOTTOM)
  noservice:DockMargin(width * 0.05, height * 0.05, width * 0.05, height * 0.005)
  noservice:SetText("Quitter son service")
  noservice:SetFont(DarkRP.Library.Font(10, 0, "Montserrat Bold"))
  noservice:SetBackgroundColor(DarkRP.Config.Colors.Red)
  
  function noservice:DoClick()
    if LocalPlayer():PIsStaff() then
      if LocalPlayer():HasAdminMode() then
        LocalPlayer():SetAdminMode(false)
        Prisel.Admin.HideMenu()
        Prisel.Admin.AdminMode()
      end
    end
  end

  local playerPanel = vgui.Create("DPanel", adminPanel)
  playerPanel:SetSize(width * 0.9, height * 0.8)
  playerPanel:SetPos(width * 0.05, height * 0.125)

  function playerPanel:Paint(w,h)
    surface.SetDrawColor(DarkRP.Config.Colors.Grey)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(DarkRP.Config.Colors.Blue)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
  end

  local playerListScroll = vgui.Create("DScrollPanel", playerPanel)
  playerListScroll:Dock(FILL)
  playerListScroll:DockMargin(5, 5, 5, 5)
  playerListScroll:SetPos(0, 0)
  playerListScroll.VBar:SetWide(0)

  function adminPanel.reloadPlayerList()
    playerListScroll:Clear()
    for k, v in ipairs(playerTBL) do
      local playerPanel = playerListScroll:Add("DPanel")
      playerPanel:SetSize(width * 0.9, height * 0.05)
      playerPanel:SetBackgroundColor(DarkRP.Config.Colors.Grey)
      playerPanel:Dock(TOP)
      playerPanel:DockMargin(width * 0.03, height * 0.015, width * 0.03, 0)
      playerPanel.PlayerInfo = {v:Nick(), v:SteamID(), v:SteamID64()}

      local avatar = vgui.Create("Prisel.AvatarRounded", playerPanel)
      avatar:SetSize(playerPanel:GetTall()*0.8, playerPanel:GetTall()*0.8)
      avatar:SetPos(playerPanel:GetWide()*0.01, playerPanel:GetTall()*0.1)
      avatar:SetPlayer(v, 128)

      local nameLabel = vgui.Create("DLabel", playerPanel)
      nameLabel:SetPos(playerPanel:GetWide()*0.12, playerPanel:GetTall()*0.1)
      nameLabel:SetSize(playerPanel:GetWide()*0.28, playerPanel:GetTall()*0.8)
      nameLabel:SetFont(DarkRP.Library.Font(8, 0, "Montserrat Bold"))
      nameLabel:SetText(v:Nick())
      nameLabel:SetTextColor(color_white)
      nameLabel:SetContentAlignment(4)

      local buttonTP = vgui.Create("Prisel.Button", playerPanel)
      buttonTP:SetSize(playerPanel:GetWide()*0.15, playerPanel:GetTall()*0.8)
      buttonTP:SetPos(playerPanel:GetWide()*0.4, playerPanel:GetTall()/2 - buttonTP:GetTall()/2)
      buttonTP:SetText("TP")
      buttonTP:SetBackgroundColor(DarkRP.Config.Colors.Blue)

      function buttonTP:DoClick()
        LocalPlayer():ConCommand("sam goto "..v:Nick())
      end

      local buttonBring = vgui.Create("Prisel.Button", playerPanel)
      buttonBring:SetSize(playerPanel:GetWide()*0.2, playerPanel:GetTall()*0.8)
      buttonBring:SetPos(playerPanel:GetWide()*0.56, playerPanel:GetTall()/2 - buttonBring:GetTall()/2)
      buttonBring:SetText("Bring")
      buttonBring:SetBackgroundColor(DarkRP.Config.Colors.Red)

      function buttonBring:DoClick()
        LocalPlayer():ConCommand("sam bring "..v:Nick())
      end

      local buttonPlus = vgui.Create("Prisel.Button", playerPanel)
      buttonPlus:SetSize(playerPanel:GetWide()*0.135, playerPanel:GetTall()*0.8)
      buttonPlus:SetPos(playerPanel:GetWide()*0.77, playerPanel:GetTall()/2 - buttonPlus:GetTall()/2)
      buttonPlus:SetText("+")
      buttonPlus:SetBackgroundColor(DarkRP.Config.Colors.Green)

      function buttonPlus:DoClick()
        Prisel.Admin.OpenPlayerInfo(v)
      end
    end
  end

  adminPanel.reloadPlayerList()

  local searchPlayer = vgui.Create("DTextEntry", adminPanel)
  searchPlayer:SetPos(width * 0.05, height * 0.08)
  searchPlayer:SetSize(width * 0.9, height * 0.03)
  searchPlayer:SetFont(DarkRP.Library.Font(10, 0, "Montserrat Bold"))
  searchPlayer:SetPlaceholderText("Rechercher un joueur")
  searchPlayer:SetDrawLanguageID(false)
  
  local placeholderColor = color_white
  local textColor = color_white
  local highlightColor = color_white
  
  function searchPlayer:Paint(w, h)
      surface.SetDrawColor(DarkRP.Config.Colors.Grey)
      surface.DrawRect(0, 0, w, h)
  
      if self.GetPlaceholderText and self.GetPlaceholderColor and self:GetPlaceholderText() and self:GetPlaceholderText():Trim() ~= "" and self:GetPlaceholderColor() and (not self:GetText() or self:GetText() == "") then
          local oldText = self:GetText()
          local str = self:GetPlaceholderText()
          if str:StartWith("#") then
              str = str:sub(2)
          end
          str = language.GetPhrase(str)
          self:SetText(str)
          self:DrawTextEntryText(placeholderColor, highlightColor, color_white)
          self:SetText(oldText)
          return
      end
  
      self:DrawTextEntryText(textColor, highlightColor, color_white)
  end

  function searchPlayer:OnChange()
    if not IsValid(playerListScroll) then return end
    playerListScroll:Clear()
    local search = self:GetText():lower()
    if search == "" then
      adminPanel.reloadPlayerList()
      return
    end

    for k, v in ipairs(playerTBL) do
      if v:Nick():lower():find(search) then
        local playerPanel = playerListScroll:Add("DPanel")
        playerPanel:SetSize(width * 0.9, height * 0.05)
        playerPanel:SetBackgroundColor(DarkRP.Config.Colors.Grey)
        playerPanel:Dock(TOP)
        playerPanel:DockMargin(width * 0.03, height * 0.015, width * 0.03, 0)
        playerPanel.PlayerInfo = {v:Nick(), v:SteamID(), v:SteamID64()}
  
        local avatar = vgui.Create("Prisel.AvatarRounded", playerPanel)
        avatar:SetSize(playerPanel:GetTall()*0.8, playerPanel:GetTall()*0.8)
        avatar:SetPos(playerPanel:GetWide()*0.01, playerPanel:GetTall()*0.1)
        avatar:SetPlayer(v, 128)
  
        local nameLabel = vgui.Create("DLabel", playerPanel)
        nameLabel:SetPos(playerPanel:GetWide()*0.12, playerPanel:GetTall()*0.1)
        nameLabel:SetSize(playerPanel:GetWide()*0.28, playerPanel:GetTall()*0.8)
        nameLabel:SetFont(DarkRP.Library.Font(8, 0, "Montserrat Bold"))
        nameLabel:SetText(v:Nick())
        nameLabel:SetTextColor(color_white)
        nameLabel:SetContentAlignment(4)
  
        local buttonTP = vgui.Create("Prisel.Button", playerPanel)
        buttonTP:SetSize(playerPanel:GetWide()*0.15, playerPanel:GetTall()*0.8)
        buttonTP:SetPos(playerPanel:GetWide()*0.4, playerPanel:GetTall()/2 - buttonTP:GetTall()/2)
        buttonTP:SetText("TP")
        buttonTP:SetBackgroundColor(DarkRP.Config.Colors.Blue)
  
        function buttonTP:DoClick()
          LocalPlayer():ConCommand("sam goto "..v:Nick())
        end
  
        local buttonBring = vgui.Create("Prisel.Button", playerPanel)
        buttonBring:SetSize(playerPanel:GetWide()*0.2, playerPanel:GetTall()*0.8)
        buttonBring:SetPos(playerPanel:GetWide()*0.56, playerPanel:GetTall()/2 - buttonBring:GetTall()/2)
        buttonBring:SetText("Bring")
        buttonBring:SetBackgroundColor(DarkRP.Config.Colors.Red)
  
        function buttonBring:DoClick()
          LocalPlayer():ConCommand("sam bring "..v:Nick())
        end
  
        local buttonPlus = vgui.Create("Prisel.Button", playerPanel)
        buttonPlus:SetSize(playerPanel:GetWide()*0.135, playerPanel:GetTall()*0.8)
        buttonPlus:SetPos(playerPanel:GetWide()*0.77, playerPanel:GetTall()/2 - buttonPlus:GetTall()/2)
        buttonPlus:SetText("+")
        buttonPlus:SetBackgroundColor(DarkRP.Config.Colors.Green)
  
        function buttonPlus:DoClick()
          Prisel.Admin.OpenPlayerInfo(v)
        end
      end
    end
  end
end

function Prisel.Admin.ShowMenu()
  gui.EnableScreenClicker(true)

  local cooldownCopy = 0
  local localPlayer = LocalPlayer()

  hook.Add("HUDPaint", "Prisel.ShowContent.Base", function()
    draw.SimpleTextOutlined("Clique gauche sur un joueur pour " .. (localPlayer:HasAdminMode() and "ouvrir le panel joueur" or "copier le SteamID"), DarkRP.Library.Font(10, 0, "Montserrat Bold"), DarkRP.ScrW / 2, localPlayer:HasAdminMode() and DarkRP.ScrH * 0.05 or DarkRP.ScrH * 0.02, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

    local mousePosX, mousePosY = input.GetCursorPos()


    for _, v in ipairs(player.GetAll()) do
        if v ~= localPlayer and v:IsValid() and v:IsOnScreen() then
            local pPos = v:GetPos():ToScreen()
            local distanceBetween = math.sqrt((mousePosX - pPos.x) ^ 2 + (mousePosY - pPos.y) ^ 2)

            if distanceBetween <= 100 then
                draw.SimpleTextOutlined("Clique gauche pour " .. (localPlayer:HasAdminMode() and "ouvrir le panel joueur" or "copier le SteamID"), DarkRP.Library.Font(8, 0, "Montserrat Bold"), pPos.x, pPos.y - 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
                if input.IsMouseDown(MOUSE_LEFT) and cooldownCopy < CurTime() then
                  if localPlayer:HasAdminMode() then
                    cooldownCopy = CurTime() + 1
                    Prisel.Admin.OpenPlayerInfo(v)
                  else
                    cooldownCopy = CurTime() + 1
                    local steamID = v:SteamID() ~= "NULL" and v:SteamID() or ("SteamID Non Valide (ID : "..v:UserID()..")")
                    SetClipboardText(steamID)
                    notification.AddLegacy(("SteamID de %s copié !"):format(v:Nick()), NOTIFY_GENERIC, 2)
                    surface.PlaySound("buttons/button15.wav")
                  end
                end
            end
        end
    end
  end)

  if localPlayer:PIsStaff() then
    if not localPlayer:HasAdminMode() then
      if IsValid(adminPanel) then
        adminPanel:Remove()
      end

      local gotoserviceButton = vgui.Create("Prisel.Button")
      gotoserviceButton:SetAlpha(0)
      gotoserviceButton:AlphaTo(255, 0.3, 0)
      gotoserviceButton:SetSize(DarkRP.ScrW * 0.2, DarkRP.ScrH * 0.05)
      gotoserviceButton:SetPos(DarkRP.ScrW / 2 - gotoserviceButton:GetWide()/2, DarkRP.ScrH * 0.96 - gotoserviceButton:GetTall()/2)
      gotoserviceButton:SetText("Prendre son service staff")
      gotoserviceButton:SetFont(DarkRP.Library.Font(10, 0, "Montserrat Bold"))
      gotoserviceButton:SetBackgroundColor(DarkRP.Config.Colors.Green)

      function gotoserviceButton:DoClick()
        localPlayer:SetAdminMode(true)
        Prisel.Admin.CreatePanelAdmin()
        Prisel.Admin.HideMenu()
        Prisel.Admin.AdminMode()
        timeStaff = CurTime()
      end

      adminGUI[#adminGUI + 1] = gotoserviceButton
    else
      Prisel.Admin.CreatePanelAdmin()
    end
  end
end

function Prisel.Admin.HideMenu()
  gui.EnableScreenClicker(false)
  hook.Remove("HUDPaint", "Prisel.ShowContent.Base")
  for _, v in ipairs(adminGUI) do
    if not v:IsValid() then continue end
    v:AlphaTo(0, 0.3, 0, function()
      if not v:IsValid() then return end
      v:Remove()
    end)
  end

  if adminPanel ~= nil and adminPanel:IsValid() and canClose then
    adminPanel:MoveTo(-DarkRP.ScrW * 0.26, 0, 0.3, 0, -1, function()
      if not adminPanel:IsValid() then return end
      adminPanel:Remove(  )
    end)
  end
end

hook.Add("OnTextEntryGetFocus", "Prisel.Admin.OnTextEntryGetFocus", function(pnl)
  if not LocalPlayer():PIsStaff() then return end
  if not LocalPlayer():HasAdminMode() then return end

  if IsValid(adminPanel) then
    canClose = false
  end
end)

hook.Add("OnTextEntryLoseFocus", "Prisel.Admin.OnTextEntryLoseFocus", function()
  if not LocalPlayer():PIsStaff() then return end
  if not LocalPlayer():HasAdminMode() then return end

  if IsValid(adminPanel) then
    canClose = true
    timer.Simple(0.1, function()
      if not IsValid(adminPanel) then return end
      if not canClose then return end
      Prisel.Admin.HideMenu()
    end)
  end
end)


hook.Add( "PlayerNoClip", "PriselV3:AdminMode:AntiNoClip", function(ply)
  return ply:HasAdminMode()
end )