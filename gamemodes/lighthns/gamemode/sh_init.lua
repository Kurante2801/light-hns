DeriveGamemode("base")

GM.Name = "Light Hide and Seek"
GM.Author = "Fafy"
GM.Email = "fafy@gflclan.com"

include("sh_colors.lua")
AddCSLuaFile("sh_colors.lua")

include("sh_roundmanager.lua")
AddCSLuaFile("sh_roundmanager.lua")

-- Shared ConVars
--[[ Max Rounds ]] CreateConVar("has_maxrounds", 5, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Rounds until map change")
--[[ Time Limit ]] CreateConVar("has_timelimit", 270, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time to seek (0 is infinite)")
--[[ Map Damage ]] CreateConVar("has_envdmgallowed", 1, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Will the map hurt players?")
--[[ Blind Time ]] CreateConVar("has_blindtime", 30, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time to hide (seekers are blinded)")
--[[ Dynamic Tagging ]] CreateConVar("has_dyntagging", 1, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Enable dynamic tag ranges?")
--[[ Hiding Reward ]] CreateConVar("has_hidereward", 3, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How many points to award hiders per round won")
--[[ Seeker Tag Reward ]] CreateConVar("has_seekreward", 1, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How many points to award seekers per hider tag")
--[[ Hider Run Speed ]] CreateConVar("has_hiderrunspeed", 320, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Speed at which hiders run at")
--[[ Seeker Run Speed ]] CreateConVar("has_seekerrunspeed", 360, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Speed at which seekers run at")
--[[ Hider Walk Speed ]] CreateConVar("has_hiderwalkspeed", 190, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Speed at which hiders walk at")
--[[ Seeker Walk Speed ]] CreateConVar("has_seekerwalkspeed", 200, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Speed at which seekers walk at")
--[[ Jump Power ]] CreateConVar("has_jumppower", 210, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Force everyone jumps with")

function GM:CreateTeams()
	TEAM_HIDE = 1
	team.SetUp(TEAM_HIDE, "Hiding", Color(75, 150, 225))

	TEAM_SEEK = 2
	team.SetUp(TEAM_SEEK, "Seeking", Color(215, 75, 50))

	-- Just changing spectators colors
	team.SetUp(TEAM_SPECTATOR, "Spectating", Color(0, 175, 100))
end

hook.Add("Tick", "HNS.SeekerBlinded", function()
	-- See if seeker is blinded
	if GAMEMODE.RoundState == ROUND_ACTIVE && GetConVar("has_timelimit"):GetInt() < (timer.TimeLeft("HNS.RoundTimer")) then
		GAMEMODE.SeekerBlinded = true
	else
		GAMEMODE.SeekerBlinded = false
	end
end)

function GM:Move(ply)
	-- Prevent seekers from moving on blind time
	return self.SeekerBlinded && ply:Team() == TEAM_SEEK
end