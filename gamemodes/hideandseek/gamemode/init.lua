include("sh_init.lua")
include("sh_achievements_table.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_achievements_table.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_fonts.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_derma.lua")
AddCSLuaFile("vgui/scoreboard.lua")
AddCSLuaFile("vgui/preferences.lua")
AddCSLuaFile("vgui/welcome.lua")
AddCSLuaFile("vgui/teamselection.lua")
AddCSLuaFile("vgui/achievements.lua")
AddCSLuaFile("tdlib.lua")

include("sv_player.lua")
include("sv_achievements.lua")

util.AddNetworkString("HNS.Say")
util.AddNetworkString("HNS.PlaySound")
util.AddNetworkString("HNS.JoinPlaying")
util.AddNetworkString("HNS.JoinSpectating")
util.AddNetworkString("HNS.PlayerColorUpdate")
util.AddNetworkString("HNS.StaminaChange")
util.AddNetworkString("HNS.AchievementsProgress")
util.AddNetworkString("HNS.AchievementsMaster")
util.AddNetworkString("HNS.AchievementsGet")
util.AddNetworkString("HNS.PlayerEvent")
util.AddNetworkString("HNS.PlayerNetReady")

-- Sends a table to be unpacked on chat.AddText
function GM:SendChat(ply, ...)
	net.Start("HNS.Say")
		net.WriteTable({ ... })
	net.Send(ply)
end
-- Same but to everyone
function GM:BroadcastChat(...)
	net.Start("HNS.Say")
		net.WriteTable({ ... })
	net.Broadcast()
end
-- Plays a sound on the client
function GM:SendSound(ply, path)
	net.Start("HNS.PlaySound")
		net.WriteString(path)
	net.Send(ply)
end
-- Same but to everyone
function GM:BroadcastSound(path)
	net.Start("HNS.PlaySound")
		net.WriteString(path)
	net.Broadcast()
end

function GM:BroadcastEvent(ply, event)
	net.Start("HNS.PlayerEvent")
		net.WriteUInt(event, 3)
		net.WriteEntity(ply)
	net.Broadcast()
end