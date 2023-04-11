local floor = math.floor
local ceil = math.ceil
local max = math.max

local COLOR_WHITE = Color(255, 255, 255)
local COLOR_BLACK = Color(0, 0, 0)
local COLOR_SHADOW = Color(0, 0, 0, 125)
local COLOR_SHADOW2 = Color(0, 0, 0, 175)

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
        local screen_padding = floor(8 * scale)
        local avatar_size = floor(32 * scale)

        -- Setting font with surface to get length
        surface.SetFont("HNSHUD.VerdanaMedium")
        local barW, textH = surface.GetTextSize(ply:Name())
        barW = ceil(max(100 * scale, barW + 3 * scale))

        -- Avatar Frame offset
        local nameX = ceil((this.AvatarFrame.Material and 44 or 42) * scale)
        local nameY = ceil(ScrH() - 35 * scale - textH / 2)

        -- Drawing name shadow now that we used surface.SetFont
        local shadow_offset = max(1, floor(0.5 * scale))

        surface.SetTextColor(0, 0, 0)
        surface.SetTextPos(nameX + shadow_offset, nameY + shadow_offset)
        surface.DrawText(ply:Name())

        -- Avatar
        draw.RoundedBox(0, screen_padding, ScrH() - screen_padding - avatar_size - 2, avatar_size + 2, avatar_size + 2, tint)
        draw.RoundedBox(0, screen_padding + 1, ScrH() - screen_padding - avatar_size - 1, avatar_size, avatar_size, COLOR_BLACK)
        this.Avatar:PaintManual()

        -- Name bar
        local barH = ceil(12 * scale)
        draw.RoundedBox(0, screen_padding + avatar_size + 2, ScrH() - screen_padding - avatar_size - 2, barW, barH, COLOR_SHADOW)
        this:ShadowedText(ply:Name(), "HNSHUD.VerdanaMedium", nameX, nameY, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        -- Team name
        this:ShadowedText(team.GetName(ply:Team()), "HNSHUD.TahomaSmall", nameX, ceil(ScrH() - 26 * scale), tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Stamina bar
        if ply:Team() == TEAM_SPECTATOR then
            this:ShadowedText("Press F2 to join the game!", "HNSHUD.TahomaSmall", nameX, ScrH() - ceil(19 * scale), tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            barH = ceil(13 * scale)
            draw.RoundedBox(0, screen_padding + avatar_size + 2, ScrH() - screen_padding - barH, barW, barH, COLOR_SHADOW2)

            local stamina_padding = max(1, ceil(1.25 * scale))
            draw.RoundedBox(0, screen_padding + avatar_size + 2 + stamina_padding, ScrH() - screen_padding - barH + stamina_padding, (barW - stamina_padding * 2) * stamina / GAMEMODE.CVars.MaxStamina:GetInt(), barH - stamina_padding * 2, ColorAlpha(tint, math.sin(CurTime() * 6) * 20 + 220))
        end

        -- Round time
        barW = ceil(70 * scale)
        barH = ceil(20 * scale)
        draw.RoundedBox(0, screen_padding, screen_padding, barW, barH, COLOR_SHADOW)
        this:ShadowedText(timeLeft, "HNSHUD.VerdanaLarge", screen_padding + barW * 0.5, screen_padding + barH * 0.5, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Round text
        draw.RoundedBox(0, screen_padding, screen_padding + barH + ceil(2 * scale), barW, floor(10 * scale), COLOR_SHADOW)
        this:ShadowedText(roundText, "HNSHUD.TahomaSmall", screen_padding + barW * 0.5, screen_padding + barH + floor(7 * scale), COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Blind text
        if GAMEMODE.SeekerBlinded then
            barW = ceil(120 * scale)
            barH = ceil(24 * scale)
            draw.RoundedBox(0, ScrW() * 0.5 - barW * 0.5, screen_padding, barW, barH, COLOR_SHADOW)
            this:ShadowedText((ply:Team() == TEAM_SEEK and "You" or team.NumPlayers(2) == 1 and "The seeker" or "The seekers") .. " will be unblinded in...", "HNSHUD.TahomaSmall", ScrW() * 0.5, ceil(13 * scale), COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            this:ShadowedText(blindTime, "HNSHUD.VerdanaLarge", ScrW() * 0.5, ceil(24 * scale) - 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Avatar Frame
        this.AvatarFrame:PaintManual()
    end,
    AvatarFunc = function(this, scale, ply)
        local screen_padding = floor(8 * scale)
        local avatar_size = floor(32 * scale)

        this.Avatar = vgui.Create("AvatarImage")
        this.Avatar:SetPos(screen_padding + 1, ScrH() - screen_padding - avatar_size - 1)
        this.Avatar:SetSize(avatar_size, avatar_size)
        this.Avatar.Player = ply or LocalPlayer()
        this.Avatar:SetPlayer(ply or LocalPlayer(), ceil(32 * scale))
        this.Avatar:SetPaintedManually(true)
        this.Avatar:MoveToBack()

        local frame_size = ceil(32 * 1.22 * scale)
        local frame_padding = ceil((frame_size - avatar_size) * 0.5)
        this.AvatarFrame = vgui.Create("HNS.AvatarFrame")
        this.AvatarFrame:SetPos(screen_padding + 1 - frame_padding, ScrH() - screen_padding - avatar_size - 1 - frame_padding)
        this.AvatarFrame:SetSize(frame_size, frame_size)
        this.AvatarFrame.Player = ply or LocalPlayer()
        this.AvatarFrame:SetPlayer(ply or LocalPlayer(), ceil(32 * scale))
        this.AvatarFrame:SetPaintedManually(true)
        this.AvatarFrame:MoveToBack()
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

    scale = self.CVars.HUDScale:GetFloat()
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
        draw.SimpleTextOutlined("Stuck Prevention Enabled", "HNSHUD.VerdanaMedium", ScrW() / 2, ScrH() / 2 + 60 * scale, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLOR_SHADOW)
    end

    -- Remove leftover avatars
    for i, hud in ipairs(self.HUDs) do
        -- Ignore current hud
        if hud == self.SelectedHUD then continue end

        if hud.Avatar then
            hud.Avatar:Remove()
            hud.Avatar = nil
        end

        if hud.AvatarFrame then
            hud.AvatarFrame:Remove()
            hud.AvatarFrame = nil
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

    -- Cache blur
    for i = 1, 2 do
        self.BlurMaterial:SetFloat("$blur", (i / 4) * 4)
        self.BlurMaterial:Recompute()
        render.UpdateScreenEffectTexture()
    end
end

-- Using hook to allow other HUD elements from other addons to be seen
function GM:PreDrawHUD()
     -- Blind (combined with render hook)
    if self.SeekerBlinded and LocalPlayer():Team() == TEAM_SEEK then
        cam.Start2D()
        cam.IgnoreZ(true)
        draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0))
        cam.IgnoreZ(false)
        cam.End2D()
    end
end

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