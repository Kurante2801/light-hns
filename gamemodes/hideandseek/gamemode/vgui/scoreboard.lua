-- Menu that shows all players when you press TAB
local PANEL = {}

function PANEL:Init()
	self.Blur = Material("pp/blurscreen")

	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	-- GitHub/server button
	self.BigButton = self:Add("DButton")
	self.BigButton:SetText("")
	self.BigButton.Paint = function(this, w, h)
		self:ShadowedText(GAMEMODE.CVars.ScoreboardText:GetString(), "HNSHUD.VerdanaLarge", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		surface.SetDrawColor(150, 150, 150, 255)
		surface.DrawLine(w - 1, 0, w - 1, h)
	end
	self.BigButton.DoClick = function()
		gui.OpenURL(GAMEMODE.CVars.ScoreboardURL:GetString())
	end
	-- Player list
	self.PP = self:Add("DScrollPanel")
	self.PP:Dock(FILL)
	
	self.Players = {}
	-- Adding players
	for i, ply in ipairs(player.GetAll()) do
		local button = self.PP:Add("HNS.ScoreboardPlayer")
		button:SetPlayer(ply)
		button:SetScale(GAMEMODE.CVars.HUDScale:GetInt())
		button.Blur = self.Blur

		self.Players[i] = button
	end
	-- We do this last so everything is sized
	self:UpdateDimentions()
end

function PANEL:Paint(w, h)
	local scale = GAMEMODE.CVars.HUDScale:GetInt()
	local blurx, blury = self:LocalToScreen(0, 0)

	-- Cache blur
	for i = 1, 2 do
		self.Blur:SetFloat("$blur", (i / 4) * 4)
		self.Blur:Recompute()
		render.UpdateScreenEffectTexture()
	end

	-- Top blur
	render.SetScissorRect(blurx, blury, blurx + w, blury + 32 * scale, true)
		surface.SetMaterial(self.Blur)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(-blurx, -blury, ScrW(), ScrH())
	render.SetScissorRect(0, 0, 0, 0, false)

	-- Top bar and outline
	surface.SetDrawColor(0, 0, 0, 125)
	surface.DrawRect(0, 0, w, 32 * scale)
	surface.SetDrawColor(150, 150, 150, 255)
	surface.DrawOutlinedRect(0, 0, w, 32 * scale)

	-- Map name
	self:ShadowedText("We are playing on", "HNSHUD.TahomaSmall", (w + 110 * scale) / 2, 11 * scale, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self:ShadowedText(game.GetMap(), "HNSHUD.VerdanaMedium", (w + 110 * scale) / 2, 19 * scale, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	-- Player list header
	render.SetScissorRect(blurx, blury + 34 * scale, blurx + w, blury + 46 * scale, true)
		surface.SetMaterial(self.Blur)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(-blurx, -blury, ScrW(), ScrH())
	render.SetScissorRect(0, 0, 0, 0, false)

	surface.SetDrawColor(0, 0, 0, 125)
	surface.DrawRect(0, 34 * scale, w, 12 * scale)
	surface.SetDrawColor(150, 150, 150, 255)
	surface.DrawOutlinedRect(0, 34 * scale, w, 12 * scale)

	-- Player count (on the header)
	self:ShadowedText("Hiding", "HNSHUD.CorbelSmall", 2 * scale, 40 * scale, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- Resize when HUD scale is changed
function PANEL:UpdateDimentions()
	local scale = GAMEMODE.CVars.HUDScale:GetInt()
	-- Padding
	self:DockPadding(0, 48 * scale, 0, 0)
	-- Makes the width smaller than ScrW at all times
	self:SetSize(math.min(scale * 275, ScrW() - 50), ScrH() - 100)
	self:Center()
	-- Github/server button
	self.BigButton:SetSize(110 * scale, 32 * scale)
	-- Players
	for _, button in ipairs(self.Players) do
		button:SetScale(scale)
	end
end

function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0), alignx, aligny)
	draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

function PANEL:GetPlayerCount()
	return team.NumPlayers(TEAM_HIDE) + team.NumPlayers(TEAM_SEEK)
end

vgui.Register("HNS.Scoreboard", PANEL, "DFrame")

PANEL = {}

function PANEL:Init()
	self:Dock(TOP)
	self.Avatar = self:Add("AvatarImage")
	self.Scale = 2
end

function PANEL:Paint(w, h)
	-- Prevent lua error when player leaves
	if !self.Player then
		self:Remove()
		return
	end
	-- Blur
	local blurx, blury = self:LocalToScreen(0, 0)
	local scale = self.Scale

	render.SetScissorRect(blurx, blury, blurx + w, blury + h, true)
		surface.SetMaterial(self.Blur)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(-blurx, -blury, ScrW(), ScrH())
	render.SetScissorRect(0, 0, 0, 0, false)

	-- Background and outline
	surface.SetDrawColor(0, 0, 0, 125)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(150, 150, 150, 255)
	surface.DrawOutlinedRect(0, 0, w, h)

	-- PFP fill and outline
	surface.DrawOutlinedRect(4 * scale - 1, 4 * scale - 1, 16 * scale + 2, 16 * scale + 2)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(4 * scale, 4 * scale, 16 * scale, 16 * scale)

	-- Player team and name
	self:ShadowedText(self:GetTeamName(), "HNSHUD.CorbelSmall", 22 * scale, h / 2 - 4 * scale, self:GetTeamColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self:ShadowedText(self.Player:Name(), "HNSHUD.CorbelSmall", 22 * scale, h / 2 + 4 * scale, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:SetPlayer(ply)
	self.Player = ply
end

function PANEL:SetScale(scale)
	if !self.Player then return end

	self.Scale = scale
	self:SetTall(24 * scale)

	self.Avatar:SetPos(4 * scale, 4 * scale)
	self.Avatar:SetSize(16 * scale, 16 * scale)
	self.Avatar:SetPlayer(self.Player, 16 * scale * 2)
end

function PANEL:BackgroundColor()
	if !self.Player then
		return Color(0, 0, 0, 125)
	end
end

-- Returns Playing when localplayer is a hider, returns team otherwise
function PANEL:GetTeamName()
	if self.Player:Team() == TEAM_SPECTATOR then
		return "Spectating"
	elseif LocalPlayer():Team() == TEAM_HIDE then
		return "Playing"
	else
		return team.GetName(self.Player:Team())
	end
end

-- Similar to GetTeamName but with colors
function PANEL:GetTeamColor()
	if self.Player:Team() == TEAM_SPECTATOR then
		return Color(0, 175, 100)
	elseif LocalPlayer():Team() == TEAM_HIDE then
		return Color(215, 215, 215)
	else
		return team.GetColor(self.Player:Team())
	end
end

function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0), alignx, aligny)
	draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

vgui.Register("HNS.ScoreboardPlayer", PANEL, "DButton")