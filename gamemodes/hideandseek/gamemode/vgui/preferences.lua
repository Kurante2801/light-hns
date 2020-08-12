local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 400)
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
	local texts = { "INTERFACE", "PLAYER MODEL", "CROSSHAIR", "SERVER CVARS" }
	local tabs = { "HNS.PreferencesHUD", "DPanel", "DPanel", "DPanel" }
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
		button.Panel.GetTheme = self.GetTheme
		button.Panel.GetTint = self.GetTint

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

vgui.Register("HNS.Preferences", PANEL, "DFrame")
timer.Simple(0.1, function()
	vgui.Create("HNS.Preferences", PANEL, "DFrame")
end)

-- HUD settings panel
PANEL = {}

function PANEL:Init()
	self:DockPadding(0, 6, 0, 6)
	-- Container
	self.SP = self:Add("DScrollPanel")
	self.SP:Dock(FILL)
	-- HUD selection
	self.HUD = self.SP:Add("DPanel")
	self.HUD:Dock(TOP)
	self.HUD:SetTall(22)
	self.HUD.Paint = function(this, w, h)
		-- Text
		draw.SimpleText("HUD SELECTION", "HNS.RobotoSmall", 9, 1, Color(0, 0, 0, 125), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("HUD SELECTION", "HNS.RobotoSmall", 8, 0, self:GetTint(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		-- Selected name
		local hud = GAMEMODE.HUDs[GAMEMODE.CVars.HUD:GetInt()]
		if hud then
			draw.SimpleText(hud.Name:upper(), "HNS.RobotoSmall", w - 116, 1, Color(0, 0, 0, 125), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(hud.Name:upper(), "HNS.RobotoSmall", w - 116, 0, self:GetTint(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end
	-- Slider
	self.HUD.Selector = self.HUD:Add("DNumSlider")
	self.HUD.Selector:Dock(FILL)
	self.HUD.Selector:DockMargin(124, 0, 124, 0)
	-- Disable all elements besides the slider
	self.HUD.Selector.Label:Hide()
	self.HUD.Selector.TextArea:Hide()
	-- Make slider fancier
	self.HUD.Selector.Slider.Paint = function(this, w, h)
		surface.SetDrawColor(self:GetTheme(3))
		surface.DrawLine(7, h / 2, w - 7, h / 2)

		local space = (w - 16) / (self.HUD.Selector:GetMax() - 1)
		-- Lines
		for i = 0, self.HUD.Selector:GetMax() do
			surface.DrawRect(8 + space * i, h / 2 + 2, 1, 4)
		end
	end
	-- Values
	self.HUD.Selector:SetMinMax(1, #GAMEMODE.HUDs)
	self.HUD.Selector:SetValue(GAMEMODE.CVars.HUD:GetInt())
	self.HUD.Selector:SetDecimals(0)
	self.HUD.Selector.OnValueChanged = function(this, value)
		value = math.Round(value)
		this:SetValue(value)
		-- Update HUD and text
		GAMEMODE.CVars.HUD:SetInt(value)
	end
end

function PANEL:Paint(w, h)
end

vgui.Register("HNS.PreferencesHUD", PANEL, "DPanel")