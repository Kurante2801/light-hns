include("sh_init.lua")

-- Create local cvars for customization
--[[ HUD ]] CreateClientConVar("has_hud", 1, true, false)
--[[ Hider Color ]] CreateClientConVar("has_hidercolor", "Default", true, true)
--[[ Seeker Color ]] CreateClientConVar("has_seekercolor", "Default", true, true)
--[[ Gender ]] CreateClientConVar("has_gender", 0, true, true)

-- Receive a chat message from gamemode
net.Receive("HNS.Say", function()
	local sayTable = net.ReadTable()
	chat.AddText(unpack(sayTable))
end)
-- Play sounds
net.Receive("HNS.PlaySound", function()
	local path = net.ReadString()
	surface.PlaySound(path)
end)

local enums = {"ROUND_WAIT", "ROUND_ACTIVE", "ROUND_POST"}

function GM:HUDPaint()
	draw.SimpleTextOutlined("ROUND TIME: " .. math.Round(timer.TimeLeft("HNS.RoundTimer") || 0, 1), "DermaLarge", ScrW() / 2, ScrH() - 225, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	draw.SimpleTextOutlined("ROUND COUNT: " .. self.RoundCount, "DermaLarge", ScrW() / 2, ScrH() - 200, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	draw.SimpleTextOutlined("ROUND STATE: " .. enums[self.RoundState], "DermaLarge", ScrW() / 2, ScrH() - 175, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	draw.SimpleTextOutlined("SEEKER BLIND: " .. ((timer.TimeLeft("HNS.RoundTimer") || 0) > GetConVar("has_timelimit"):GetInt() && "true" || "false"), "DermaLarge", ScrW() / 2, ScrH() - 150, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
end