
-- Copyright (C) 2017-2018 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

local sunset = Material('gui/daynight/sunset.png')
local sunrise = Material('gui/daynight/sunrise.png')
local moonset = Material('gui/daynight/moonset.png')
local moonrise = Material('gui/daynight/moonrise.png')
local vgui = vgui
local surface = surface
local DDayNight = DDayNight
local HUDCommons = DLib.HUDCommons
local draw = draw
local localize = DLib.i18n.localize
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local table = table
local IsValid = IsValid
local FrameTime = FrameTime
local gui = gui

local DISPLAY = CreateConVar('cl_ddaynight_context', '1', {FCVAR_ARCHIVE}, 'Display day/night progression when opening context menu')

local NIGHT_COLOR = Color(68, 138, 187)
local black = Color() * 0
local DAY_COLOR = Color(231, 206, 120)
local THICKNESS = 12
local SEGMENTS = 50
local ICONS_WIDE = 64
local TEXT_COLOR = Color(222, 110, 80)

timer.Simple(0, function()
	surface.CreateFont('DDayNight_MenuText', {
		font = 'Roboto',
		weight = 500,
		extended = true,
		size = ScreenSize(18)
	})
end)

-- true - day
-- false - night
local lastIcons = true
local lastday = 0
local lastnight = 0

local function paintprogress(self, w, h)
	local date = DDayNight.DATE_OBJECT
	local status = date:GetStatus()

	if lastIcons then
		local deg = math.floor(90 * lastday)
		HUDCommons.DrawArcHollow2(0, h * 0.2, w, SEGMENTS, THICKNESS, 135 + deg, 90 - deg, NIGHT_COLOR)
		HUDCommons.DrawArcHollow2(0, h * 0.2, w, SEGMENTS, THICKNESS, 135, deg, DAY_COLOR)
	else
		local deg = math.floor(90 * lastnight)
		HUDCommons.DrawArcHollow2(0, h * 0.2, w, SEGMENTS, THICKNESS, 135 + deg, 90 - deg, DAY_COLOR)
		HUDCommons.DrawArcHollow2(0, h * 0.2, w, SEGMENTS, THICKNESS, 135, deg, NIGHT_COLOR)
	end

	surface.SetDrawColor(255, 255, 255)

	if lastIcons then
		surface.SetMaterial(sunrise)
		surface.DrawTexturedRect(8, h * 0.3, ICONS_WIDE, ICONS_WIDE)
		surface.SetMaterial(sunset)
		surface.DrawTexturedRect(w - 64, h * 0.3, ICONS_WIDE, ICONS_WIDE)
	else
		surface.SetMaterial(moonrise)
		surface.DrawTexturedRect(8, h * 0.3, ICONS_WIDE, ICONS_WIDE)
		surface.SetMaterial(moonset)
		surface.DrawTexturedRect(w - 64, h * 0.3, ICONS_WIDE, ICONS_WIDE)
	end

	if status == date.STATUS_NIGHT then
		lastIcons = false
		lastnight = date:GetNightProgression()
	elseif status == date.STATUS_DAY then
		lastIcons = true
		lastday = date:GetDayProgression()
	elseif status == date.STATUS_SUNSET then
		draw.DrawText(localize('gui.daynight.menu.sunset'), 'DDayNight_MenuText', w * 0.5, h * 0.3, TEXT_COLOR, TEXT_ALIGN_CENTER)
		lastday = 1
	elseif status == date.STATUS_SUNRISE then
		draw.DrawText(localize('gui.daynight.menu.sunrise'), 'DDayNight_MenuText', w * 0.5, h * 0.3, TEXT_COLOR, TEXT_ALIGN_CENTER)
		lastnight = 1
	end
end

local function BuildClient(self)
	if not IsValid(self) then return end

	local sunstatus = vgui.Create('EditablePanel', self)

	function sunstatus:Paint(w, h)
		if w ~= h then
			self:SetSize(w, w)
			w, h = w, w
		end

		paintprogress(self, w, h)
	end

	sunstatus:Dock(TOP)

	local timestatus = vgui.Create('EditablePanel', self)
	timestatus:Dock(TOP)
	timestatus:SetSize(0, ScreenSize(140))

	function timestatus:Paint(w, h)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, w, h)

		DDayNight.HUDPaintFULL(w / 2, h * 0.13, true)
	end

	local chk = {'context', 'small', 'scoreboard'}

	for i, cvar in ipairs(chk) do
		self:CheckBox('gui.daynight.menu.cvar.' .. cvar, 'cl_ddaynight_' .. cvar)
	end
end

local function BuildServer(self)
	if not IsValid(self) then return end
end

hook.Add('PopulateToolMenu', 'DDayNight', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'daynight_client', 'DDayNight', '', '', BuildClient)
	--spawnmenu.AddToolMenuOption('Utilities', 'Admin', 'daynight_server', 'DDayNight', '', '', BuildServer)
end)

hook.Add('ContextMenuCreated', 'DDayNight', function(self)
	local sunstatus = vgui.Create('EditablePanel', self)
	sunstatus.Paint = paintprogress

	local w, h = ScreenSize(200), ScreenSize(200)
	local x, y = ScrWL() / 2 - w / 2, ScrHL() * 0.2
	sunstatus:SetPos(x, y)
	sunstatus:SetSize(w, h)
	sunstatus:SetAlpha(140)
	sunstatus:SetKeyboardInputEnabled(false)
	sunstatus:SetMouseInputEnabled(false)

	h = h * 0.4
	y = y + ScreenSize(30)

	local hoveralpha = 0

	function sunstatus:Think()
		local mx, my = gui.MousePos()
		sunstatus:SetAlpha(80 + hoveralpha * 175)

		if mx >= x and my >= y and mx <= x + w and my <= h + y then
			hoveralpha = (hoveralpha + FrameTime() * 3):min(1)
		else
			hoveralpha = (hoveralpha - FrameTime() * 3):max(0)
		end
	end

	cvars.AddChangeCallback('cl_ddaynight_context', function()
		sunstatus:SetVisible(DISPLAY:GetBool())
	end, 'DDayNight_Menu')

	sunstatus:SetVisible(DISPLAY:GetBool())
end)

if IsValid(g_ContextMenu) then
	CreateContextMenu()
end