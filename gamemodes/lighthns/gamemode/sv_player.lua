function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_HIDE)
end

function GM:PlayerSpawn(ply)
	-- Calling base spawn for stuff fixing
	self.BaseClass:PlayerSpawn(ply)

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

function GM:PlayerCanPickupWeapon(ply, weapon)
	-- Allow pickup after round
	if ply:Team() == TEAM_SPECTATOR || self.RoundState == ROUND_ACTIVE then return false end

	return true
end

function GM:PlayerDisconnected(ply)
	-- Check for seeker avoider
	if ply:Team() == TEAM_SEEK && team.NumPlayers(TEAM_SEEK) <= 1 then
		self:BroadcastChat(COLOR_WHITE, "[", Color(220, 20, 60), "HNS", COLOR_WHITE, "] ", ply:Name(), " Avoided seeker! (", Color(220, 20, 60), ply:SteamID(), COLOR_WHITE, ")")
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