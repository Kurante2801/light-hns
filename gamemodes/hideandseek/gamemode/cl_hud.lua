function GM:StringToMinutesSeconds(time)
    local seconds = time % 60

    -- Fix missing 0
    if seconds < 10 then
        seconds = "0" .. seconds
    end
    -- Concatenate

    return math.floor(time / 60) .. ":" .. seconds
end

GM.HUDs = {}

GM.HUDs[1] = {
    Name = "Classic",
    Draw = function(this, ply, tint, stamina, timeLeft, roundText, blindTime, scale)
        -- Player info and stamina container
        draw.RoundedBoxEx(8 * scale, 10 * scale, ScrH() - 40 * scale, 100 * scale, 40 * scale, Color(0, 0, 0, 200), true, true, false, false)
        -- Player info
        draw.SimpleTextOutlined(ply:Name(), "HNSHUD.TahomaSmall", 16 * scale, ScrH() - 35 * scale + 1, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))
        draw.SimpleTextOutlined(team.GetName(ply:Team()), "HNSHUD.TahomaThin", 16 * scale, ScrH() - 28 * scale + 1, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))

        -- Stamina
        if ply:Team() ~= TEAM_SPECTATOR then
            draw.RoundedBoxEx(8 * scale, 110 * scale, ScrH() - 24 * scale, 54 * scale, 16 * scale, Color(0, 0, 0, 200), false, true, false, true)
            draw.RoundedBox(6 * scale, 12 * scale, ScrH() - 22 * scale, 150 * scale, 12 * scale, Color(0, 0, 0, 200))
            draw.RoundedBox(6 * scale, 12 * scale, ScrH() - 22 * scale, 150 * stamina / GAMEMODE.CVars.MaxStamina:GetInt() * scale, 12 * scale, ColorAlpha(tint, math.sin(CurTime() * 6) * 50 + 100))
        end

        -- Round indicators
        draw.RoundedBoxEx(8 * scale, 10 * scale, 0, 64 * scale, 36 * scale, Color(0, 0, 0, 200), false, false, true, true)
        draw.SimpleTextOutlined(timeLeft, "HNSHUD.RobotoLarge", 16 * scale, 12 * scale, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))
        draw.SimpleTextOutlined(roundText, "HNSHUD.TahomaThin", 16 * scale, 24 * scale, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))

        -- Blind time
        if GAMEMODE.SeekerBlinded then
            draw.RoundedBoxEx(8 * scale, ScrW() / 2 - 50 * scale, 0, 100 * scale, 36 * scale, Color(0, 0, 0, 200), false, false, true, true)
            draw.SimpleTextOutlined((ply:Team() == TEAM_SEEK and "You" or team.NumPlayers(2) == 1 and "The seeker" or "The seekers") .. " will be unblinded in...", "HNSHUD.TahomaThin", ScrW() / 2, 14 * scale, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))
            draw.SimpleTextOutlined(blindTime .. " seconds", "HNSHUD.TahomaThin", ScrW() / 2, 22 * scale, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))
        end
    end
}

GM.HUDs[2] = {
    Name = "Fafy",
    Draw = function(this, ply, tint, stamina, timeLeft, roundText, blindTime, scale)
        -- Setting font with surface to get length
        surface.SetFont("HNSHUD.VerdanaMedium")
        this.BarWide, this.TextTall = surface.GetTextSize(ply:Name())
        this.BarWide = math.max(100 * scale, this.BarWide + 3 * scale)
        -- Drawing name shadow now that we used surface.SetFont
        surface.SetTextColor(0, 0, 0)
        surface.SetTextPos(42 * scale + 1, (ScrH() - 35 * scale - this.TextTall / 2) + 1)
        surface.DrawText(ply:Name())
        -- Avatar image
        draw.RoundedBox(0, 8 * scale - 1, ScrH() - 40 * scale - 1, 32 * scale + 2, 32 * scale + 2, tint)
        draw.RoundedBox(0, 8 * scale, ScrH() - 40 * scale, 32 * scale, 32 * scale, Color(0, 0, 0))
        this.Avatar:PaintManual()
        -- Player name
        draw.RoundedBox(0, 40 * scale + 1, ScrH() - 40 * scale - 1, this.BarWide, 12 * scale, Color(0, 0, 0, 125))
        draw.SimpleText(ply:Name(), "HNSHUD.VerdanaMedium", 42 * scale, ScrH() - 35 * scale, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        -- Player team
        this:ShadowedText(team.GetName(ply:Team()), "HNSHUD.TahomaSmall", 42 * scale + 1, ScrH() - 25 * scale + 1, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        -- Round and timer bars
        draw.RoundedBox(0, 8 * scale - 1, 8 * scale - 1, 70 * scale, 20 * scale, Color(0, 0, 0, 125))
        draw.RoundedBox(0, 8 * scale - 1, 30 * scale, 70 * scale, 10 * scale, Color(0, 0, 0, 125))
        -- Round and timer texts
        this:ShadowedText(timeLeft, "HNSHUD.VerdanaLarge", 43 * scale - 1, 17 * scale + 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        this:ShadowedText(roundText, "HNSHUD.TahomaSmall", 43 * scale - 1, 35 * scale - 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if GAMEMODE.SeekerBlinded then
            draw.RoundedBox(0, ScrW() / 2 - 60 * scale, 8 * scale - 1, 120 * scale, 24 * scale, Color(0, 0, 0, 125))
            this:ShadowedText((ply:Team() == TEAM_SEEK and "You" or team.NumPlayers(2) == 1 and "The seeker" or "The seekers") .. " will be unblinded in...", "HNSHUD.TahomaSmall", ScrW() / 2, 13 * scale, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            this:ShadowedText(blindTime, "HNSHUD.VerdanaLarge", ScrW() / 2, 24 * scale - 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Stamina bar
        if ply:Team() == TEAM_SPECTATOR then
            this:ShadowedText("Press F2 to join the game!", "HNSHUD.TahomaSmall", 42 * scale + 1, ScrH() - 17 * scale, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            draw.RoundedBox(0, 40 * scale + 1, ScrH() - 20 * scale + 1, this.BarWide, 12 * scale, Color(0, 0, 0, 175))
            draw.RoundedBox(0, 41 * scale + 1, ScrH() - 19 * scale + 1, (this.BarWide - 2 * scale) * stamina / GAMEMODE.CVars.MaxStamina:GetInt(), 10 * scale, ColorAlpha(tint, math.sin(CurTime() * 4) * 60 + 120))
        end
    end,
    AvatarFunc = function(this, scale, ply)
        this.Avatar = vgui.Create("AvatarImage")
        this.Avatar:SetPos(8 * scale, ScrH() - 40 * scale)
        this.Avatar:SetSize(32 * scale, 32 * scale)
        this.Avatar.Player = ply or LocalPlayer()
        this.Avatar:SetPlayer(this.Avatar.Player, 32 * scale)
        this.Avatar:SetPaintedManually(true)
        this.Avatar:MoveToBack()
    end,
    ShadowedText = function(this, text, font, x, y, color, aX, aY, shadow, oX, oY)
        draw.SimpleText(text, font, (x or 0) + (oX or 1), (y or 0) + (oY or 1), shadow or Color(0, 0, 0), aX, aY)
        draw.SimpleText(text, font, x, y, color, aX, aY)
    end
}

GM.HUDs[3] = {
    Name = "Compact",
    Draw = function(this, ply, tint, stamina, timeLeft, roundText, blindTime, scale)
        -- So much for a border
        surface.SetDrawColor(tint)
        surface.DrawOutlinedRect(10 * scale, ScrH() - 60 * scale, 155 * scale, 50 * scale)

        -- Stamina
        if ply:Team() ~= TEAM_SPECTATOR then
            -- Black back
            draw.RoundedBox(0, 12 * scale + 1, ScrH() - 25 * scale, 150 * scale, 12 * scale + 1, Color(0, 0, 0, 215))
            -- Tinted bar
            draw.RoundedBox(0, 12 * scale + 1, ScrH() - 25 * scale, stamina / GAMEMODE.CVars.MaxStamina:GetInt() * 150 * scale, 12 * scale + 1, tint)
        end

        -- Background
        draw.RoundedBox(0, 10 * scale, ScrH() - 60 * scale, 155 * scale, 50 * scale, ColorAlpha(tint, 5))
        -- Player name
        draw.SimpleTextOutlined(ply:Name(), "HNSHUD.VerdanaMedium", 12 * scale + 1, ScrH() - 32 * scale - 1, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))
        -- Player team
        draw.SimpleTextOutlined(team.GetName(ply:Team()), "HNSHUD.VerdanaMedium", 162 * scale + 1, ScrH() - 32 * scale - 1, tint, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))
        -- Time remaining and round count
        draw.SimpleTextOutlined(timeLeft, "HNSHUD.VerdanaLarge", 12 * scale + 1, ScrH() - 53 * scale, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))
        draw.SimpleTextOutlined(roundText, "HNSHUD.VerdanaMedium", 12 * scale + 1, ScrH() - 42 * scale - 1, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))

        -- Time until seeker is unblinded
        if GAMEMODE.SeekerBlinded then
            draw.SimpleTextOutlined((ply:Team() == 1 and "Hide" or ply:Team() == 2 and "Wait" or "Start in") .. ": " .. blindTime, "HNSHUD.VerdanaMedium", 162 * scale + 1, ScrH() - 42 * scale - 1, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))
        end
    end
}

GM.HUDs[4] = {
    Name = "Cinematic",
    Draw = function() end
}

-- Draw HUD
GM.SelectedHUD = GM.HUDs[GM.CVars.HUD:GetInt()] or GM.HUDs[2]
GM.HiderColor = GM:GetTeamShade(TEAM_HIDE, GM.CVars.HiderColor:GetString())
GM.SeekerColor = GM:GetTeamShade(TEAM_SEEK, GM.CVars.SeekerColor:GetString())

local function GetDrawColor(ply)
    if ply:Team() == TEAM_HIDE then
        return GAMEMODE:GetTeamShade(TEAM_HIDE, GAMEMODE.CVars.HiderColor:GetString())
    elseif ply:Team() == TEAM_SEEK then
        return GAMEMODE:GetTeamShade(TEAM_SEEK, GAMEMODE.CVars.SeekerColor:GetString())
    else
        return team.GetColor(ply:Team())
    end
end

local function GetRoundText()
    if GAMEMODE.RoundState == ROUND_WAIT then
        return "Waiting for players..."
    else
        if GAMEMODE.RoundCount > 0 then
            return "Round " .. GAMEMODE.RoundCount
        else
            return "Warm-Up Round"
        end
    end
end

local speed, rayEnt, lastLooked, lookedTime, lookedColor, scale, ply

-- Prevent glitches when reloading
if GAMEMODE then
    GM.RoundLength = GAMEMODE.RoundLength
else
    GM.RoundLength = 0
end

function GM:HUDPaint()
    ply = LocalPlayer()
    -- Are we spectating someone else?
    local target = ply:GetObserverTarget()

    if IsValid(target) and target:IsPlayer() then
        ply = target
    end

    scale = self.CVars.HUDScale:GetInt()
    self.SelectedHUD = self.HUDs[self.CVars.HUD:GetInt()] or self.HUDs[2]

    -- Create avatar
    if IsValid(self.SelectedHUD.Avatar) and self.SelectedHUD.Avatar.Player ~= ply then
        self.SelectedHUD.Avatar:Remove()
        self.SelectedHUD:AvatarFunc(scale, ply)
    end

    if self.SelectedHUD.AvatarFunc and not IsValid(self.SelectedHUD.Avatar) then
        self.SelectedHUD:AvatarFunc(scale, ply)
    end

    -- Draw HUD
    self.SelectedHUD:Draw(ply, GetDrawColor(ply), ply:GetStamina(), self:StringToMinutesSeconds(self.TimeLeft), GetRoundText(), self.TimeLeft - self.RoundLength, scale)

    -- Stuck prevention
    if ply:GetCollisionGroup() == COLLISION_GROUP_WEAPON then
        draw.SimpleTextOutlined("Stuck Prevention Enabled", "HNSHUD.VerdanaMedium", ScrW() / 2, ScrH() / 2 + 60 * scale, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
    end

    -- Remove leftover avatars
    for i, hud in ipairs(self.HUDs) do
        -- Ignore current hud
        if hud == self.SelectedHUD then continue end

        if hud.Avatar then
            hud.Avatar:Remove()
            hud.Avatar = nil
        end
    end

    -- Speed pos
    if self.CVars.ShowSpeed:GetBool() then
        speed = ply:GetVelocity():Length2D()
        draw.RoundedBox(0, self.CVars.SpeedX:GetInt() - 25 * scale, self.CVars.SpeedY:GetInt() - 14 * scale, 50 * scale, 28 * scale, Color(0, 0, 0, speed > 0 and 200 or 100))
        draw.SimpleText("SPEED", "HNSHUD.VerdanaMedium", self.CVars.SpeedX:GetInt(), self.CVars.SpeedY:GetInt() - 8 * scale, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(math.Round(speed), "HNSHUD.TahomaLarge", self.CVars.SpeedX:GetInt(), self.CVars.SpeedY:GetInt() + 4 * scale, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Fade out names
    rayEnt = ply:GetEyeTrace().Entity

    if not IsValid(ply:GetObserverTarget()) and IsValid(rayEnt) and rayEnt:IsPlayer() and (self.RoundState ~= ROUND_ACTIVE or rayEnt:Team() == ply:Team() or rayEnt:GetPos():DistToSqr(ply:GetPos()) <= 302500) then
        -- From murder gamemode
        lastLooked = rayEnt
        lookedTime = CurTime()
    end

    -- Draw name
    if IsValid(lastLooked) and lookedTime + 2 > CurTime() then
        lookedColor = ColorAlpha(team.GetColor(lastLooked:Team()), (1 - (CurTime() - lookedTime) / 2) * 255)
        draw.SimpleTextOutlined(lastLooked:Name(), "HNSHUD.RobotoLarge", ScrW() / 2, ScrH() / 2 + 25 * scale, lookedColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, lookedColor.a))
        draw.SimpleTextOutlined(team.GetName(lastLooked:Team()), "HNSHUD.TahomaSmall", ScrW() / 2, ScrH() / 2 + 35 * scale, lookedColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, lookedColor.a))

        if self.CVars.ShowID:GetBool() then
            draw.SimpleTextOutlined(lastLooked:SteamID(), "HNSHUD.TahomaSmall", ScrW() / 2, ScrH() / 2 + 42 * scale, lookedColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, lookedColor.a))
        end
    end

    -- Team indicators (the V)
    if self.CVars.TeamIndicators:GetBool() and ply:Team() ~= TEAM_SPECTATOR then
        for _, mate in ipairs(team.GetPlayers(ply:Team())) do
            if mate == ply then continue end
            local pos = mate:GetPos() + Vector(0, 0, 84)
            local alpha = math.Clamp((ply:GetPos():Distance(mate:GetPos()) - 200) * 255 / 600, 0, 255)
            pos = pos:ToScreen()
            draw.SimpleTextOutlined("v", "HNSHUD.RobotoLarge", pos.x, pos.y, ColorAlpha(mate:GetPlayerColor():ToColor(), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha * 0.35))
        end
    end
end

-- Using hook to allow other HUD elements from other addons to be seen
hook.Add("HUDPaint", "HNS.BlindTime", function()
    -- Blind (combined with render hook)
    if GAMEMODE.SeekerBlinded and LocalPlayer():Team() == TEAM_SEEK then
        draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0))
    end
end, HOOK_HIGH)

-- Hook will run first, so other addons paint ON TOP of the black screen, thus being visible
-- Hide elements
local hide = {
    ["CHudWeaponSelection"] = true,
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudPoisonDamageIndicator"] = true,
    ["CHudZoom"] = true,
    ["CHudSuitPower"] = true,
}

function GM:HUDShouldDraw(element)
    return not hide[element]
end

-- Blind time
function GM:RenderScreenspaceEffects()
    if self.SeekerBlinded and LocalPlayer():Team() == TEAM_SEEK then
        DrawColorModify({
            ["pp_colour_addr "] = 0,
            ["pp_colour_addg "] = 0,
            ["pp_colour_addb "] = 0,
            ["pp_colour_brightness"] = -0.92,
            ["pp_colour_colour"] = 0,
            ["pp_colour_contrast"] = 1.4,
            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0,
        })
    end
end

function GM:DrawCrosshair(x, y, ch)
    surface.SetDrawColor(ch.Color)
    -- Top
    surface.DrawRect(x - ch.Thick / 2, y - ch.Size - ch.Gap, ch.Thick, ch.Size)
    -- Bottom
    surface.DrawRect(x - ch.Thick / 2, y + ch.Gap, ch.Thick, ch.Size)
    -- Right
    surface.DrawRect(x + ch.Gap, y - ch.Thick / 2, ch.Size, ch.Thick)
    -- Left
    surface.DrawRect(x - ch.Gap - ch.Size, y - ch.Thick / 2, ch.Size, ch.Thick)
end

-- Update avatars
cvars.AddChangeCallback("has_hud_scale", function()
    local hud = GAMEMODE.HUDs[GAMEMODE.CVars.HUD:GetInt()]

    if hud.AvatarFunc and IsValid(hud.Avatar) then
        hud.Avatar:Remove()
        hud.Avatar = nil
    end
end, "HNS.UpdateAvatar")