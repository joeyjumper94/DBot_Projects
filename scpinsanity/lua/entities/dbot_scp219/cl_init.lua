include('shared.lua')
return net.Receive('SCP-219Menu', function()
  local ent = net.ReadEntity()
  if not IsValid(ent) then
    return 
  end
  local self = vgui.Create('DFrame')
  self:SetSize(200, 150)
  self:SetTitle('SCP-219')
  self:Center()
  self:MakePopup()
  local lab = self:Add('DLabel')
  lab:SetText('Strength (min 1):')
  lab:Dock(TOP)
  local entry = self:Add('DTextEntry')
  entry:SetText('1')
  entry:Dock(TOP)
  timer.Simple(0.1, function()
    return input.SetCursorPos(entry:LocalToScreen(5, 8))
  end)
  lab = self:Add('DLabel')
  lab:SetText('Duration (min 6):')
  lab:Dock(TOP)
  local entry2 = self:Add('DTextEntry')
  entry2:SetText('15')
  entry2:Dock(TOP)
  local button = self:Add('DButton')
  button:SetText('Launch')
  button.DoClick = function()
    local strength = tonumber(entry:GetText())
    local duration = tonumber(entry2:GetText())
    if strength and duration and strength >= 1 and duration > 5 then
      net.Start('SCP-219Menu')
      net.WriteEntity(ent)
      net.WriteUInt(math.ceil(strength), 32)
      net.WriteUInt(math.ceil(duration), 32)
      net.SendToServer()
    end
    return self:Close()
  end
  return button:Dock(TOP)
end)
