-- Shared utils
GM.DUtils = {}

GM.DUtils.FadeHover = function(panel, id, x, y, w, h, color, speed, func)
	color = color || Color(255, 255, 255)

	surface.SetDrawColor(ColorAlpha(color, GAMEMODE.DUtils.LerpNumber(panel, id, 0, color.a, speed, func)))
	surface.DrawRect(x, y, w, h)
end

GM.DUtils.LerpNumber = function(panel, id, value1, value2, speed, func)
	-- Lerps don't exist yet
	if !panel.Lerps then
		panel.Lerps = {}
	end
	-- ID lerp doesn't exist
	if !panel.Lerps[id] then
		panel.Lerps[id] = value1
	end

	speed = speed || 6
	func = func || function(s) return s:IsHovered() end

	panel.Lerps[id] = Lerp(FrameTime() * speed, panel.Lerps[id], func(panel) && value2 || value1)
	return panel.Lerps[id]
end

GM.DUtils.Outline = function(x, y, w, h, thick, color)
	surface.SetDrawColor(color)
	for i = 0, thick - 1 do
		surface.DrawOutlinedRect(x + i, y + i, w - 2 * i, h - 2 * i)
	end
end

-- Achievements
local PANEL = {}

function PANEL:Init()
	self:SetSize(400, 600)
	self:Center()
	self:MakePopup()
	self:DockPadding(0, 24, 0, 0)
	self:SetTitle("HNS | Achievements")
	-- Scroll panel
	self.SP = self:Add("DScrollPanel")
	self.SP:Dock(FILL)
	-- For each achievement, add a panel
	for id, ach in pairs(GAMEMODE.Achievements) do
		local panel = self.SP:Add("DPanel")
		panel:Dock(TOP)
		panel:SetTall(ach.Goal && 70 || 46)

		if ach.Goal then
			panel.Done = (GAMEMODE.AchievementsProgress[id] || 0) >= ach.Goal
		else
			panel.Done = GAMEMODE.AchievementsProgress[id]
		end

		panel.Paint = function(this, w, h)
			-- BG
			if this.Done then
				draw.RoundedBox(0, 0, 0, w, h, Color(75, 150, 225, 75))
			end

			-- Progress
			if ach.Goal then
				draw.RoundedBox(0, 6, 44, w - 12, 19, COLOR_WHITE)
				draw.RoundedBox(0, 7, 45, w - 14, 17, Color(0, 0, 0))
				draw.RoundedBox(0, 7, 45, (w * (GAMEMODE.AchievementsProgress[id] || 0) / ach.Goal) - 14, 17, Color(220, 20, 60))

				draw.SimpleText((GAMEMODE.AchievementsProgress[id] || 0) .. "/" .. ach.Goal, "HNS.RobotoSmall", w / 2, 53, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			draw.SimpleText(ach.Name, "HNS.RobotoMedium", 5, 14, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(ach.Name, "HNS.RobotoMedium", 6, 15, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(ach.Desc, "DermaDefault", 6, 30, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(ach.Desc, "DermaDefault", 7, 31, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(255, 255, 255) surface.DrawLine(0, h - 1, w, h - 1)
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(25, 25, 25))
	draw.RoundedBox(0, 0, 0, w, 24, Color(50, 50, 50))
end

vgui.Register("HNS.Achievements", PANEL, "DFrame")