local PANEL = {}

function PANEL:Init()
	self:SetSize(510, 600)
	self:Center()
	self:MakePopup()
	self:DockPadding(0, 24, 0, 0)
	self:SetTitle("")
	self:ShowCloseButton(false)
	-- New close button
	self.CB = self:Add("DButton")
	self.CB:SetSize(24, 24)
	self.CB:SetPos(486, 0)
	self.CB:SetText("")
	self.CB.DoClick = function()
		self:Close()
	end
	self.CB.Paint = function(this, w, h)
		GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, Color(0, 0, 0, 125))
		self:ShadowedText("r", "Marlett", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	-- Back button
	self.BB = self:Add("DButton")
	self.BB:SetSize(24, 24)
	self.BB:SetPos(462, 0)
	self.BB:SetText("")
	self.BB.DoClick = function()
		self:Close()
		vgui.Create("HNS.Welcome")
	end
	self.BB.Paint = function(this, w, h)
		GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, Color(0, 0, 0, 125))
		self:ShadowedText("3", "Marlett", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.SP = self:Add("DScrollPanel")
	self.SP:Dock(FILL)
	self.SP.VBar:SetHideButtons(true)
	self.SP.VBar.Paint = function() end
	self.SP.VBar.btnGrip.Paint = function(this, w, h)
		surface.SetDrawColor(self:GetTint())
		surface.DrawRect(0, 0, w, h)
	end

	local i = 1
	local count = table.Count(GAMEMODE.Achievements)
	for id, ach in pairs(GAMEMODE.Achievements) do
		local panel = self.SP:Add("DPanel")
		panel:Dock(TOP)
		panel:SetTall(ach.Goal && 80 ||50)

		if ach.Goal then
			panel.Done = (GAMEMODE.AchievementsProgress[id] || 0) >= ach.Goal
		else
			panel.Done = GAMEMODE.AchievementsProgress[id]
		end

		panel.BG = i % 2 + 1 == 1
		panel.Line = i < count
		panel.Paint = function(this, w, h)
			-- BG
			surface.SetDrawColor(self:GetTheme(this.BG && 2 || 1))
			surface.DrawRect(0, 0, w, h)
			if this.Done then
				surface.SetDrawColor(0, 175, 100)
				surface.DrawRect(0, 0, w, h)
			end
			-- Texts
			self:ShadowedText(ach.Name:upper(), "HNS.RobotoSmall", 8, 7, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			self:ShadowedText(ach.Desc, "HNS.RobotoThin", 8, 25, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			-- Bars
			if ach.Goal then
				surface.SetDrawColor(self:GetTheme(this.BG && 1 || 2))
				surface.DrawRect(8, 48, w - 16, 24)
				surface.SetDrawColor(self:GetTint())
				surface.DrawRect(8, 48, self:Map(GAMEMODE.AchievementsProgress[id] || 0, 0, ach.Goal, 0, w - 16), 24)
				GAMEMODE.DUtils.Outline(8, 48, w - 16, 24, 2, self:GetTheme(3))
				self:ShadowedText((GAMEMODE.AchievementsProgress[id] || 0) .. "/" .. ach.Goal, "HNS.RobotoSmall", w / 2, 60, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if this.Line then
				surface.SetDrawColor(self:GetTheme(3))
				surface.DrawLine(0, h - 1, w, h - 1)
			end
		end

		i = i + 1
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self:GetTheme(1))
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(self:GetTint())
	surface.DrawRect(0, 0, w, 24)
	self:ShadowedText("ACHIEVEMENTS", "HNS.RobotoSmall", 8, 12, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
	Color(175, 175, 175), -- Header
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

function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 200), alignx, aligny)
	draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

-- https://stackoverflow.com/questions/929103/convert-a-number-range-to-another-range-maintaining-ratio
function PANEL:Map(value, oldMin, oldMax, newMin, newMax)
	return (((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin
end

vgui.Register("HNS.Achievements", PANEL, "DFrame")
vgui.Create("HNS.Achievements")