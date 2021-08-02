-- Global players tab to use in has_hands (to not call player.GetAll)
GM.PlayersCache = GAMEMODE and table.Copy(player.GetAll()) or {}

function GM:PlayerInitialSpawn(ply)
    ply.HASCollisions = {}
    -- Don't set bots as spectators
    if ply:IsBot() then
        ply:SetTeam(TEAM_SEEK)
        ply.Achs = {}

        return
    end

    ply:SetTeam(TEAM_SPECTATOR)
end

function GM:HASPlayerNetReady(ply)
    -- Get achievements from sql and also network etc
    ply:ProcessAchievements()
    -- Send round info
    net.Start("HNS.RoundInfo")
    net.WriteDouble(CurTime())
    net.WriteDouble(math.abs(timer.TimeLeft("HNS.RoundTimer") or (self.CVars.TimeLimit:GetInt() + self.CVars.BlindTime:GetInt())))
    net.WriteDouble(self.RoundLength or 0)
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
    -- Refresh cache
    self.PlayersCache = {}
    for _, other in ipairs(player.GetAll()) do
        table.insert(self.PlayersCache, other)
        if IsValid(other.HASCollisionBrush) then
            table.insert(self.PlayersCache, other.HASCollisionBrush)
        end
    end

    -- Removing last hider trail
    if IsValid(ply.HiderTrail) then
        ply.HiderTrail:Fire("Kill", 0, 0) -- Make the engine kill it
        ply.HiderTrail:Remove() -- Remove the entity
        ply.HiderTrail = nil -- Make this nil for future if checks
    end

    if ply:Team() == TEAM_SPECTATOR then
        self:PlayerSpawnAsSpectator(ply)
        ply:SetNoDraw(false) -- We hide spectators on PrePlayerDraw
        ply:AllowFlashlight(false)

        return true
    end

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

    local hidercolor = ply:GetInfo("has_hidercolor", "Default")
    local seekercolor = ply:GetInfo("has_seekercolor", "Default")
    ply:SetNWString("has_hidercolor", hidercolor)
    ply:SetNWString("has_seekercolor", seekercolor)

    if ply:Team() == TEAM_HIDE then
        -- Setting desired color shade
        ply:SetPlayerColor(self:GetTeamShade(TEAM_HIDE, hidercolor):ToVector())
        -- Setting movement vars
        ply:SetRunSpeed(self.CVars.HiderRunSpeed:GetInt())
        ply:SetWalkSpeed(self.CVars.HiderWalkSpeed:GetInt())
        -- Block flashlight
        ply:AllowFlashlight(false)
    else
        -- Setting desired color shade
        ply:SetPlayerColor(self:GetTeamShade(TEAM_SEEK, seekercolor):ToVector())
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

    if GAMEMODE.CVars.NewCollision:GetBool() then
        ply:SetCustomCollisionCheck(true)
        ply:CollisionRulesChanged()

        if not IsValid(ply.HASCollisionBrush) then
            ply.HASCollisionBrush = ents.Create("has_collisionbrush")
            ply.HASCollisionBrush:Spawn()
            table.insert(self.PlayersCache, ply.HASCollisionBrush)
        end
        ply.HASCollisionBrush:SetPlayer(ply)
    end

    -- We give hands again just in case PlayerLoadout doesn't fucking work
    timer.Simple(0.1, function()
        ply:Give("has_hands")
    end)

    self:RoundCheck()
end

function GM:PlayerLoadout(ply)
    if ply:Team() ~= TEAM_SPECTATOR then
        ply:Give("has_hands")
    end
end

function GM:PlayerCanPickupWeapon(ply, weapon)
    -- Allow pickup after round
    if ply:Team() == TEAM_SPECTATOR or (weapon:GetClass() ~= "has_hands" and self.RoundState == ROUND_ACTIVE) then return false end

    return true
end

function GM:PlayerDisconnected(ply)
    -- Remove from players table
    table.RemoveByValue(self.PlayersCache, ply)

    -- Check for seeker avoider
    if ply:Team() == TEAM_SEEK and team.NumPlayers(TEAM_SEEK) <= 1 then
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
        if ent.LastDoorToggle and CurTime() <= ent.LastDoorToggle + 1 then return false end
        -- Register last time
        ent.LastDoorToggle = CurTime()
    end

    -- Prevent use when running
    if ply:IsSprinting() and (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer") then return false end

    return true
end

function GM:CanPlayerTag(ply)
    return true
end

function GM:GetFallDamage(ply, speed)
    if self.RoundState ~= ROUND_ACTIVE then return end
    local time = math.Round(speed / 666, 1)

    if speed >= 600 then
        -- Break a leg!
        ply:EmitSound("player/pl_fleshbreak.wav")
        ply:EmitSound("vo/npc/" .. (ply.Gender and "female01" or "male01") .. "/pain0" .. math.random(9) .. ".wav")
        ply:ViewPunch(Angle(0, math.random(-speed / 45, speed / 45), 0))
        -- Make jump lower
        ply:SetJumpPower(85)

        -- Restore jump power
        timer.Create("HNS.FallRestore." .. ply:EntIndex(), time, 1, function()
            if IsValid(ply) and ply:Team() ~= TEAM_SPECTATOR then
                ply:SetJumpPower(GAMEMODE.CVars.JumpPower:GetInt())
            end
        end)

        -- Stop refilling stamina
        if speed < 650 then
            ply:SetStamina(ply:GetStamina())
        end

        hook.Run("HASPlayerFallDamage", ply)
    end

    if speed >= 650 then
        ply:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
        -- Lower stamina
        ply:SetStamina(ply:GetStamina() - time * 20)

        -- Moan
        timer.Simple(math.random(2, 4), function()
            if not IsValid(ply) then return end
            local rand = math.random(5)
            ply:EmitSound("vo/npc/" .. (ply.Gender and "fe" or "") .. "male01/moan0" .. rand .. ".wav")

            if ply.Gender then
                ply:EmitSound("vo/npc/female01/moan0" .. rand .. ".wav")
            end
        end)
    end
end

function GM:EntityTakeDamage(ent, damage)
    -- Don't kill on seeker blid time or when this is off
    if self.SeekerBlinded or not self.CVars.EnviromentDamageAllowed:GetBool() then return end

    -- Kill, make a seeker and check for round end
    if IsValid(ent) and IsValid(damage:GetAttacker()) and ent:IsPlayer() and ent:Alive() and damage:GetAttacker():GetClass() == "trigger_hurt" then
        ent:Kill()

        -- Don't turn into seeker if the round ended
        if self.RoundState == ROUND_ACTIVE then
            ent:SetTeam(TEAM_SEEK)
        end

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
        if not IsValid(ent) then return end

        -- If we're pushing a player
        if distance <= 4900 and ent:IsPlayer() and ply:Team() == ent:Team() and ent:GetVelocity():Length() <= 40 then
            ent:SetVelocity(ply:GetForward() * 82)

            return
        end

        -- If we're pushing a prop
        if distance <= 5184 and (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer") and ent:GetPhysicsObject():GetMass() > 35 then
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

-- This is different from client
function GM:ShouldCollide(ent1, ent2)
    if not IsValid(ent1) or not IsValid(ent2) then return false end

    if ent1:IsPlayer() and ent2:IsPlayer() then
        if self.CVars.NewCollision:GetBool() then
            return ent1.HASCollisions[ent2:EntIndex()] or ent2.HASCollisions[ent1:EntIndex()]
        else
            return true
        end
    elseif ent1:GetClass() == "has_collisionbrush" or ent2:GetClass() == "has_collisionbrush" then
        -- The collision brushes only affect clients
        -- This is because the player's camera will stutter a lot
        -- if they have ping and are on top of another player
        return false
    else
        return self.BaseClass.ShouldCollide(self, ent1, ent2)
    end
end

function GM:PlayerTick(ply, data)
    self:StaminaPrediction(ply, data:KeyDown(IN_SPEED))

    if not GAMEMODE.CVars.NewCollision:GetBool() then return end

    local pos = ply:GetPos()
    -- Refresh collisions cache
    for _, ent in ipairs(player.GetAll()) do
        if not IsValid(ent) then continue end

        local _, hull

        if ent:Crouching() then
            _, hull = ent:GetHullDuck()
        else
            _, hull = ent:GetHull()
        end

        local should = ent:Team() ~= TEAM_SPECTATOR and ply:Team() ~= TEAM_SPECTATOR and ent:GetPos().z + hull.z <= pos.z

        if ply.HASCollisions[ent:EntIndex()] ~= should then
            ply:CollisionRulesChanged()
            ply.HASCollisions[ent:EntIndex()] = should
        end
    end
end

function GM:HASPlayerCaught(seeker, ply)
    if self.RoundCount < 1 or not self.CVars.FirstSeeks:GetBool() then return end
    if IsValid(self.FirstCaught) and self.FirstCaught:Team() ~= TEAM_SPECTATOR then return end
    self.FirstCaught = ply
end

local using = nil

hook.Add("Move", "HNS.SprintPrevention", function(ply, data)
    using = ply:GetEntityInUse()

    -- Prevent sprinting while moving a prop
    if ply:IsSprinting() and IsValid(using) and (using:GetClass() == "prop_physics" or using:GetClass() == "player_pickup" or using:GetClass() == "prop_physics_multiplayer") then
        -- Seeker or hider max speed
        if ply:Team() == TEAM_HIDE then
            data:SetMaxSpeed(GAMEMODE.CVars.HiderWalkSpeed:GetInt())
        elseif ply:Team() == TEAM_SEEK then
            data:SetMaxSpeed(GAMEMODE.CVars.SeekerWalkSpeed:GetInt())
        end
    end
end)

local PLAYER = FindMetaTable("Player")

function PLAYER:Caught(ply)
    -- Change team
    self:SetTeam(TEAM_SEEK)
    -- Parameters
    self:AllowFlashlight(true)
    self:SetRunSpeed(GAMEMODE.CVars.SeekerRunSpeed:GetInt())
    self:SetWalkSpeed(GAMEMODE.CVars.SeekerWalkSpeed:GetInt())
    -- Change color
    self:SetPlayerColor(GAMEMODE:GetTeamShade(TEAM_SEEK, self:GetNWString("has_seekercolor", "Default")):ToVector())

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
    if ply:Team() == TEAM_HIDE or ply:Team() == TEAM_SEEK then return end
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

    -- If player is only seeker, forbid
    if GAMEMODE.RoundState == ROUND_ACTIVE and ply:Team() == TEAM_SEEK and team.NumPlayers(TEAM_SEEK) <= 1 then
        GAMEMODE:SendChat(ply, COLOR_WHITE, "[", Color(220, 20, 60), "HNS", COLOR_WHITE, "] You are the only seeker. Tag someone else first!")

        return
    end

    -- Log & advert
    GAMEMODE:BroadcastEvent(ply, PLYEVENT_SPEC)
    print(string.format("[LHNS] %s (%s) joins the spectators.", ply:Name(), ply:SteamID()))

    -- If players are avoiding getting tagged
    -- Run caught hook on nearest seeker
    if ply:Team() == TEAM_HIDE and not GAMEMODE.SeekerBlinded then
        local lowest, ent = 105626, nil

        for _, seeker in ipairs(team.GetPlayers(TEAM_SEEK)) do
            local dist = seeker:GetPos():DistToSqr(ply:GetPos())

            if dist <= 105625 and dist < lowest then
                lowest = dist
                ent = seeker
            end
        end

        if IsValid(ent) then
            if GAMEMODE.RoundCount > 0 then
                ent:AddFrags(GAMEMODE.CVars.SeekerReward:GetInt())
            end

            ply:Caught(ent)
        end
    end

    -- Set team and spawn
    ply:SetTeam(TEAM_SPECTATOR)
    ply:Spawn()
    -- Round check
    GAMEMODE:RoundCheck()
end)

-- Receive color update
net.Receive("HNS.PlayerColorUpdate", function(_, ply)
    local hidercolor = ply:GetInfo("has_hidercolor", "Default")
    local seekercolor = ply:GetInfo("has_seekercolor", "Default")
    ply:SetNWString("has_hidercolor", hidercolor)
    ply:SetNWString("has_seekercolor", seekercolor)
    if ply:Team() == TEAM_SPECTATOR then return end
    ply:SetPlayerColor(GAMEMODE:GetPlayerTeamColor(ply):ToVector())

    -- Update hider trail if applicable
    if IsValid(ply.HiderTrail) then
        ply.HiderTrail:Fire("Color", tostring(GAMEMODE:GetTeamShade(TEAM_HIDE, hidercolor)))
    end
end)

-- Call hook when player can receive net messages
net.Receive("HNS.PlayerNetReady", function(_, ply)
    hook.Run("HASPlayerNetReady", ply)
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
    if GAMEMODE.CVars.NewCollision:GetBool() then
        return
    end
    -- Stuck prevention
    for _, ply in ipairs(GAMEMODE.PlayersCache) do
        if not IsValid(ply) or not ply:IsPlayer() or ply:Team() == TEAM_SPECTATOR or ply:GetObserverMode() ~= OBS_MODE_NONE then continue end
        roof = (ply:Crouching() or ply:KeyDown(IN_DUCK)) and 58 or 70
        shouldCalculate = false

        -- Check for near players
        for _, ply2 in ipairs(GAMEMODE.PlayersCache) do
            if not IsValid(ply2) or not ply2:IsPlayer() or ply2:Team() == TEAM_SPECTATOR or ply == ply2 or ply2:GetObserverMode() ~= OBS_MODE_NONE then continue end

            if (ply:GetPos() + Vector(0, 0, 30)):DistToSqr(ply2:GetPos() + Vector(0, 0, 30)) <= 6400 then
                shouldCalculate = true
                break
            end
        end

        -- If another player is closeby, start checking
        if shouldCalculate then
            if ply:Crouching() or ply:KeyDown(IN_DUCK) then
                hulla, hullb = ply:GetHullDuck()
                hullb = hullb + Vector(0, 0, 4)
            else
                hulla, hullb = ply:GetHull()
            end

            hulla = hulla + Vector(2, 2, 2)
            hullb = hullb - Vector(2, 2, 2)

            for _, ent in ipairs(ents.FindInBox(ply:GetPos() + hulla, ply:GetPos() + hullb)) do
                if ent == ply or not ent:IsPlayer() or ply:Team() == TEAM_SPECTATOR or ent:GetObserverMode() ~= OBS_MODE_NONE then continue end
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