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