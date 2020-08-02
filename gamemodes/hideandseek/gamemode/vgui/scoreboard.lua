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
		draw.SimpleTextOutlined(GAMEMODE.CVars.ScoreboardText:GetString(), "HNSHUD.VerdanaLarge", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
		surface.SetDrawColor(150, 150, 150, 255)
		surface.DrawLine(w - 1, 0, w - 1, h)
	end
	self.BigButton.DoClick = function()
		gui.OpenURL(GAMEMODE.CVars.ScoreboardURL:GetString())
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
	draw.SimpleTextOutlined("We are playing on", "HNSHUD.TahomaSmall", (w + 110 * scale) / 2, 11 * scale, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	draw.SimpleTextOutlined(game.GetMap(), "HNSHUD.VerdanaMedium", (w + 110 * scale) / 2, 19 * scale, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
end

-- Resize when HUD scale is changed
function PANEL:UpdateDimentions()
	local scale = GAMEMODE.CVars.HUDScale:GetInt()
	-- Makes the width smaller than ScrW at all times
	self:SetSize(math.min(scale * 275, ScrW() - 50), ScrH() - 100)
	self:Center()
	-- Github/server button
	self.BigButton:SetSize(110 * scale, 32 * scale)

end

vgui.Register("HNS.Scoreboard", PANEL, "DFrame")