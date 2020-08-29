local PANEL = {}

function PANEL:Init()
	self:SetSize(306, 178)
	self:Center()
	self:MakePopup()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:DockPadding(0, 0, 0, 0)
	self:SetDraggable(false)
	-- New close button
	self.CB = self:Add("DButton")
	self.CB:SetSize(24, 24)
	self.CB:SetPos(282, 0)
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
	self.BB:SetPos(258, 0)
	self.BB:SetText("")
	self.BB.DoClick = function()
		self:Close()
		vgui.Create("HNS.Welcome")
	end
	self.BB.Paint = function(this, w, h)
		GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, Color(0, 0, 0, 125))
		self:ShadowedText("3", "Marlett", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	-- Buttons
	self.Play = self:Add("DButton")
	self.Play:SetPos(2, 26)
	self.Play:SetSize(150, 150)
	self.Play:SetText("")
	self.Play.Paint = function(this, w, h)
		GAMEMODE.DUtils.Outline(0, 0, w, h, 4, Color(220, 20, 60))
		this:HoverAnim(w, h)
		self:ShadowedText("PLAY!", "HNS.RobotoLarge", w / 2, h / 2, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.Play.DoClick = function()
		net.Start("HNS.JoinPlaying")
		net.SendToServer()
		self:Close()
	end

	self.Spec = self:Add("DButton")
	self.Spec:SetPos(154, 26)
	self.Spec:SetSize(150, 150)
	self.Spec:SetText("")
	self.Spec.Paint = function(this, w, h)
		GAMEMODE.DUtils.Outline(0, 0, w, h, 4, Color(0, 175, 100))
		this:HoverAnim(w, h)
		self:ShadowedText("SPECTATE", "HNS.RobotoLarge", w / 2, h / 2, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.Spec.DoClick = function()
		net.Start("HNS.JoinSpectating")
		net.SendToServer()
		self:Close()
	end

	-- Random animations
	local anim = math.random(#self.RandomAnimLeft)
	self.Play.HoverAnim = self.RandomAnimLeft[anim]
	self.Spec.HoverAnim = self.RandomAnimRight[anim]
end

function PANEL:Paint(w, h)
	Derma_DrawBackgroundBlur(self)
	surface.SetDrawColor(self:GetTheme(1))
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(self:GetTint())
	surface.DrawRect(0, 0, w, 24)
	self:ShadowedText("TEAM SELECTION", "HNS.RobotoSmall", 8, 12, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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

function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 200), alignx, aligny)
	draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

PANEL.RandomAnimLeft = {
	function(this, w, h)
		surface.DrawRect(0, 0, GAMEMODE.DUtils.LerpNumber(this, 1, 0, w), h, 8)
	end,
	function(this, w, h)
		surface.DrawRect(GAMEMODE.DUtils.LerpNumber(this, 1, w, 0), 0, w, h, 8)
	end,
	function(this, w, h)
		surface.DrawRect(0, 0, w, GAMEMODE.DUtils.LerpNumber(this, 1, 0, h), 8)
	end,
	function(this, w, h)
		surface.DrawRect(0, GAMEMODE.DUtils.LerpNumber(this, 1, h, 0), w, h, 8)
	end,
	function(this, w, h)
		surface.DrawRect(0, 0, GAMEMODE.DUtils.LerpNumber(this, 1, 0, w / 2 + 1), h, 8)
		surface.DrawRect(GAMEMODE.DUtils.LerpNumber(this, 2, w, w / 2), 0, w, h, 8)
		surface.DrawRect(0, 0, w, GAMEMODE.DUtils.LerpNumber(this, 3, 0, h / 2), 8)
		surface.DrawRect(0, GAMEMODE.DUtils.LerpNumber(this, 4, h, h / 2), w, h, 8)
	end,
}

PANEL.RandomAnimRight = {
	function(this, w, h)
		surface.DrawRect(GAMEMODE.DUtils.LerpNumber(this, 1, w, 0), 0, w, h, 8)
	end,
	function(this, w, h)
		surface.DrawRect(0, 0, GAMEMODE.DUtils.LerpNumber(this, 1, 0, w), h, 8)
	end,
	function(this, w, h)
		surface.DrawRect(0, GAMEMODE.DUtils.LerpNumber(this, 1, h, 0), w, h, 8)
	end,
	function(this, w, h)
		surface.DrawRect(0, 0, w, GAMEMODE.DUtils.LerpNumber(this, 1, 0, h), 8)
	end,
	function(this, w, h)
		surface.DrawRect(0, 0, GAMEMODE.DUtils.LerpNumber(this, 1, 0, w / 2 + 1), h, 8)
		surface.DrawRect(GAMEMODE.DUtils.LerpNumber(this, 2, w, w / 2), 0, w, h, 8)
		surface.DrawRect(0, 0, w, GAMEMODE.DUtils.LerpNumber(this, 3, 0, h / 2), 8)
		surface.DrawRect(0, GAMEMODE.DUtils.LerpNumber(this, 4, h, h / 2), w, h, 8)
	end,
}

vgui.Register("HNS.TeamSelection", PANEL, "DFrame")