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
		self:ShadowedText("r", "Marlett", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	-- Allow server owners to add their own stuff here
	if !hook.Run("HASWelcomeMenu", self) then
		self.DefaultDescription = true
	end

	-- These buttons will appear regardless of the hook
	self.Play = self:Add("DButton")
	self.Play:SetText("")
	self.Play:SetPos(150, 222)
	self.Play:SetSize(200, 60)
	self.Play.Color = Color(0, 0, 0)
	self.Play.Paint = function(this, w, h)
		this.Sin = math.sin(SysTime())
		-- Alternate between hider and seeker colors
		this.Color = Color(
			self:Map(this.Sin, -1, 1, 75, 215),
			self:Map(this.Sin, -1, 1, 150, 75),
			self:Map(this.Sin, -1, 1, 225, 50)
		)

		GAMEMODE.DUtils.Outline(0, 0, w, h, 2, this.Color)
		GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, this.Color)

		-- Text
		self:ShadowedText("LET'S PLAY!", "HNS.RobotoLarge", w / 2, h / 2, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.Play.DoClick = function()
		self:Close()
		-- Open once
		if !GAMEMODE.TeamSelectionOpenedFromF1 then
			GAMEMODE.TeamSelectionOpenedFromF1 = true
			vgui.Create("HNS.TeamSelection")
		end
	end

	self.Prefs = self:Add("DButton")
	self.Prefs:SetPos(360, 237)
	self.Prefs:SetSize(130, 30)
	self.Prefs:SetText("")
	self.Prefs.Paint = function(this, w, h)
		GAMEMODE.DUtils.Outline(0, 0, w, h, 2, self:GetTint())
		surface.SetDrawColor(self:GetTint())
		surface.DrawRect(GAMEMODE.DUtils.LerpNumber(this, 1, w, 0), 0, w, h, 8)
		self:ShadowedText("PREFERENCES", "HNS.RobotoSmall", w / 2, h / 2, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.Prefs.DoClick = function()
		self:Close()
		vgui.Create("HNS.Preferences")
	end

	self.Achs = self:Add("DButton")
	self.Achs:SetPos(10, 237)
	self.Achs:SetSize(130, 30)
	self.Achs:SetText("")
	self.Achs.Paint = function(this, w, h)
		GAMEMODE.DUtils.Outline(0, 0, w, h, 2, self:GetTint())
		surface.SetDrawColor(self:GetTint())
		surface.DrawRect(GAMEMODE.DUtils.LerpNumber(this, 1, -w, 0), 0, w, h, 8)
		self:ShadowedText("ACHIEVEMENTS", "HNS.RobotoSmall", w / 2, h / 2, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.Achs.DoClick = function()
		self:Close()
		vgui.Create("HNS.Achievements")
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self:GetTheme(1))
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(self:GetTint())
	surface.DrawRect(0, 0, w, 24)
	self:ShadowedText("WELCOME TO LIGHT HIDE AND SEEK", "HNS.RobotoSmall", 8, 12, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	if !self.DefaultDescription then return end

	-- Gameplay explanation
	draw.SimpleText("HOW TO PLAY", "HNS.RobotoSmall", 10, 30, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	self.TeamWide = draw.SimpleText("Hiders ", "HNS.RobotoThin", 10, 48, Color(100, 175, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("must avoid seekers until the round timer ends to win.", "HNS.RobotoThin", self.TeamWide + 10, 48, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	self.TeamWide = draw.SimpleText("Seekers ", "HNS.RobotoThin", 10, 66, Color(235, 100, 75), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("must find and catch all hiders they can to aid their team.", "HNS.RobotoThin", self.TeamWide + 10, 66, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	draw.SimpleText("Hiders will turn into Seekers when caught and the round will also end ", "HNS.RobotoThin", 10, 90, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("when there are no more Hiders standing.", "HNS.RobotoThin", 10, 108, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	-- Default binds
	draw.SimpleText("DEFAULT BINDS", "HNS.RobotoSmall", 10, 136, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("F1 - Open this window. Binded to gm_showhelp", "HNS.RobotoThin", 10, 154, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("F2 - Open team selection. Binded to gm_showteam", "HNS.RobotoThin", 10, 172, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("R - Play a random taunt. Binded to +reload", "HNS.RobotoThin", 10, 190, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

-- https://stackoverflow.com/questions/929103/convert-a-number-range-to-another-range-maintaining-ratio
function PANEL:Map(value, oldMin, oldMax, newMin, newMax)
	return (((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin
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
	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 200), alignx, aligny)
	return draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

vgui.Register("HNS.Welcome", PANEL, "DFrame")