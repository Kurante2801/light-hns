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
		ply:SetPlayerColor(self:GetTeamColor(TEAM_HIDE, ply:GetInfo("has_hidercolor", "Default")):ToVector())
		-- Setting movement vars
		ply:SetRunSpeed(GetConVar("has_hiderrunspeed"):GetInt())
		ply:SetWalkSpeed(GetConVar("has_hiderwalkspeed"):GetInt())
		-- Block flashlight
		ply:AllowFlashlight(false)
	else
		-- Setting desired color shade
		ply:SetPlayerColor(self:GetTeamColor(TEAM_SEEK, ply:GetInfo("has_seekercolor", "Default")):ToVector())
		-- Setting movement vars
		ply:SetRunSpeed(GetConVar("has_seekerrunspeed"):GetInt())
		ply:SetWalkSpeed(GetConVar("has_seekerwalkspeed"):GetInt())
		-- Allow flashlight
		ply:AllowFlashlight(true)
	end
	-- Both teams get these
	ply:SetJumpPower(GetConVar("has_jumppower"):GetInt())
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