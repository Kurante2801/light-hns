-- FOR ONE TIME: PLY_STEAM_ID, ACHIEVEMENT_ID
-- FOR PROGRESS: PLY_STEAM_ID, ACHIEVEMENT_ID, PROGRESS

local PLAYER = FindMetaTable("Player")

-- Create SQL table
sql.Query("CREATE TABLE IF NOT EXISTS lhns_achievements_onetime (SteamID STRING, AchievementID STRING)")
sql.Query("CREATE TABLE IF NOT EXISTS lhns_achievements_progress (SteamID STRING, AchievementID STRING, Progress INT)")

function GM:PlayerNotifyAchievement(ply, id)
	net.Start("HNS.AchievementsGet")
		net.WriteEntity(ply)
		net.WriteString(id)
	net.Broadcast()
end

-- Get player achievements from SQL (I'd say this is fairly expensive to do)
function PLAYER:ProcessAchievements()
	self.Achs = {}
	-- Store count
	local completed = 0
	-- Get from SQL
	for id, ach in pairs(GAMEMODE.Achievements) do
		local result = sql.Query("SELECT * FROM lhns_achievements_" .. (ach.Goal && "progress" || "onetime") .. " WHERE SteamID = '" .. self:SteamID() .. "' AND AchievementID = '" .. id .. "'")

		-- Result will return nil if there's no sql entry
		if result then
			-- If we have a goal, we'll check for progress
			if ach.Goal then
				result = result[1]
				result.Progress = tonumber(result.Progress)
				-- Store progress
				self.Achs[id] = result.Progress
				-- Check for completion
				if self.Achs[id] >= ach.Goal then
					completed = completed + 1
				end
			else
				-- If we get a result on an achievement with no goal, achievement was achieved
				self.Achs[id] = true
				completed = completed + 1
			end
		end
	end

	-- Check for all achievements completion
	if completed >= GAMEMODE.AchievementsCount then
		self.AchMaster = true
		-- Network
		net.Start("HNS.AchievementsMaster")
			net.WriteEntity(self) -- Remember that self is PLAYER
		net.Broadcast()
	end

	-- Send achievements progress
	net.Start("HNS.AchievementsProgress")
		net.WriteTable(self.Achs)
	net.Send(self)
end

-- For one time achievements
function PLAYER:GiveAchievement(id)
	-- Check if achievement was already earned
	if self.Achs[id] then return end
	-- Insert into SQL
	sql.Query("INSERT INTO lhns_achievements_onetime VALUES('" .. self:SteamID() .. "', '" .. id .. "')")
	-- Process achievements
	self:ProcessAchievements()
	-- Notify
	GAMEMODE:PlayerNotifyAchievement(self, id)
	-- Log
	print(string.format("[LHNS] Player %s (%s) earned achievement %s (%s)", self:Name(), self:SteamID(), GAMEMODE.Achievements[id].Name, id))
	-- Call hook
	hook.Run("HASAchievementEarned", self, id)
end

-- For progressiv eachievements
function PLAYER:GiveAchievementProgress(id, count)
	-- Check if achievement was already earned
	if count == 0 || (self.Achs[id] || 0) >= GAMEMODE.Achievements[id].Goal then return end
	-- Make sure this exists for calculation
	self.Achs[id] = self.Achs[id] || 0
	-- Update or insert values
	if self.Achs[id] > 0 then
		sql.Query("UPDATE lhns_achievements_progress SET SteamID = SteamID, AchievementID = AchievementID, Progress = Progress + " .. count .. " WHERE SteamID = '" .. self:SteamID() .. "' AND AchievementID = '" .. id .. "'")
	else
		sql.Query("INSERT INTO lhns_achievements_progress VALUES('" .. self:SteamID() .. "', '" .. id .. "', " .. count .. ")")
	end
	-- Cache
	self.Achs[id] = self.Achs[id] + count
	-- Log
	print(string.format("[LHNS] Player %s (%s) has new achievement progress on %s (%s): %s/%s", self:Name(), self:SteamID(), GAMEMODE.Achievements[id].Name, id, self.Achs[id], GAMEMODE.Achievements[id].Goal))
	-- If we earned the achievement
	if self.Achs[id] >= GAMEMODE.Achievements[id].Goal then
		GAMEMODE:PlayerNotifyAchievement(self, id)
		-- Run hook
		hook.Run("HASAchievementEarned", self, id)
	end
	-- Update
	self:ProcessAchievements()
end

-- HERE COMES THE LOGIC!... I took it from a previous recoding attempt, back when I separated a function from its perenthesis
hook.Add("PlayerSpawn", "HNS.Achievements", function(ply)
	if ply:Team() != TEAM_HIDE then return end

	-- Setup
	ply.HWTime = 0
	ply.TauntsSingle = 0
end)

local lastSecond = 0
hook.Add("Tick", "HNS.Achievements", function()
	if GAMEMODE.RoundState == ROUND_ACTIVE && lastSecond != GAMEMODE.TimeLeft then
		lastSecond = GAMEMODE.TimeLeft
		-- Hiding in tranquility: Add a second each second
		for _, ply in pairs(team.GetPlayers(TEAM_HIDE)) do
			ply.HWTime = ply.HWTime + 1
		end
	end
end)

hook.Add("HASHitBreakable", "HNS.Achievements", function(ply, ent)
	if ply:Team() != TEAM_SEEK then return end

	-- Another way through
	timer.Simple(0.2, function()
		-- If we broke something
		if !IsValid(ent) || ent:Health() <= 0 then
			-- Flag
			ply.BrokeStuff = true
			-- Unflag after some time
			timer.Create("HNS.BrokeStuff_" .. ply:EntIndex(), 8, 1, function()
				if !IsValid(ply) then return end
				ply.BrokeStuff = false
			end)
		end
	end)
end)

hook.Add("OnPlayerHitGround", "HNS.Achievements", function(ply, water, _, speed)
	-- Mario
	local ent = ply:GetGroundEntity()

	if ply:Team() != TEAM_SEEK || !IsValid(ent) || !ent:IsPlayer() || water || speed < 100 then return end

	ply.LandedOnPlayer = ent

	timer.Simple(1, function()
		ply.LandedOnPlayer = nil
	end)
end)

hook.Add("HASPlayerFallDamage", "HNS.Achievements", function(ply)
	-- Rubber legs
	ply:GiveAchievementProgress("rubberlegs", 1)
end)

hook.Add("HASPlayerTaunted", "HNS.Achievements", function(ply)
	if GAMEMODE.RoundState != ROUND_ACTIVE || ply:Team() != TEAM_HIDE then return end

	-- Conversionalist
	ply.TauntsSingle = ply.TauntsSingle + 1

	if ply.TauntsSingle >= 30 then
		ply:GiveAchievement("conversationalist")
	end
end)

hook.Add("HASPlayerCaught", "HNS.Achievements", function(ply, victim)
	-- Seeking champ
	ply:GiveAchievementProgress("1kchampion", 1)
	-- Close call
	if team.NumPlayers(TEAM_HIDE) == 0 && math.abs(timer.TimeLeft("HNS.RoundTimer") || 0) <= 10 then
		ply:GiveAchievement("closecall")
	end
	-- Another way
	if ply.BrokeStuff then
		ply:GiveAchievement("anotherway")
	end
end)

hook.Add("HASPlayerCaughtArea", "HNS.Achievements", function(ply, victim)
	-- Submission
	victim.PreventSubmission = true
	timer.Simple(1, function()
		if IsValid(victim) then
			victim.PreventSubmission = false
		end
	end)

	if !ply.PreventSubmission && ply:GetVelocity():Length() <= 16 && ply:GetGroundEntity() != nil then
		ply:GiveAchievement("submission")
	end

	-- Mario
	if ply.LandedOnPlayer == victim then
		ply:GiveAchievement("mario")
	end
end)

hook.Add("HASRoundEndedTime", "HNS.Achievements2", function()
	-- Crowd
	for _, ply in pairs(team.GetPlayers(TEAM_HIDE)) do
		local ccc = 0

		for _, a in pairs(team.GetPlayers(TEAM_HIDE)) do
			if ply != a && ply:GetPos():DistToSqr(a:GetPos()) <= 57600 then
				ccc = ccc + 1
			end
		end

		if ccc >= 2 then
			ply:GiveAchievement("crowd")
		end
	end
	-- Last standing
	if team.NumPlayers(TEAM_HIDE) == 1 then
		team.GetPlayers(TEAM_HIDE)[1]:GiveAchievement("lasthiding")
	end
end)

local HASRoundEnded = function()
	-- Tranquility
	for _, ply in pairs(player.GetAll()) do
		if ply.HWTime != nil then
			ply:GiveAchievementProgress("tranquillity", ply.HWTime)
		end
	end
end
hook.Add("HASRoundEndedTime", "HNS.Achievements", HASRoundEnded)
hook.Add("HASRoundEndedCaught", "HNS.Achievements", HASRoundEnded)

hook.Add("PlayerSay", "HNS.Achievements", function(ply, text)
	-- Magic words
	if string.lower(text) == "tickle fight" || string.lower(text) == "ticklefight" then
		ply:GiveAchievement("ticklefight")
	end
end)

hook.Add("PlayerUse", "HNS.Achievements", function(ply, ent)
	if !string.match(ent:GetClass(), "^prop_physics") then return end

	if !ply.PickupTime then
		ply.PickupTime = CurTime()
	end

	if CurTime() >= ply.PickupTime then
		ply.PickupTime = CurTime() + 1

		if ent:GetModel() == "models/props_junk/bicycle01a.mdl" then
			ply:GiveAchievement("bike")
		end
	else
		ply.PickupTime = CurTime() + 1
	end
end)