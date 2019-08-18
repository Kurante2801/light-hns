-- Create local cvars for customization
GM.CVars = GM.CVars || {}
GM.CVars.HUD = CreateClientConVar("has_hud", 1, true, false)
GM.CVars.HiderColor = CreateClientConVar("has_hidercolor", "Default", true, true)
GM.CVars.SeekerColor = CreateClientConVar("has_seekercolor", "Default", true, true)
GM.CVars.Gender = CreateClientConVar("has_gender", 0, true, true)
GM.CVars.ShowID = CreateClientConVar("has_showid", 1, true, false)
GM.CVars.CrosshairEnable = CreateClientConVar("has_crosshair_enable", "0", true, false)
GM.CVars.CrosshairColor = CreateClientConVar("has_crosshair_color", "55 215 75 225", true, false)
GM.CVars.CrosshairSize = CreateClientConVar("has_crosshair_size", 8, true, false)
GM.CVars.CrosshairGap = CreateClientConVar("has_crosshair_gap", 6, true, false)
GM.CVars.CrosshairThick = CreateClientConVar("has_crosshair_thick", 4, true, false)

-- Includes
include("sh_init.lua")
include("cl_fonts.lua")
include("cl_hud.lua")

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