DeriveGamemode("base")

GM.Name = "Light Hide and Seek"
GM.Author = "Fafy"
GM.Email = "fafy@gflclan.com"

include("sh_colors.lua")
AddCSLuaFile("sh_colors.lua")

include("sh_roundmanager.lua")
AddCSLuaFile("sh_roundmanager.lua")

-- Player events
PLYEVENT_PLAY, PLYEVENT_SPEC, PLYEVENT_AVOID  = 1, 2, 3

-- Shared ConVars
GM.CVars = GM.CVars || {}
GM.CVars.MaxRounds = CreateConVar("has_maxrounds", 5, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Rounds until map change")
GM.CVars.TimeLimit = CreateConVar("has_timelimit", 300, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time to seek (0 is infinite)")
GM.CVars.EnviromentDamageAllowed = CreateConVar("has_envdmgallowed", 1, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Will the map hurt players?")
GM.CVars.BlindTime = CreateConVar("has_blindtime", 30, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time to hide (seekers are blinded)")
GM.CVars.HiderReward = CreateConVar("has_hidereward", 3, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How many points to award hiders per round won")
GM.CVars.SeekerReward = CreateConVar("has_seekreward", 1, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How many points to award seekers per hider tag")
GM.CVars.HiderRunSpeed = CreateConVar("has_hiderrunspeed", 320, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Speed at which hiders run at")
GM.CVars.SeekerRunSpeed = CreateConVar("has_seekerrunspeed", 360, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Speed at which seekers run at")
GM.CVars.HiderWalkSpeed = CreateConVar("has_hiderwalkspeed", 190, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Speed at which hiders walk at")
GM.CVars.SeekerWalkSpeed = CreateConVar("has_seekerwalkspeed", 200, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Speed at which seekers walk at")
GM.CVars.JumpPower = CreateConVar("has_jumppower", 210, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Force everyone jumps with")
GM.CVars.ClickRange = CreateConVar("has_clickrange", 100, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Range at which seekers can click tag")
GM.CVars.ScoreboardText = CreateConVar("has_scob_text", "Light HNS", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Text for the scoreboard (top left button)")
GM.CVars.ScoreboardURL = CreateConVar("has_scob_url", "https://github.com/Fafy2801/light-hns", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Link the scoreboard button will open (top left button too)")
GM.CVars.HiderTrail = CreateConVar("has_lasthidertrail", 1, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Put a trail on the last remaining hider.")
GM.CVars.HiderFlash = CreateConVar("has_hiderflashlight", 0, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Enable hider flashlights (only visible to them).")
GM.CVars.TeamIndicators = CreateConVar("has_teamindicators", 0, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Draw an indicator over teammates heads when they are far away.")
GM.CVars.InfiniteStamina = CreateConVar("has_infinitestamina", 0, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Enable infinite stamina.")
GM.CVars.FirstSeeks = CreateConVar("has_firstcaughtseeks", 0, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "First player caught will seek next round.")

function GM:CreateTeams()
	TEAM_HIDE = 1
	team.SetUp(TEAM_HIDE, "Hiding", Color(75, 150, 225))

	TEAM_SEEK = 2
	team.SetUp(TEAM_SEEK, "Seeking", Color(215, 75, 50))

	-- Just changing spectators colors
	team.SetUp(TEAM_SPECTATOR, "Spectating", Color(0, 175, 100))
end

-- Sound when seekers are unblinded
GM.PlayedStartSound = true

hook.Add("Tick", "HNS.SeekerBlinded", function()
	-- Store time left
	if GAMEMODE.RoundState == ROUND_WAIT then
		GAMEMODE.TimeLeft = GAMEMODE.CVars.TimeLimit:GetInt() + GAMEMODE.CVars.BlindTime:GetInt()
	else
		GAMEMODE.TimeLeft = timer.TimeLeft("HNS.RoundTimer") || 0
		GAMEMODE.TimeLeft = math.abs(math.ceil(GAMEMODE.TimeLeft))
	end
	-- See if seeker is blinded
	if GAMEMODE.RoundState == ROUND_ACTIVE && GAMEMODE.RoundLength < GAMEMODE.TimeLeft then
		GAMEMODE.SeekerBlinded = true
	else
		GAMEMODE.SeekerBlinded = false
	end

	if GAMEMODE.RoundState == ROUND_ACTIVE then
		if !GAMEMODE.PlayedStartSound && !GAMEMODE.SeekerBlinded then
			GAMEMODE.PlayedStartSound = true
			-- Sound
			if SERVER then
				for _, ply in pairs(team.GetPlayers(TEAM_SEEK)) do
					ply:EmitSound("coach/coach_attack_here.wav")
				end
			elseif CLIENT then
				LocalPlayer():EmitSound("coach/coach_attack_here.wav", 90, 100)
			end
		end
	else
		GAMEMODE.PlayedStartSound = false
	end
end)

function GM:Move(ply, data)
	-- Prevent seekers from moving on blind time
	return self.SeekerBlinded && ply:Team() == TEAM_SEEK
end

-- Stamina
function GM:StartCommand(ply, cmd)
	if cmd:KeyDown(IN_SPEED) then
		-- Reduce stamina
		self:StaminaStart(ply)
		-- Prevent sprint
		if ply:GetStamina() <= 0 && ply:Team() != TEAM_SPECTATOR then
			cmd:SetButtons(cmd:GetButtons() - IN_SPEED)
		end
	end
end

function GM:StaminaStart(ply)
	local i = ply:EntIndex()

	-- Caching strings
	local stadrain = "HNS.StaminaDrain" .. i
	local staregen = "HNS.StaminaRegen" .. i
	local stadelay = "HNS.StaminaDelay" .. i
	-- Don't drain when infinite
	if self.CVars.InfiniteStamina:GetBool() then
		-- Remove timers
		timer.Remove(stadrain)
		timer.Remove(staregen)
		timer.Remove(stadelay)
		return
	end
	-- Already draining
	if timer.Exists(stadrain) then return end
	-- Stops regeneration
	timer.Remove(staregen)
	timer.Remove(stadelay)
	-- Drain
	timer.Create(stadrain, 0.055, 0, function()
		if !IsValid(ply) then
			timer.Remove(stadrain)
		elseif !ply:KeyDown(IN_SPEED) then
			GAMEMODE:StaminaStop(ply)
		elseif ply:Team() != TEAM_SPECTATOR && ply:GetVelocity():Length2D() >= 65 then
			-- We lose a tiny bit more of stamina as client to account for lag
			if CLIENT then
				ply:SetStamina(math.Clamp(ply:GetStamina() - 1.05, 0, 100))
			else
				ply:SetStamina(math.Clamp(ply:GetStamina() - 1, 0, 100))
			end
		end
	end)
end

function GM:StaminaStop(ply)
	-- Do nothing on infinite
	if self.CVars.InfiniteStamina:GetBool() then return end
	local i = ply:EntIndex()
	-- Caching strings
	local stadrain = "HNS.StaminaDrain" .. i
	local staregen = "HNS.StaminaRegen" .. i
	local stadelay = "HNS.StaminaDelay" .. i
	-- Player did not sprint recently
	if timer.Exists(stadelay) || timer.Exists(staregen) then return end
	-- Stop draining stamina
	timer.Remove(stadrain)
	-- Create a delay before filling stamina
	timer.Create(stadelay, 2, 1, function()
		timer.Create(staregen, 0.05, 0, function()
			if !IsValid(ply) then
				timer.Remove(staregen)
				return
			end

			ply:SetStamina(math.Clamp(ply:GetStamina() + 0.4, 0, 100))
			-- Stop regen timer when full
			if ply:GetStamina() >= 100 then
				timer.Remove(staregen)
			end
		end)
	end)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:SetStamina(sta)
	if SERVER then
		self:SetNWFloat("has_stamina", sta)
	else
		self.Stamina = sta
	end
end

function PLAYER:GetStamina()
	if GAMEMODE.CVars.InfiniteStamina:GetBool() then
		return 100
	end

	if CLIENT && self == LocalPlayer() then
		return self.Stamina || self:GetNWFloat("has_stamina", 100)
	end

	return self:GetNWFloat("has_stamina", 100)
end