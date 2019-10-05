function GM:PlayerInitialSpawn(ply)
	-- Get achievements from sql and also network etc
	ply:ProcessAchievements()
	-- Don't set bots as spectators
	if ply:IsBot() then
		ply:SetTeam(TEAM_SEEK)
		return
	end
	ply:SetTeam(TEAM_SPECTATOR)
	-- Send round info
	net.Start("HNS.RoundInfo")
		net.WriteDouble(CurTime())
		net.WriteDouble(math.abs(timer.TimeLeft("HNS.RoundTimer") || (self.CVars.TimeLimit:GetInt() + self.CVars.BlindTime:GetInt())))
		net.WriteDouble(self.RoundLength || 0)
		net.WriteInt(self.RoundCount, 8)
		net.WriteUInt(self.RoundState, 3)
	net.Send(ply)
	-- Send achievements masters
	for _, otherPly in ipairs(player.GetAll()) do
		if otherPly.AchMaster then
			net.Start("HNS.AchievementsMaster")
				net.WriteEntity(otherPly)
			net.Send(ply)
		end
	end
end

function GM:PlayerSpawn(ply)
	-- Removing last hider trail
	if IsValid(ply.HiderTrail) then
		ply.HiderTrail:Fire("Kill", 0, 0) -- Make the engine kill it
		ply.HiderTrail:Remove() -- Remove the entity
		ply.HiderTrail = nil -- Make this nil for future if checks
	end

	if ply:Team() == TEAM_SPECTATOR then
		self:PlayerSpawnAsSpectator(ply)
		ply:SetNoDraw(false)
		ply:SetMaterial("models/effects/vol_light001")
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
		ply:SetColor(Color(0, 0, 0, 0))
		ply:AllowFlashlight(false)
		return true
	end
	-- Calling base spawn for stuff fixing
	self.BaseClass:PlayerSpawn(ply)

	-- Fixing spectator stuff
	ply:SetMaterial("")
	ply:SetRenderMode(RENDERMODE_NORMAL)
	ply:SetColor(COLOR_WHITE)

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

	-- We give hands again just in case PlayerLoadout doesn't fucking work
	timer.Simple(0.1, function()
		ply:Give("has_hands")
	end)

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

function GM:EntityTakeDamage(ent, damage)
	-- Don't kill on seeker blid time or when this is off
	if self.SeekerBlinded || !self.CVars.EnviromentDamageAllowed:GetBool() then return end
	-- Kill, make a seeker and check for round end
	if IsValid(ent) && IsValid(damage:GetAttacker()) && ent:IsPlayer() && ent:Alive() && damage:GetAttacker():GetClass() == "trigger_hurt" then
		ent:Kill()
		ent:SetTeam(TEAM_SEEK)
		self:RoundCheck()
	end
end

function GM:KeyPress(ply, key)
	-- Push players and big props
	if key == IN_USE then
		if ply:Team() == TEAM_SPECTATOR then return end

		local ent = ply:GetEyeTrace()
		local distance = ply:GetPos():DistToSqr(ent.HitPos)
		ent = ent.Entity

		if !IsValid(ent) then return end

		-- If we're pushing a player
		if distance <= 4900 && ent:IsPlayer() && ply:Team() == ent:Team() && ent:GetVelocity():Length() <= 40 then
			ent:SetVelocity(ply:GetForward() * 82)
			return
		end

		-- If we're pushing a prop
		if distance <= 5184 && (ent:GetClass() == "prop_physics" || ent:GetClass() == "prop_physics_multiplayer") && ent:GetPhysicsObject():GetMass() > 35 then
			local eyeAngle = -ply:EyeAngles().p
			ent:GetPhysicsObject():Wake()

			if eyeAngle >= 2.5 then
				ent:GetPhysicsObject():AddVelocity(ply:GetForward() * 56 + Vector(0, 0, eyeAngle * 2.33))
			else
				ent:GetPhysicsObject():AddVelocity(ply:GetForward() * 66)
			end
		end
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
	-- Removing last hider trail
	if IsValid(self.HiderTrail) then
		self.HiderTrail:Fire("Kill", 0, 0) -- Make the engine kill it
		self.HiderTrail:Remove() -- Remove the entity
		self.HiderTrail = nil -- Make this nil for future if checks
	end
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
	GAMEMODE:BroadcastEvent(ply, PLYEVENT_PLAY)
	print(string.format("[LHNS] %s (%s) joins the seekers.", ply:Name(), ply:SteamID()))
	-- Set team and spawn
	ply:SetTeam(TEAM_SEEK)
	ply:Spawn()
end)
net.Receive("HNS.JoinSpectating", function(_, ply)
	-- Ignore specs
	if ply:Team() == TEAM_SPECTATOR then return end
	-- If player is only seeker, forbit
	if GAMEMODE.RoundState == ROUND_ACTIVE && ply:Team() == TEAM_SEEK && team.NumPlayers(TEAM_SEEK) <= 1 then
		GAMEMODE:SendChat(ply, COLOR_WHITE, "[", Color(220, 20, 60), "HNS", COLOR_WHITE, "] You are the only seeker. Tag someone else first!")
		return
	end
	-- Log & advert
	GAMEMODE:BroadcastEvent(ply, PLYEVENT_SPEC)
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
	-- Update hider trail if applicable
	if IsValid(ply.HiderTrail) then
		ply.HiderTrail:Fire("Color", tostring(GAMEMODE:GetTeamShade(TEAM_HIDE, ply:GetInfo("has_hidercolor", "Default"))))
	end
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
cvars.AddChangeCallback("has_lasthidertrail", function(_, _, new)
	if new == 0 then
		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply.HiderTrail) then
				ply.HiderTrail:Fire("Kill", 0, 0)
				ply.HiderTrail:Remove()
				ply.HiderTrail = nil
			end
		end
	end
end)

hook.Add("Tick", "HNS.PlayerStuckPrevention", function()
		-- Stuck prevention
	for _, ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end

		roof = (ply:Crouching() || ply:KeyDown(IN_DUCK)) && 58 || 70

		shouldCalculate = false

		-- Check for near players
		for _, ply2 in ipairs(player.GetAll()) do
			if ply2:Team() == TEAM_SPECTATOR || ply == ply2 then continue end

			shouldCalculate = false

			if (ply:GetPos() + Vector(0, 0, 30)):DistToSqr(ply2:GetPos() + Vector(0, 0, 30)) <= 6400 then
				shouldCalculate = true
				break
			end
		end

		-- If another player is closeby, start checking
		if shouldCalculate then
			if ply:Crouching() || ply:KeyDown(IN_DUCK) then
				hulla, hullb = ply:GetHullDuck()
				hullb = hullb + Vector(0, 0, 4)
			else
				hulla, hullb = ply:GetHull()
			end

			hulla = hulla + Vector(2, 2, 2)
			hullb = hullb - Vector(2, 2, 2)

			for _, ent in ipairs(ents.FindInBox(ply:GetPos() + hulla, ply:GetPos() + hullb)) do
				if ent == ply || !ent:IsPlayer () || ply:Team() == TEAM_SPECTATOR then continue end

				ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
				ent:SetColor(ColorAlpha(ply:GetColor(), 235))
				-- Un unstuck
				timer.Create("HAS_AntiStuck_" .. ent:EntIndex(), 0.25, 1, function()
					ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
					ent:SetRenderMode(RENDERMODE_NORMAL)
					ent:SetColor(ColorAlpha(ply:GetColor(), 255))
				end)

			end
		end
	end
end)