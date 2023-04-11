-- This is chaotic, if  you're trying to understand this... don't, do yourself a favor
-- Mostly because I've done this over 100 times
SWEP.Author = "Fafy"
SWEP.PrintName = "Hands"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.AnimPrefix = "rpg"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Secondary = SWEP.Primary

function SWEP:Initialize()
    self:SetWeaponHoldType("normal")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.25)
    self:SetNextSecondaryFire(CurTime() + 0.25)

    local owner = self:GetOwner()
    -- Stop if this is run on the client, or seeker is blinded and owner is seeking
    if CLIENT or (GAMEMODE.SeekerBlinded and owner:Team() == TEAM_SEEK) then return end
    owner:ViewPunch(Angle(-1, 0, 0))
    local ent = owner:GetEyeTrace()
    local dist = ent.StartPos:DistToSqr(ent.HitPos)
    ent = ent.Entity

    if (ent:GetClass() == "func_breakable" or ent:GetClass() == "func_breakable_surf") and dist <= 10000 and ent:Health() ~= 0 then
        -- Damage
        ent:EmitSound("physics/body/body_medium_impact_hard")
        ent:Fire("RemoveHealth", 25)
        -- Call hook
        hook.Run("HASHitBreakable", owner, ent)
    end

    -- Run a sound after round
    if GAMEMODE.RoundState == ROUND_POST then
        owner:EmitSound("misc/happy_birthday_tf_" .. math.random(10, 29) .. ".wav")
    end

    -- Don't check if we can tag a hider if round isn't active or we aren't seeking
    if GAMEMODE.RoundState ~= ROUND_ACTIVE or owner:Team() ~= TEAM_SEEK then return end
    if not hook.Run("CanPlayerTag", owner) then return end

    if ent:IsPlayer() and ent:Team() == TEAM_HIDE and dist <= GAMEMODE.CVars.ClickRange:GetInt() * GAMEMODE.CVars.ClickRange:GetInt() then
        ent:ViewPunch(Angle(8, math.random(-16, 16), 0))
        ent:Caught(owner)

        -- Award frag
        if GAMEMODE.RoundCount > 0 then
            owner:AddFrags(GAMEMODE.CVars.SeekerReward:GetInt())
        end
    end
end

SWEP.SecondaryAttack = SWEP.PrimaryAttack

function SWEP:Deploy()
    self.TauntDelay = self.TauntDelay or 0
    return true
end

function SWEP:Holster()
    return true
end

if SERVER then
    AddCSLuaFile("shared.lua")

    function SWEP:Think()
        local owner = self:GetOwner()
        -- Do nothing if round is nothing active or we aren't seeking
        if GAMEMODE.RoundState ~= ROUND_ACTIVE or GAMEMODE.SeekerBlinded or owner:Team() ~= TEAM_SEEK then return end
        if not hook.Run("CanPlayerTag", owner) then return end
        -- When this is true, we will calculate for hiders
        self.ShouldCalculate = false

        for _, ply in ipairs(team.GetPlayers(TEAM_HIDE)) do
            if (owner:GetPos() + Vector(0, 0, 30)):DistToSqr(ply:GetPos() + Vector(0, 0, 30)) <= 6084 then
                self.ShouldCalculate = true
                break
            end
        end

        -- If a hider is close enough, check for collition(Copied from old recoding)
        if self.ShouldCalculate then
            local range = 34 + owner:Ping() / 24
            local roof = owner:Crouching() and 64 or 76
            local floor = owner:GetGroundEntity() and -9 or -3
            local playerHeight = owner:Crouching() and 32 or 52
            local traceHeight = owner:Crouching() and 2.75 or 12
            local start = owner:GetPos() + Vector(0, 0, playerHeight)
            local traces = {}

            for i = 1, 5 do
                traces[i] = util.TraceHull({
                    start = start,
                    endpos = start + Vector(i == 1 and range or i == 2 and -range or 0, i == 3 and range or i == 4 and -range or 0, i == 5 and roof - playerHeight or 0),
                    filter = GAMEMODE.PlayersCache,
                    mins = Vector(i < 3 and -0.5 or i < 5 and -6 or -8, i < 3 and -6 or i < 5 and -0.5 or -8),
                    maxs = Vector(i < 3 and 0.5 or i < 5 and 6 or 8, i < 3 and 0.5 or i < 5 and 6 or 8, i == 5 and 0.5 or traceHeight),
                })
            end

            -- For each entity inside the box
            for _, ply in ipairs(ents.FindInBox(owner:GetPos() + Vector(math.max(traces[1].Fraction * range, 16.25), math.max(traces[3].Fraction * range, 16.25), floor), owner:GetPos() + Vector(math.min(-(traces[2].Fraction * range), -16.25), math.min(-(traces[4].Fraction * range), -16.25), playerHeight + traces[5].Fraction * (roof - playerHeight)))) do
                -- Stop if not a hider or spectating through ulx
                if not IsValid(ply) or not ply:IsPlayer() or ply:Team() ~= TEAM_HIDE or ply:GetObserverMode() ~= OBS_MODE_NONE then continue end
                local plyHeight = ply:Crouching() and 32 or 52

                -- See if we are touching ply
                local trace = util.TraceLine({
                    start = start,
                    endpos = ply:GetPos() + Vector(0, 0, plyHeight),
                    filter = GAMEMODE.PlayersCache
                })

                -- Tag
                if trace.Fraction == 1 then
                    ply:ViewPunch(Angle(8, math.random(-16, 16), 0))
                    owner:ViewPunch(Angle(-1, 0, 0))
                    -- Tag
                    ply:Caught(owner)

                    -- Award Frag
                    if GAMEMODE.RoundCount > 0 then
                        owner:AddFrags(1)
                    end

                    -- Call hook
                    hook.Run("HASPlayerCaughtArea", owner, ply)
                end
            end
        end
    end

    function SWEP:Reload()
        if self.TauntDelay > CurTime() then return end
        self.TauntDelay = CurTime() + 2.5

        local owner = self:GetOwner()
        local taunts = {}
        local gender = owner.Gender and "female01" or "male01"

        if GAMEMODE.RoundState == ROUND_ACTIVE then
            if owner:Team() == TEAM_HIDE then
                taunts = {"vo/npc/" .. gender .. "/answer20.wav", "vo/npc/" .. gender .. "/gordead_ans05.wav", "vo/npc/" .. gender .. "/gordead_ans06.wav", "vo/npc/" .. gender .. "/behindyou01.wav", "vo/npc/" .. gender .. "/hi01.wav", "vo/npc/" .. gender .. "/hi02.wav", "vo/npc/" .. gender .. "/illstayhere01.wav", "vo/npc/" .. gender .. "/littlecorner01.wav", "vo/npc/" .. gender .. "/runforyourlife01.wav", "vo/npc/" .. gender .. "/question30.wav", "vo/npc/" .. gender .. "/waitingsomebody.wav", "vo/npc/" .. gender .. "/uhoh.wav", "vo/npc/" .. gender .. "/incoming02.wav", "vo/npc/" .. gender .. "/yougotit02.wav", "vo/npc/" .. gender .. "/gethellout.wav", "vo/npc/" .. gender .. "/strider_run.wav", "vo/npc/" .. gender .. "/overhere01.wav", "vo/npc/" .. gender .. "/question06.wav", "vo/canals/" .. gender .. "/stn6_go_nag02.wav", "vo/trainyard/" .. gender .. "/cit_window_use01.wav", "vo/trainyard/" .. gender .. "/cit_window_use02.wav", "vo/trainyard/" .. gender .. "/cit_window_use03.wav", "vo/coast/barn/" .. gender .. "/youmadeit.wav", "vo/canals/" .. gender .. "/stn6_incoming.wav",}

                if owner.Gender then
                    table.insert(taunts, "vo/canals/airboat_go_nag01.wav")
                    table.insert(taunts, "vo/canals/airboat_go_nag03.wav")
                    table.insert(taunts, "vo/canals/arrest_getgoing.wav")
                    table.insert(taunts, "vo/trainyard/cit_window_usnext.wav")
                else
                    table.insert(taunts, "vo/canals/boxcar_becareful.wav")
                    table.insert(taunts, "vo/canals/boxcar_becareful_b.wav")
                    table.insert(taunts, "vo/canals/boxcar_go_nag03.wav")
                    table.insert(taunts, "vo/canals/boxcar_go_nag04.wav")
                    table.insert(taunts, "vo/canals/gunboat_goonout.wav")
                    table.insert(taunts, "vo/canals/matt_beglad.wav")
                    table.insert(taunts, "vo/canals/matt_getin.wav")
                    table.insert(taunts, "vo/canals/matt_goodluck.wav")
                    table.insert(taunts, "vo/canals/matt_tearinguprr_b.wav")
                    table.insert(taunts, "vo/canals/shanty_go_nag01.wav")
                    table.insert(taunts, "vo/canals/shanty_go_nag02.wav")
                    table.insert(taunts, "vo/canals/shanty_go_nag03.wav")
                    table.insert(taunts, "vo/canals/shanty_gotword.wav")
                end
            else
                taunts = {"vo/npc/" .. gender .. "/readywhenyouare01.wav", "vo/npc/" .. gender .. "/readywhenyouare02.wav", "vo/npc/" .. gender .. "/squad_approach02.wav", "vo/npc/" .. gender .. "/squad_away01.wav", "vo/npc/" .. gender .. "/squad_away02.wav", "vo/npc/" .. gender .. "/upthere01.wav", "vo/npc/" .. gender .. "/upthere02.wav", "vo/npc/" .. gender .. "/gotone01.wav", "vo/npc/" .. gender .. "/gotone02.wav", "vo/npc/" .. gender .. "/overthere01.wav", "vo/npc/" .. gender .. "/overthere02.wav", "vo/npc/" .. gender .. "/hi01.wav", "vo/npc/" .. gender .. "/hi02.wav", "vo/coast/odessa/" .. gender .. "/stairman_follow01.wav",}

                if owner.Gender then
                    table.insert(taunts, "vo/trainyard/female01/cit_hit05.wav")
                else
                    table.insert(taunts, "vo/coast/bugbait/sandy_youthere.wav")
                    table.insert(taunts, "vo/coast/bugbait/sandy_help.wav")
                end
            end
        else
            taunts = {"vo/npc/" .. gender .. "/yeah02.wav", "vo/coast/odessa/" .. gender .. "/nlo_cheer01.wav", "vo/coast/odessa/" .. gender .. "/nlo_cheer02.wav", "vo/coast/odessa/" .. gender .. "/nlo_cheer03.wav"}
        end

        owner:EmitSound(taunts[math.random(#taunts)], 89)
        hook.Run("HASPlayerTaunted", owner)
    end
elseif CLIENT then
    SWEP.FrameVisible = false
    local crosshair = {}

    function SWEP:DoDrawCrosshair(x, y)
        -- Crosshair
        if GAMEMODE.CVars.CrosshairEnable:GetBool() then
            crosshair.Size = GAMEMODE.CVars.CrosshairSize:GetInt()
            crosshair.Gap = GAMEMODE.CVars.CrosshairGap:GetInt()
            crosshair.Thick = GAMEMODE.CVars.CrosshairThick:GetInt()
            crosshair.Color = Color(GAMEMODE.CVars.CrosshairR:GetInt(), GAMEMODE.CVars.CrosshairG:GetInt(), GAMEMODE.CVars.CrosshairB:GetInt(), GAMEMODE.CVars.CrosshairA:GetInt())
            GAMEMODE:DrawCrosshair(ScrW() / 2, ScrH() / 2, crosshair)

            return true
        end
    end

    function SWEP:ShouldDrawViewModel()
        return false
    end

    function SWEP:DrawWorldModel()
    end

    function SWEP:DrawWorldModelTranslucent()
    end
end