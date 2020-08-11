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
	local tabs = { "DPanel", "DPanel", "DPanel", "DPanel" }
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
			surface.SetDrawColor(125, 125, 125, 255)
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

		table.insert(self.Buttons, button)

		-- Show first panel
		if i == 1 then
			button:DoClick()
		end
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255)
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

vgui.Register("HNS.Preferences", PANEL, "DFrame")
vgui.Create("HNS.Preferences", PANEL, "DFrame")

-- HUD settings panel
PANEL = {}

vgui.Register("HNS.PreferencesHUD", PANEL, "DPanel")