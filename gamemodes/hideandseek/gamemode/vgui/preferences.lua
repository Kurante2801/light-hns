local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 300)
	self:Center()
	self:MakePopup()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:DockPadding(0, 24, 0, 0)
	-- New close button
	self.CB = self:Add("DButton")
	self.CB:SetSize(24, 24)
	self.CB:SetPos(476, 0)
	self.CB:SetText("")
	self.CB.DoClick = function()
		self:Close()
	end
	self.CB.Paint = function(this, w, h)
		GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, Color(0, 0, 0, 125))
		draw.SimpleText("r", "Marlett", w / 2 + 1, h / 2 + 1, Color(0, 0, 0, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("r", "Marlett", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	-- "Tabs" bar
	self.TabsP = self:Add("DPanel")
	self.TabsP:Dock(TOP)
	self.TabsP.Paint = function() end

	self.Buttons = {}

	-- Buttons to toggle panels
	local texts = { "INTERFACE", "PLAYER MODEL", "CROSSHAIR", "PLACEHOLDER" }
	local tabs = { "HNS.PreferencesHUD", "HNS.PreferencesPM", "HNS.PreferencesCrosshair", "DPanel" }
	-- Create panel
	for i, text in ipairs(texts) do
		local button = self.TabsP:Add("DButton")
		button:Dock(LEFT)
		button:SetWide(125)
		button:SetText("")
		-- Panel that the button will show
		button.Panel = self:Add(tabs[i])
		button.Panel:Dock(FILL)
		button.Panel:Hide()
		-- Funcs
		button.Paint = function(this, w, h)
			surface.SetDrawColor(self:GetTheme(2))
			surface.DrawRect(0, 0, w, h)
			GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, self:GetTint(), 6, function(s) return s.Active end)

			draw.SimpleText(text, "HNS.RobotoSmall", w / 2 + 1, h / 2 + 1, Color(0, 0, 0, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(text, "HNS.RobotoSmall", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		button.DoClick = function(this)
			-- Hide other panels
			for _, v in ipairs(self.Buttons) do
				if v == this then
					v.Active = true
					v.Panel:Show()
				else
					v.Active = false
					v.Panel:Hide()
				end
			end
		end

		button.GetTheme = self.GetTheme
		button.GetTint = self.GetTint
		button.ShadowedText = self.ShadowedText
		button.Panel.GetTheme = self.GetTheme
		button.Panel.GetTint = self.GetTint
		button.Panel.ShadowedText = self.ShadowedText

		table.insert(self.Buttons, button)

		-- Show first panel
		if i == 1 then
			button:DoClick()
		end
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self:GetTheme(1))
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(self:GetTint())
	surface.DrawRect(0, 0, w, 24)
	draw.SimpleText("LHNS - PLAYER PREFERENCES", "HNS.RobotoSmall", 9, 13, Color(0, 0, 0, 175), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("LHNS - PLAYER PREFERENCES", "HNS.RobotoSmall", 8, 12, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- Should return HiderColor, SeekerColor or Specator color
function PANEL:GetTint()
	if LocalPlayer():Team() == TEAM_HIDE then
		return GAMEMODE:GetTeamShade(TEAM_HIDE, GAMEMODE.CVars.HiderColor:GetString())
	elseif LocalPlayer():Team() == TEAM_SEEK then
		return GAMEMODE:GetTeamShade(TEAM_SEEK, GAMEMODE.CVars.SeekerColor:GetString())
	else
		return team.GetColor(LocalPlayer():Team())
	end
end

-- Differences between themes
local light = {
	Color(255, 255, 255), -- BG
	Color(125, 125, 125), -- Header
	Color(0, 0, 0), -- Text
}

local dark = {
	Color(25, 25, 25), -- BG
	Color(50, 50, 50), -- Header
	Color(255, 255, 255), -- Text
}

function PANEL:GetTheme(i)
	if GAMEMODE.CVars.DarkTheme:GetBool() then
		return dark[i] || Color(0, 0, 0)
	else
		return light[i] || Color(255, 255, 255)
	end
end

-- Should clear a lot of code
function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 125), alignx, aligny)
	draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

vgui.Register("HNS.Preferences", PANEL, "DFrame")

-- HUD settings panel
PANEL = {}

function PANEL:Init()
	self:DockPadding(0, 10, 0, 6)
	-- Container
	self.SP = self:Add("DScrollPanel")
	self.SP:Dock(FILL)
	-- HUD selection
	self.HUD = self:AddSlider(124, 124)
	self.HUD.Paint = function(this, w, h)
		-- Text
		self:ShadowedText("HUD SELECTION", "HNS.RobotoSmall", 64, 0, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		-- Selected name
		local hud = GAMEMODE.HUDs[GAMEMODE.CVars.HUD:GetInt()]
		if hud then
			self:ShadowedText(hud.Name:upper(), "HNS.RobotoSmall", w - 116, 0, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end
	-- Values
	self.HUD.Slider:SetMinMax(1, #GAMEMODE.HUDs)
	self.HUD.Slider:SetValue(GAMEMODE.CVars.HUD:GetInt())
	self.HUD.Slider:SetDecimals(0)
	self.HUD.Slider.OnValueChanged = function(this, value)
		value = math.Round(value)
		this:SetValue(value)
		-- Update HUD and text
		GAMEMODE.CVars.HUD:SetInt(value)
	end

	-- HUD Scaling
	self.Scale = self:AddSlider(124, 124)
	self.Scale.Paint = function(this, w, h)
		-- Text
		self:ShadowedText("HUD SCALING", "HNS.RobotoSmall", 64, 0, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		local scale = GAMEMODE.CVars.HUDScale:GetInt()

		-- Scaling
		if scale == 2 then
			self:ShadowedText("2 (DEFAULT)", "HNS.RobotoSmall", w - 116, 0, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		else
			self:ShadowedText(scale, "HNS.RobotoSmall", w - 116, 0, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end
	-- Values
	self.Scale.Slider:SetMinMax(1, 6)
	self.Scale.Slider:SetValue(GAMEMODE.CVars.HUDScale:GetInt())
	self.Scale.Slider:SetDecimals(0)
	self.Scale.Slider.OnValueChanged = function(this, value)
		value = math.Round(value)
		this:SetValue(value)
		-- Update HUD and text
		GAMEMODE.CVars.HUDScale:SetInt(value)
	end

	-- Checkboxs
	self:AddCheckbox("ENABLE DARK THEME", "has_darktheme", 124)
	self:AddCheckbox("SHOW OTHER PLAYERS' STEAM ID", "has_showid", 124)
	self:AddCheckbox("PUT YOURSELF AT THE TOP OF THE SCOREBOARD (TODO)", "has_scob_ontop", 124)
	-- Speed and its wangs
	self.Speed = self:AddCheckbox("SHOW MOVEMENT SPEED (X Y):", "has_showspeed", 124)
	-- Panel that prevents button click
	self.Speed.Panel = self.Speed:Add("DPanel")
	self.Speed.Panel:Dock(FILL)
	self.Speed.Panel:DockMargin(290, 0, 0, 0)
	self.Speed.Panel.Paint = function() end
	-- Wangs
	self.Speed.SpeedX = self.Speed.Panel:Add("DNumberWang")
	self.Speed.SpeedX:SetPos(0, 1)
	self.Speed.SpeedX:SetSize(50, 22)
	self.Speed.SpeedX:SetMinMax(45, ScrW() - 45)
	self.Speed.SpeedX:SetValue(GAMEMODE.CVars.SpeedX:GetInt())
	self.Speed.SpeedX:SetConVar("has_speedx")

	self.Speed.SpeedY = self.Speed.Panel:Add("DNumberWang")
	self.Speed.SpeedY:SetPos(54, 1)
	self.Speed.SpeedY:SetSize(50, 22)
	self.Speed.SpeedY:SetMinMax(30, ScrH() - 30)
	self.Speed.SpeedY:SetValue(GAMEMODE.CVars.SpeedY:GetInt())
	self.Speed.SpeedY:SetConVar("has_speedy")

	-- Center button
	self.Speed.SpeedC = self.Speed.Panel:Add("DButton")
	self.Speed.SpeedC:SetPos(108, 1)
	self.Speed.SpeedC:SetSize(50, 22)
	self.Speed.SpeedC:SetText("Center")
	self.Speed.SpeedC.DoClick = function()
		self.Speed.SpeedX:SetValue(ScrW() / 2)
		self.Speed.SpeedY:SetValue(ScrH() / 2)
	end
	-- Enable/Disable
	self.Speed.SpeedX:SetEnabled(GAMEMODE.CVars.ShowSpeed:GetBool())
	self.Speed.SpeedY:SetEnabled(GAMEMODE.CVars.ShowSpeed:GetBool())
	self.Speed.SpeedC:SetEnabled(GAMEMODE.CVars.ShowSpeed:GetBool())
	self.Speed.OnChangeAdditional = function(this, value)
		self.Speed.SpeedX:SetEnabled(value)
		self.Speed.SpeedY:SetEnabled(value)
		self.Speed.SpeedC:SetEnabled(value)
	end

	-- Add your own settings in this hook
	hook.Run("HASPreferencesMenu", self.SP)
end

function PANEL:AddSlider(offsetx, offsety)
	local panel = self.SP:Add("DPanel")
	panel:Dock(TOP)
	panel:DockMargin(0, 0, 0, 6)
	-- Slider
	panel.Slider = panel:Add("DNumSlider")
	panel.Slider:Dock(FILL)
	panel.Slider:DockMargin(offsetx, 0, offsety, 0)
	-- Disable all elements besides the slider
	panel.Slider.Label:Hide()
	panel.Slider.TextArea:Hide()
	-- Make slider fancier
	panel.Slider.Paint = function(this, w, h)
		surface.SetDrawColor(self:GetTint())
		surface.DrawLine(7, h / 2, w - 7, h / 2)

		local space = (w - 16) / (panel.Slider:GetMax() - 1)
		-- Lines
		for i = 0, panel.Slider:GetMax() do
			surface.DrawRect(8 + space * i, h / 2 + 2, 1, 4)
		end
	end
	panel.OnChangeAdditional = function() end

	return panel
end

function PANEL:AddCheckbox(text, cvar, offsetx)
	local panel = self.SP:Add("DButton")
	panel:Dock(TOP)
	panel:SetTall(24)
	panel:SetText("")
	panel:DockMargin(0, 0, 0, 6)
	-- Cache cvar
	panel.CVar = GetConVar(cvar)
	-- Funcs
	panel.Paint = function(this, w, h)
		self:ShadowedText(text, "HNS.RobotoSmall", 64, h / 2 + 1, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		GAMEMODE.DUtils.Outline(24, 0, 24, 24, 2, self:GetTint())
		GAMEMODE.DUtils.FadeHover(this, 1, 28, 4, 16, h - 8, self:GetTint(), 6, function(s) return s.CVar:GetBool() end)
	end
	panel.DoClick = function(this)
		this.CVar:SetBool(!this.CVar:GetBool())
		this.OnChangeAdditional(this, this.CVar:GetBool())
	end
	panel.OnChangeAdditional = function() end

	return panel
end

function PANEL:Paint() end

vgui.Register("HNS.PreferencesHUD", PANEL, "DPanel")

-- Player color and model gender settings
PANEL = {}

function PANEL:Init()
	-- Scroll panel
	self:DockPadding(2, 8, 0, 0)
	-- Color pickers
	self.Lines = {}

	for i = 1, 4 do
		local line = self:Add("DPanel")
		table.insert(self.Lines, line)
		line:Dock(TOP)
		line:DockPadding(120, 0, 0, 0)
		line:DockMargin(0, 0, 0, 2)
		line:SetTall(35)
		line.Paint = function(this, w, h)
			if this.Text then
				self:ShadowedText(this.Text, "HNS.RobotoSmall", 60, h / 2, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				self:ShadowedText(this.CVar:GetString():upper(), "HNS.RobotoSmall", 60, h / 2, GAMEMODE:GetTeamShade(this.Team, this.CVar:GetString()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
		-- Displayed text
		if i == 1 then
			line.Text = "HIDER COLOR"
		elseif i == 2 then
			line.CVar = GAMEMODE.CVars.HiderColor
			line.Team = TEAM_HIDE
		elseif i == 3 then
			line.Text = "SEEKER COLOR"
		else
			line.CVar = GAMEMODE.CVars.SeekerColor
			line.Team = TEAM_SEEK
		end
	end

	-- Insert colors
	local i = 0

	for name, color in pairs(GAMEMODE.HiderColors) do
		local button = self:AddButton(name, color)
		button:SetParent(self.Lines[i % 2 + 1])
		button.CVar = GAMEMODE.CVars.HiderColor
		i = i + 1
	end

	i = 0
	for name, color in pairs(GAMEMODE.SeekerColors) do
		local button = self:AddButton(name, color)
		button:SetParent(self.Lines[i % 2 + 3])
		button.CVar = GAMEMODE.CVars.SeekerColor
		i = i + 1
	end
	-- Separate hider colors from seeker colors
	self.Lines[2]:DockMargin(0, 0, 0, 8)

	-- Model (No docking here)
	self.Stand = self:Add("DPanel")
	self.Stand:SetPos(340, 0)
	self.Stand:SetSize(160, 252)
	self.Stand.Paint = function(this, w, h)
		surface.SetDrawColor(self:GetTheme(2))
		surface.DrawRect(0, 0, w, h)
	end

	self.Model = self.Stand:Add("DModelPanel")
	self.Model:Dock(FILL)
	self.Model:SetFOV(50)
	self.Model:SetModel(LocalPlayer():GetModel())
	self.Model.Entity.PlyColor = LocalPlayer():GetPlayerColor() -- Changes with the buttons
	self.Model.Entity.GetPlayerColor = function(this)
		return this.PlyColor
	end

	-- Gender button
	self.Gender = self:Add("DButton")
	self.Gender:SetWide(150)
	self.Gender:SetPos(95, 215)
	self.Gender:SetText("")
	self.Gender.CVar = GAMEMODE.CVars.Gender
	self.Gender.Paint = function(this, w, h)
		GAMEMODE.DUtils.Outline(0, 0, w, h, 2, self:GetTint())
		surface.SetDrawColor(self:GetTint())
		surface.DrawRect(GAMEMODE.DUtils.LerpNumber(this, 1, 0, w / 2, 8, function(s) return this.CVar:GetBool() end), 0, w / 2, h)
		self:ShadowedText("MALE", "HNS.RobotoSmall", w / 4, h / 2, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		self:ShadowedText("FEMALE", "HNS.RobotoSmall", w - w / 4, h / 2, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.Gender.DoClick = function(this)
		this.CVar:SetBool(!this.CVar:GetBool())
	end
end

function PANEL:AddButton(name, color)
	local button = self:Add("DButton")
	button:Dock(LEFT)
	button:DockMargin(0, 0, 2, 0)
	button:SetWide(35)
	button:SetText("")
	button.Name = name
	button.Color = color
	button.Paint = function(this, w, h)
		surface.SetDrawColor(this.Color)
		surface.DrawRect(0, 0, w, h)
	end
	button.DoClick = function(this)
		this.CVar:SetString(this.Name)
		self.Model.Entity.PlyColor = color:ToVector()
	end

	return button
end

function PANEL:Paint(w, h)
	self:ShadowedText("PLAYERMODEL GENDER", "HNS.RobotoSmall", (w - 160) / 2, 180, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self:ShadowedText("(NEXT SPAWN, AFFECTS TAUNTS TOO)", "HNS.RobotoSmall", (w - 160) / 2, 200, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("HNS.PreferencesPM", PANEL, "DPanel")

-- Crosshair section
PANEL = {}

function PANEL:Init()
	self.CR = {}
	-- Enabled
	self.Button = self:Add("DButton")
	self.Button:SetPos(0, 12)
	self.Button:SetSize(300, 24)
	self.Button:SetText("")
	-- Cache cvar
	self.Button.CVar = GAMEMODE.CVars.CrosshairEnable
	-- Funcs
	self.Button.Paint = function(this, w, h)
		self:ShadowedText("ENABLE CUSTOM CROSSHAIR", "HNS.RobotoSmall", 48, h / 2 + 1, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		GAMEMODE.DUtils.Outline(16, 0, 24, 24, 2, self:GetTint())
		GAMEMODE.DUtils.FadeHover(this, 1, 20, 4, 16, h - 8, self:GetTint(), 6, function(s) return s.CVar:GetBool() end)
	end
	self.Button.DoClick = function(this)
		this.CVar:SetBool(!this.CVar:GetBool())
	end
	-- Color stuff
	self.Mixer = self:Add("DColorMixer")
	self.Mixer:SetPalette(false)
	self.Mixer:SetPos(14, 42)
	self.Mixer:SetSize(314, 200)
	self.Mixer:SetConVarA("has_crosshair_a")
	self.Mixer:SetConVarR("has_crosshair_r")
	self.Mixer:SetConVarG("has_crosshair_g")
	self.Mixer:SetConVarB("has_crosshair_b")
	-- Crosshair dimentions
	for i = 0, 2 do
		local wang = self:Add("DNumberWang")
		wang:SetPos(432, 42 + 24 * i)
		wang:SetWide(50)
		wang:SetMinMax(0, 20)

		if i == 0 then
			wang:SetValue(GAMEMODE.CVars.CrosshairSize:GetInt())
			wang:SetConVar("has_crosshair_size")
		elseif i == 1 then
			wang:SetValue(GAMEMODE.CVars.CrosshairGap:GetInt())
			wang:SetConVar("has_crosshair_gap")
		else
			wang:SetValue(GAMEMODE.CVars.CrosshairThick:GetInt())
			wang:SetConVar("has_crosshair_thick")
		end
	end
end

function PANEL:Paint(w, h)
	self:ShadowedText("RED", "HNS.RobotoSmall", 332, 52, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self:ShadowedText("GREEN", "HNS.RobotoSmall", 332, 77, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self:ShadowedText("BLUE", "HNS.RobotoSmall", 332, 101, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self:ShadowedText("ALPHA", "HNS.RobotoSmall", 332, 125, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	self:ShadowedText("SIZE", "HNS.RobotoSmall", 428, 52, self:GetTheme(3), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	self:ShadowedText("GAP", "HNS.RobotoSmall", 428, 77, self:GetTheme(3), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	self:ShadowedText("THICK", "HNS.RobotoSmall", 428, 101, self:GetTheme(3), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	surface.SetDrawColor(125, 125, 125, 255)
	surface.DrawRect(402, 154, 80, 80)

	self.CR.Size = GAMEMODE.CVars.CrosshairSize:GetInt()
	self.CR.Gap = GAMEMODE.CVars.CrosshairGap:GetInt()
	self.CR.Thick = GAMEMODE.CVars.CrosshairThick:GetInt()
	self.CR.Color = Color(GAMEMODE.CVars.CrosshairR:GetInt(), GAMEMODE.CVars.CrosshairG:GetInt(), GAMEMODE.CVars.CrosshairB:GetInt(), GAMEMODE.CVars.CrosshairA:GetInt())
	GAMEMODE:DrawCrosshair(442, 194, self.CR)
end

vgui.Register("HNS.PreferencesCrosshair", PANEL, "DPanel")