DeriveGamemode("base")
GM.Name = "Light Hide and Seek"
GM.Author = "Fafy"
GM.Email = ""
include("sh_colors.lua")
AddCSLuaFile("sh_colors.lua")
include("sh_roundmanager.lua")
AddCSLuaFile("sh_roundmanager.lua")
-- Player events
PLYEVENT_PLAY, PLYEVENT_SPEC, PLYEVENT_AVOID = 1, 2, 3
-- Shared ConVars
GM.CVars = GM.CVars or {}

GM.CVars.MaxRounds = CreateConVar("has_maxrounds", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Rounds until map change")
GM.CVars.TimeLimit = CreateConVar("has_timelimit", 300, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time to seek (0 is infinite)")
GM.CVars.EnviromentDamageAllowed = CreateConVar("has_envdmgallowed", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Will the map hurt players?")
GM.CVars.BlindTime = CreateConVar("has_blindtime", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time to hide (seekers are blinded)")
GM.CVars.HiderReward = CreateConVar("has_hidereward", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "How many points to award hiders per round won")
GM.CVars.SeekerReward = CreateConVar("has_seekreward", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "How many points to award seekers per hider tag")
GM.CVars.HiderRunSpeed = CreateConVar("has_hiderrunspeed", 320, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Speed at which hiders run at")
GM.CVars.SeekerRunSpeed = CreateConVar("has_seekerrunspeed", 360, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Speed at which seekers run at")
GM.CVars.HiderWalkSpeed = CreateConVar("has_hiderwalkspeed", 190, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Speed at which hiders walk at")
GM.CVars.SeekerWalkSpeed = CreateConVar("has_seekerwalkspeed", 200, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Speed at which seekers walk at")
GM.CVars.JumpPower = CreateConVar("has_jumppower", 210, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Force everyone jumps with")
GM.CVars.ClickRange = CreateConVar("has_clickrange", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Range at which seekers can click tag")
GM.CVars.ScoreboardText = CreateConVar("has_scob_text", "Light HNS", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Text for the scoreboard (top left button)")
GM.CVars.ScoreboardURL = CreateConVar("has_scob_url", "https://github.com/Fafy2801/light-hns", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Link the scoreboard button will open (top left button too)")
GM.CVars.HiderTrail = CreateConVar("has_lasthidertrail", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Put a trail on the last remaining hider.")
GM.CVars.HiderFlash = CreateConVar("has_hiderflashlight", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Enable hider flashlights (only visible to them).")
GM.CVars.TeamIndicators = CreateConVar("has_teamindicators", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Draw an indicator over teammates heads when they are far away.")
GM.CVars.InfiniteStamina = CreateConVar("has_infinitestamina", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Enable infinite stamina.")
GM.CVars.FirstSeeks = CreateConVar("has_firstcaughtseeks", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "First player caught will seek next round.")
GM.CVars.MaxStamina = CreateConVar("has_maxstamina", 100, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Maximum ammount of stamina players can refill.")
GM.CVars.StaminaRefill = CreateConVar("has_staminarefill", 6.6, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Rate at which stamina is filled.")
GM.CVars.StaminaDeplete = CreateConVar("has_staminadeplete", 13.3, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Rate at which stamina is depleted.")
GM.CVars.StaminaWait = CreateConVar("has_staminawait", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "How many seconds to wait before filling stamina.")

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
        GAMEMODE.TimeLeft = timer.TimeLeft("HNS.RoundTimer") or 0
        GAMEMODE.TimeLeft = math.abs(math.ceil(GAMEMODE.TimeLeft))
    end

    -- See if seeker is blinded
    if GAMEMODE.RoundState == ROUND_ACTIVE and GAMEMODE.RoundLength < GAMEMODE.TimeLeft then
        GAMEMODE.SeekerBlinded = true
    else
        GAMEMODE.SeekerBlinded = false
    end

    if GAMEMODE.RoundState == ROUND_ACTIVE then
        if not GAMEMODE.PlayedStartSound and not GAMEMODE.SeekerBlinded then
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
    return self.SeekerBlinded and ply:Team() == TEAM_SEEK
end

function GM:StaminaLinearFunction(x)
    --return x * 20 / 3
    return x * self.CVars.StaminaRefill:GetFloat()
end

function GM:StaminaLinearDeplete(x)
    --return x * 40 / 3
    return x * self.CVars.StaminaDeplete:GetFloat()
end

function GM:StaminaPrediction(ply, sprinting)
    if ply:Team() == TEAM_SPECTATOR then return end
    local max = self.CVars.MaxStamina:GetInt()
    ply.Stamina = ply.Stamina or max
    -- Make sure values exist
    local lastSprint = ply:GetNWFloat("has_staminalastsprinted", -1)

    if lastSprint < 0 then
        lastSprint = nil
    end

    local lastAmmount = ply:GetNWFloat("has_staminalastammount", max)
    local lastTime = ply:GetNWFloat("has_staminalasttime", CurTime())

    if sprinting and not lastSprint then
        lastSprint = CurTime()
        ply:SetNWFloat("has_staminalastsprinted", lastSprint)
    end

    -- If player sprinted at some point (defined on KeyPress)
    if lastSprint then
        -- And we're still sprinting
        if sprinting and ply:GetVelocity():Length2DSqr() >= 4225 then
            ply.Stamina = lastAmmount - self:StaminaLinearDeplete(CurTime() - lastSprint)
            ply:SetNWFloat("has_staminalasttime", CurTime())
        else
            -- If we aren't sprinting, we delete StaminaLastSprinted and define last stamina aquired
            ply:SetNWFloat("has_staminalastammount", ply.Stamina or max)
            ply:SetNWFloat("has_staminalasttime", CurTime())
            ply:SetNWFloat("has_staminalastsprinted", -1)
        end

        ply.Stamina = math.Clamp(ply.Stamina, 0, max)

        return
    end

    -- Last time since stamina was changed
    local since = CurTime() - lastTime

    -- We wait to refill stamina
    if since <= self.CVars.StaminaWait:GetFloat() then
        ply.Stamina = lastAmmount
    else
        ply.Stamina = lastAmmount + self:StaminaLinearFunction(since - self.CVars.StaminaWait:GetFloat())
    end

    ply.Stamina = math.Clamp(ply.Stamina, 0, max)
end

function GM:PlayerTick(ply, data)
    self:StaminaPrediction(ply, data:KeyDown(IN_SPEED))
end

hook.Add("KeyPress", "HNS.StaminaStart", function(ply, key)
    if IsFirstTimePredicted() and key == IN_SPEED then
        ply:SetNWFloat("has_staminalastsprinted", CurTime())
        ply:SetNWFloat("has_staminalastammount", ply.Stamina)
    end
end)

function GM:StartCommand(ply, cmd)
    if ply:Team() == TEAM_SPECTATOR then return end

    -- Prevent running
    if cmd:KeyDown(IN_SPEED) then
        if ply:GetStamina() <= 0 then
            cmd:SetButtons(cmd:GetButtons() - IN_SPEED)
            ply:SetNWBool("has_sprinting", false)
        else
            ply:SetNWBool("has_sprinting", true)
        end
    else
        ply:SetNWBool("has_sprinting", false)
    end
end

local PLAYER = FindMetaTable("Player")

-- This function will always be unpredicted
if SERVER then
    function PLAYER:SetStamina(sta)
        sta = math.Clamp(sta, 0, GAMEMODE.CVars.MaxStamina:GetInt())
        self:SetNWFloat("has_staminalastammount", sta)
        self:SetNWFloat("has_staminalasttime", CurTime())
        local lastSprint = self:GetNWFloat("has_staminalastsprinted", -1)

        if lastSprint >= 0 then
            self:SetNWFloat("has_staminalastsprinted", CurTime())
        end
    end
end

function PLAYER:GetStamina()
    if GAMEMODE.CVars.InfiniteStamina:GetBool() then return GAMEMODE.CVars.MaxStamina:GetInt() end

    -- We want to get the stamina of another player
    if CLIENT and self ~= LocalPlayer() then
        GAMEMODE:StaminaPrediction(self, self:GetNWBool("has_sprinting", false))
    end

    return self.Stamina
end