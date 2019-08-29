function GM:PlayerInitialSpawn(ply)
	if ply:IsBot() then
		ply:SetTeam(TEAM_SEEK)
		return
	end
	ply:SetTeam(TEAM_SPECTATOR)
	-- Send round info
	net.Start("HNS.RoundInfo")
		net.WriteDouble(CurTime())
		net.WriteDouble(math.abs(timer.TimeLeft("HNS.RoundTimer") || (self.CVars.TimeLimit:GetInt() + self.CVars.BlindTime:GetInt())))
		net.WriteInt(self.RoundCount, 8)
		net.WriteUInt(self.RoundState, 3)
	net.Send(ply)
end

function GM:PlayerSpawn(ply)
	if ply:Team() == TEAM_SPECTATOR then
		self:PlayerSpawnAsSpectator(ply)
		ply:SetNoDraw(false)
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
		ply:SetColor(Color(0, 0, 0, 0))
		ply:AllowFlashlight(false)
		return
	end
	-- Calling base spawn for stuff fixing
	self.BaseClass:PlayerSpawn(ply)

	-- Fixing spectator stuff
	ply:SetColor(COLOR_WHITE)
	ply:SetRenderMode(RENDERMODE_NORMAL)

	-- Set current gender
	ply.Gender = ply:GetInfoNum("has_gender", 0) == 1

	-- Setting random gender based model
	if ply.Gender then
		ply:SetModel("models/player/group01/female_0" .. math.random(6) .. ".mdl")
	else
		ply:SetModel("models/player/group01/male_0" .. math.random(9) .. ".mdl")
	end

	if ply:Team() == TEAM_HIDE then
		-- Setting desired color shade
		ply:SetPlayerColor(self:GetTeamShade(TEAM_HIDE, ply:GetInfo("has_hidercolor", "Default")):ToVector())
		-- Setting movement vars
		ply:SetRunSpeed(self.CVars.HiderRunSpeed:GetInt())
		ply:SetWalkSpeed(self.CVars.HiderWalkSpeed:GetInt())
		-- Block flashlight
		ply:AllowFlashlight(false)
	else
		-- Setting desired color shade
		ply:SetPlayerColor(self:GetTeamShade(TEAM_SEEK, ply:GetInfo("has_seekercolor", "Default")):ToVector())
		-- Setting movement vars
		ply:SetRunSpeed(self.CVars.SeekerRunSpeed:GetInt())
		ply:SetWalkSpeed(self.CVars.SeekerWalkSpeed:GetInt())
		-- Allow flashlight
		ply:AllowFlashlight(true)
	end
	-- Both teams get these
	ply:SetJumpPower(self.CVars.JumpPower:GetInt())
	ply:SetCrouchedWalkSpeed(0.4)
	ply:GodEnable()

	self:RoundCheck()
end

function GM:PlayerLoadout(ply)
	if ply:Team() != TEAM_SPECTATOR then
		ply:Give("has_hands")
	end
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	-- Allow pickup after round
	if ply:Team() == TEAM_SPECTATOR || (weapon:GetClass() != "has_hands" && self.RoundState == ROUND_ACTIVE) then return false end

	return true
end

function GM:PlayerDisconnected(ply)
	-- Check for seeker avoider
	if ply:Team() == TEAM_SEEK && team.NumPlayers(TEAM_SEEK) <= 1 then
		self:BroadcastChat(COLOR_WHITE, "[", Color(220, 20, 60), "HNS", COLOR_WHITE, "] ", ply:Name(), " avoided seeker! (", Color(220, 20, 60), ply:SteamID(), COLOR_WHITE, ")")
	end
	self:RoundCheck()
end

function GM:PlayerDeath(ply)
	-- Award 1 frag because players lose 1 frag on death
	ply:AddFrags(1)
end

function GM:CanPlayerSuicide(ply)
	-- Allow seekers to suicide
	return ply:Team() == TEAM_SEEK
end

-- Abusable doors
local doors = {
	["function_door_rotating"] = true,
	["prop_door_rotating"] = true,
}

function GM:PlayerUse(ply, ent)
	-- Stop spectators
	if ply:Team() == TEAM_SPECTATOR then return false end

	-- Anti door spam
	if doors[ent:GetClass()] then
		-- Stop with 1 sec delay
		if ent.LastDoorToggle && CurTime() <= ent.LastDoorToggle + 1 then return false end
		-- Register last time
		ent.LastDoorToggle = CurTime()
	end

	return true
end

function GM:GetFallDamage(ply, speed)
	if self.RoundState != ROUND_ACTIVE then return end

	local time = math.Round(speed / 666, 1)

	if speed >= 600 then
		-- Break a leg!
		ply:EmitSound("player/pl_fleshbreak.wav")
		ply:EmitSound("vo/npc/" .. (ply.Gender && "female01" || "male01") .. "/pain0" .. math.random (9) .. ".wav")
		ply:ViewPunch(Angle(0, math.random(-speed / 45, speed / 45), 0))
		-- Make jump lower
		ply:SetJumpPower(85)
		-- Restore jump power
		timer.Create("HNS.FallRestore." .. ply:EntIndex(), time, 1, function()
			if IsValid(ply) && ply:Team() != TEAM_SPECTATOR then
				ply:SetJumpPower(GAMEMODE.CVars.JumpPower:GetInt())
			end
		end)

		hook.Run ("HASPlayerFallDamage", ply)
	end

	if speed >= 760 then
		ply:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
		-- Lower stamina
		net.Start("HNS.StaminaChange")
			net.WriteInt(time * -10, 8)
		net.Send(ply)

		-- Moan
		timer.Simple(math.random(2, 4), function()
			if !IsValid(ply) then return end

			local rand = math.random(5)

			ply:EmitSound("vo/npc/" .. (ply.Gender && "fe" || "") .. "male01/moan0" .. rand .. ".wav")
			if ply.Gender then
				ply:EmitSound("vo/npc/female01/moan0" .. rand .. ".wav")
			end
		end)
	end
end

FindMetaTable("Player").Caught = function(self, ply)
	-- Change team
	self:SetTeam(TEAM_SEEK)
	-- Parameters
	self:AllowFlashlight(true)
	self:SetRunSpeed(GAMEMODE.CVars.SeekerRunSpeed:GetInt())
	self:SetWalkSpeed(GAMEMODE.CVars.SeekerWalkSpeed:GetInt())
	-- Change color
	self:SetPlayerColor(GAMEMODE:GetTeamShade(TEAM_SEEK, self:GetInfo("has_seekercolor", "Default")):ToVector())
	-- Call hook
	hook.Run("HASPlayerCaught", ply, self)
	-- Play sounds
	self:EmitSound("physics/body/body_medium_impact_soft7.wav")
	GAMEMODE:SendSound(self, "npc/roller/code2.wav")
	-- Check round state
	GAMEMODE:RoundCheck()
end

-- Receive player changing teams
net.Receive("HNS.JoinPlaying", function(_, ply)
	-- Ignore players
	if ply:Team() == TEAM_HIDE || ply:Team() == TEAM_SEEK then return end
	-- Log
	GAMEMODE:BroadcastChat(COLOR_WHITE, "[", Color(200, 200, 200), "HNS", COLOR_WHITE, "] " .. ply:Name() .. " (", Color(200, 200, 200), ply:SteamID(), COLOR_WHITE, ") is now playing!")
	print(string.format("[LHNS] %s (%s) joins the seekers.", ply:Name(), ply:SteamID()))
	-- Set team and spawn
	ply:SetTeam(TEAM_SEEK)
	ply:Spawn()
end)
net.Receive("HNS.JoinSpectating", function(_, ply)
	-- Ignore specs
	if ply:Team() == TEAM_SPECTATOR then return end
	-- If player is only seeker, forbit
	if ply:Team() == TEAM_SEEK && team.NumPlayers(TEAM_SEEK) <= 1 then
		GAMEMODE:SendChat(ply, COLOR_WHITE, "[", Color(220, 20, 60), "HNS", COLOR_WHITE, "] You are the only seeker. Tag someone else first!")
		return
	end
	-- Log & advert
	GAMEMODE:BroadcastChat(COLOR_WHITE, "[", Color(200, 200, 200), "HNS", COLOR_WHITE, "] " .. ply:Name() .. " (", Color(200, 200, 200), ply:SteamID(), COLOR_WHITE, ") is now spectating!")
	print(string.format("[LHNS] %s (%s) joins the spectators.", ply:Name(), ply:SteamID()))
	-- Set team and spawn
	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spawn()
	-- Round check
	GAMEMODE:RoundCheck()
end)

-- Receive color update
net.Receive("HNS.PlayerColorUpdate", function(_, ply)
	ply:SetPlayerColor(GAMEMODE:GetPlayerTeamColor(ply):ToVector())
end)

-- Update movement vars
cvars.AddChangeCallback("has_hiderrunspeed", function(_, _, new)
	for _, ply in ipairs(team.GetPlayers(TEAM_HIDE)) do
		ply:SetRunSpeed(new)
	end
end)
cvars.AddChangeCallback("has_seekerrunspeed", function(_, _, new)
	for _, ply in ipairs(team.GetPlayers(TEAM_SEEK)) do
		ply:SetRunSpeed(new)
	end
end)
cvars.AddChangeCallback("has_hiderwalkspeed", function(_, _, new)
	for _, ply in ipairs(team.GetPlayers(TEAM_HIDE)) do
		ply:SetWalkSpeed(new)
	end
end)
cvars.AddChangeCallback("has_seekerwalkspeed", function(_, _, new)
	for _, ply in ipairs(team.GetPlayers(TEAM_SEEK)) do
		ply:SetWalkSpeed(new)
	end
end)
cvars.AddChangeCallback("has_jumppower", function(_, _, new)
	for _, ply in ipairs(player.GetAll()) do
		ply:SetJumpPower(new)
	end
end)