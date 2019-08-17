include("sh_init.lua")

-- Create local cvars for customization
--[[ HUD ]] CreateClientConVar("has_hud", 1, true, false)
--[[ Hider Color ]] CreateClientConVar("has_hidercolor", "Default", true, true)
--[[ Seeker Color ]] CreateClientConVar("has_seekercolor", "Default", true, true)
--[[ Gender ]] CreateClientConVar("has_gender", 0, true, true)


function GM:HUDPaint()
	draw.SimpleTextOutlined("ROUND TIME: " .. (timer.TimeLeft("HNS.RoundTimer") || 0), "DermaLarge", 40, ScrH() - 225, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	draw.SimpleTextOutlined("ROUND COUNT: " .. self.RoundCount, "DermaLarge", 40, ScrH() - 200, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	draw.SimpleTextOutlined("ROUND STATE: " .. self.RoundState, "DermaLarge", 40, ScrH() - 175, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	draw.SimpleTextOutlined("SEEKER BLIND: " .. ((timer.TimeLeft("HNS.RoundTimer") || 0) > GetConVar("has_timelimit"):GetInt() && "true" || "false"), "DermaLarge", 40, ScrH() - 150, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
end