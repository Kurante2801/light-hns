include("sh_init.lua")
AddCSLuaFile("sh_init.lua")

AddCSLuaFile("cl_init.lua")

include("sv_player.lua")

util.AddNetworkString("HNS.Say")
util.AddNetworkString("HNS.PlaySound")

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