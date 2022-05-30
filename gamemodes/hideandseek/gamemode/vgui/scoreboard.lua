local floor = math.floor
local sorts = {"Entity ID", "Points", "Name"}


-- Menu that shows all players when you press TAB
local PANEL = {}

function PANEL:Init()
    self.Blur = GAMEMODE.BlurMaterial
    self.Star = Material("icon16/star.png")
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetDraggable(false)
    -- GitHub/server button
    self.BigButton = self:Add("DButton")
    self.BigButton:SetText("")

    self.BigButton.Paint = function(this, w, h)
        GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, Color(150, 150, 150, 125), 6, function(s) return s.Depressed or s:IsHovered() end)
        surface.SetDrawColor(150, 150, 150, 255)
        surface.DrawLine(w - 1, 0, w - 1, h)
        self:ShadowedText(GAMEMODE.CVars.ScoreboardText:GetString(), "HNSHUD.VerdanaLarge", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.BigButton.DoClick = function()
        gui.OpenURL(GAMEMODE.CVars.ScoreboardURL:GetString())
    end

    -- Sorting methods
    self.Sort = self:Add("DButton")
    self.Sort:SetText("")

    self.Sort.Paint = function(this, w, h)
        surface.SetDrawColor(150, 150, 150, 255)
        surface.DrawOutlinedRect(0, 0, w + 1, h)
        self:ShadowedText(sorts[GAMEMODE.CVars.Sort:GetInt()], "HNSHUD.RobotoThin", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.Sort.DoClick = function()
        if GAMEMODE.CVars.Sort:GetInt() == 1 then
            GAMEMODE.CVars.Sort:SetInt(2)
        elseif GAMEMODE.CVars.Sort:GetInt() == 2 then
            GAMEMODE.CVars.Sort:SetInt(3)
        else
            GAMEMODE.CVars.Sort:SetInt(1)
        end

        -- Resort
        self:UpdatePlayers(GAMEMODE.CVars.HUDScale:GetFloat())
    end

    self.SortVertical = self:Add("DButton")
    self.SortVertical:SetText("")

    self.SortVertical.Paint = function(this, w, h)
        surface.SetDrawColor(150, 150, 150, 255)
        surface.DrawOutlinedRect(0, 0, w + 1, h)
        -- Arrow
        if not this.Shape or not this.ShapeShadow then return end
        draw.NoTexture()
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawPoly(this.ShapeShadow)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawPoly(this.Shape)
    end

    self.SortVertical.DoClick = function()
        GAMEMODE.CVars.SortReversed:SetBool(not GAMEMODE.CVars.SortReversed:GetBool())
    end

    -- Player list
    self.SP = self:Add("DScrollPanel")
    self.SP:Dock(FILL)
    self.SP.VBar:SetHideButtons(true)

    self.SP.VBar.Paint = function(this, w, h)
        -- Blur
        local blurx, blury = this:LocalToScreen(0, 0)
        render.SetScissorRect(blurx, blury, blurx + w, blury + h, true)
        surface.SetMaterial(self.Blur)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(-blurx, -blury, ScrW(), ScrH())
        render.SetScissorRect(0, 0, 0, 0, false)
        -- Fill and outline
        surface.SetDrawColor(0, 0, 0, 125)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(150, 150, 150, 255)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.SP.VBar.btnGrip.Paint = function(this, w, h)
        -- Fill
        surface.SetDrawColor(150, 150, 150, 75)
        surface.DrawRect(0, 0, w, h)
        -- Overlay
        GAMEMODE.DUtils.FadeHover(this, 1, 0, 0, w, h, Color(150, 150, 150), 6, function(s) return s.Depressed end)
    end

    self.Players = {}

    -- Adding players
    for i, ply in ipairs(player.GetAll()) do
        local button = self.SP:Add("HNS.ScoreboardPlayer")
        button:SetPlayer(ply)
        button:SetScale(GAMEMODE.CVars.HUDScale:GetFloat())
        button.Blur = self.Blur
        button.Star = self.Star
        table.insert(self.Players, button)
    end

    -- Server name
    self.ServerName = self:Add("DPanel")

    self.ServerName.Paint = function(this, w, h)
        surface.SetFont("HNSHUD.RobotoThin")

        -- Scrolling text
        if this.HostNameWide > w then
            local offset = SysTime() % 10 / 10
            this:Text(offset * -this.HostNameWide + this.HostNameWide, 0)
            this:Text(offset * -this.HostNameWide, 0)
        else
            this:Text(0, 0)
        end
    end

    self.ServerName.Text = function(this, x, y)
        surface.SetTextColor(0, 0, 0, 255)
        surface.SetTextPos(x + 1, y + 1)
        surface.DrawText(GetHostName())
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x, y)
        surface.DrawText(GetHostName())
    end

    -- We do this last so everything is sized
    self:UpdateDimentions()
end

function PANEL:Paint(w, h)
    local scale = GAMEMODE.CVars.HUDScale:GetFloat()
    local blurx, blury = self:LocalToScreen(0, 0)

    -- Top blur
    render.SetScissorRect(blurx, blury, blurx + w, blury + 32 * scale, true)
    surface.SetMaterial(self.Blur)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(-blurx, -blury, ScrW(), ScrH())
    render.SetScissorRect(0, 0, 0, 0, false)
    -- Top bar and outline
    surface.SetDrawColor(0, 0, 0, 125)
    surface.DrawRect(0, 0, w, 32 * scale)
    surface.SetDrawColor(150, 150, 150, 255)
    surface.DrawOutlinedRect(0, 0, w, 32 * scale)
    -- Map name
    self:ShadowedText("Map: ", "HNSHUD.RobotoThin", 114 * scale, 16 * scale, Color(215, 215, 215), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    self:ShadowedText(game.GetMap(), "HNSHUD.RobotoThin", 134 * scale, 16 * scale, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    -- Player count
    self:ShadowedText("Players: ", "HNSHUD.RobotoThin", 114 * scale, 25 * scale, Color(215, 215, 215), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    self:ShadowedText(player.GetCount() .. "/" .. game.MaxPlayers(), "HNSHUD.RobotoThin", 144 * scale, 25 * scale, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    -- Player list header
    render.SetScissorRect(blurx, blury + 34 * scale, blurx + w, blury + 46 * scale, true)
    surface.SetMaterial(self.Blur)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(-blurx, -blury, ScrW(), ScrH())
    render.SetScissorRect(0, 0, 0, 0, false)
    surface.SetDrawColor(0, 0, 0, 125)
    surface.DrawRect(0, 34 * scale, w, 12 * scale)
    surface.SetDrawColor(150, 150, 150, 255)
    surface.DrawOutlinedRect(0, 34 * scale, w, 12 * scale)
    -- Teams count (on the header)
    self:ShadowedText("Hiders: " .. team.NumPlayers(TEAM_HIDE), "HNSHUD.RobotoThin", 4 * scale, 40 * scale, Color(75, 150, 225), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    self:ShadowedText("Seekers: " .. team.NumPlayers(TEAM_SEEK), "HNSHUD.RobotoThin", w / 2, 40 * scale, Color(215, 75, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    self:ShadowedText("Spectators: " .. team.NumPlayers(TEAM_SPECTATOR), "HNSHUD.RobotoThin", w - 4 * scale, 40 * scale, Color(0, 175, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

-- Resize when HUD scale is changed
function PANEL:UpdateDimentions()
    local scale = GAMEMODE.CVars.HUDScale:GetFloat()
    -- Padding
    self:DockPadding(0, 48 * scale, 0, 0)
    -- Makes the width smaller than ScrW at all times
    self:SetSize(math.min(scale * 250, ScrW() - 50), ScrH() - 100)
    self:Center()
    -- Github/server button
    self.BigButton:SetSize(110 * scale, 32 * scale)
    -- VBar
    self.SP.VBar:SetWide(10 * scale)
    -- Sort modes
    self.Sort:SetSize(40 * scale, 10 * scale)
    self.Sort:SetPos(self:GetWide() - 50 * scale, 22 * scale)
    self.SortVertical:SetSize(10 * scale, 10 * scale)
    self.SortVertical:SetPos(self:GetWide() - 10 * scale, 22 * scale)

    -- Define sort arrow polygons
    if GAMEMODE.CVars.SortReversed:GetBool() then
        self.SortVertical.Shape = {
            {
                x = 5 * scale,
                y = 3 * scale
            },
            {
                x = 7 * scale,
                y = 7 * scale
            },
            {
                x = 3 * scale,
                y = 7 * scale
            },
        }
    else
        self.SortVertical.Shape = {
            {
                x = 3 * scale,
                y = 3 * scale
            },
            {
                x = 7 * scale,
                y = 3 * scale
            },
            {
                x = 5 * scale,
                y = 7 * scale
            },
        }
    end

    self.SortVertical.ShapeShadow = {
        {
            x = self.SortVertical.Shape[1].x + 1,
            y = self.SortVertical.Shape[1].y + 1
        },
        {
            x = self.SortVertical.Shape[2].x + 1,
            y = self.SortVertical.Shape[2].y + 1
        },
        {
            x = self.SortVertical.Shape[3].x + 1,
            y = self.SortVertical.Shape[3].y + 1
        },
    }

    -- Players
    self:UpdatePlayers(scale)
    -- Server name
    surface.SetFont("HNSHUD.RobotoThin")
    self.ServerName.HostNameWide, self.HostNameTall = surface.GetTextSize(GetHostName())
    -- Limit the bounds of the panel
    self.ServerName:SetPos(114 * scale, 7 * scale - self.HostNameTall / 2)
    self.ServerName:SetSize(self:GetWide() - 114 * scale, self.HostNameTall)
    -- Pass values
    self.ServerName.HostNameWide = self.ServerName.HostNameWide + 12 * scale -- Moar padding (for scrolling purposes)
    self.ServerName.HostNameTall = self.HostNameTall
    self.ServerName.Scale = scale
end

function PANEL:UpdatePlayers(scale)
    -- We sort by name here
    if GAMEMODE.CVars.Sort:GetInt() == 3 then
        table.sort(self.Players, function(a, b)
            if not IsValid(a.Player) or not IsValid(b.Player) then return false end

            return a.Player:Name() > b.Player:Name()
        end)
    end

    -- We set the zPos
    for i, button in ipairs(self.Players) do
        if not IsValid(button.Player) then
            button:Remove()
            continue
        end

        button:SetScale(scale)
        local pos = 0

        -- Sort players
        if GAMEMODE.CVars.Sort:GetInt() == 1 then
            pos = button.Player:EntIndex()
        elseif GAMEMODE.CVars.Sort:GetInt() == 2 then
            pos = -button.Player:Frags() -- It's negative because we want higher points to be up
        else
            pos = i
        end

        -- Reverse the sorting
        if GAMEMODE.CVars.SortReversed:GetBool() then
            pos = -pos
        end

        -- Spectators always last
        if button.Player:Team() == TEAM_SPECTATOR then
            pos = pos + game.MaxPlayers()
            -- Local player first
        elseif GAMEMODE.CVars.ShowOnTop:GetBool() and button.Player == LocalPlayer() then
            pos = pos - game.MaxPlayers()
        end

        -- Set ZPos
        button:SetZPos(pos)
        button:DockMargin(0, 0, self.SP.VBar.Enabled and (2 * scale) or 0, 2 * scale)
    end
end

function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
    draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0), alignx, aligny)

    return draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

-- Add missing players
function PANEL:Think()
    -- Loop through players
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or ply:Team() == 0 then continue end

        -- Loop through buttons
        for i, button in ipairs(self.Players) do
            -- We also check if a player is not valid here
            if not IsValid(button.Player) then
                table.remove(self.Players, i)
                goto foundply -- Don't keep looking for a player that doesn't exist
            end

            -- We found the player we were looking for
            if button.Player == ply then
                goto foundply
            end
        end

        -- This will not run if a button was found
        -- So we add the button here
        local button = self.SP:Add("HNS.ScoreboardPlayer")
        button.Blur = self.Blur
        button.Star = self.Star
        button:SetPlayer(ply)
        button:SetScale(GAMEMODE.CVars.HUDScale:GetFloat())
        table.insert(self.Players, button)

        -- We do this in a timer so it updates properly
        timer.Simple(1, function()
            self:UpdatePlayers(GAMEMODE.CVars.HUDScale:GetFloat())
        end)

        ::foundply::
    end
end

vgui.Register("HNS.Scoreboard", PANEL, "DFrame")
PANEL = {}

function PANEL:Init()
    self:Dock(TOP)
    self:SetText("")
    self.Avatar = self:Add("HNS.Avatar")
    self.Avatar:SetMouseInputEnabled(false)
    self.Scale = 2
end

function PANEL:Paint(w, h)
    -- Prevent lua error when player leaves
    if not IsValid(self.Player) then
        self:Remove()

        return
    end

    -- Blur
    local blurx, blury = self:LocalToScreen(0, 0)
    local scale = self.Scale
    render.SetScissorRect(blurx, blury, blurx + w, blury + h, true)
    surface.SetMaterial(self.Blur)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(-blurx, -blury, ScrW(), ScrH())
    render.SetScissorRect(0, 0, 0, 0, false)
    -- Background and outline
    surface.SetDrawColor(0, 0, 0, 125)
    surface.DrawRect(0, 0, w, h)
    self:BackgroundOverlayColor(w, h)
    surface.SetDrawColor(150, 150, 150, 255)
    surface.DrawOutlinedRect(0, 0, w, h)
    -- PFP fill and outline
    surface.DrawOutlinedRect(4 * scale - 1, 4 * scale - 1, 16 * scale + 2, 16 * scale + 2)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(4 * scale, 4 * scale, 16 * scale, 16 * scale)
    -- Player team and name
    self:ShadowedText(self:GetTeamName(), "HNSHUD.RobotoThin", 23 * scale, h / 2 - 4 * scale, self:GetTeamColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    self:ShadowedText(self.Player:Name(), "HNSHUD.RobotoThin", 23 * scale, h / 2 + 4 * scale, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    -- Ping
    self:ShadowedText("Ping", "HNSHUD.RobotoThin", w - 12 * scale, h / 2 - 4 * scale, self:GetTeamColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    self:ShadowedText(self.Player:Ping(), "HNSHUD.RobotoThin", w - 12 * scale, h / 2 + 4 * scale, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    -- Points (frags)
    self:ShadowedText("Points", "HNSHUD.RobotoThin", w - 44 * scale, h / 2 - 4 * scale, self:GetTeamColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    self:ShadowedText(self.Player:Frags(), "HNSHUD.RobotoThin", w - 44 * scale, h / 2 + 4 * scale, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Achievements master stars
    if self.Player.AchMaster then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.Star)
        surface.DrawTexturedRect(w / 2 - 8, h / 2 - 16, 16, 16)
        surface.DrawTexturedRect(w / 2 - 17, h / 2, 16, 16)
        surface.DrawTexturedRect(w / 2 + 1, h / 2, 16, 16)
    end
end

function PANEL:SetPlayer(ply)
    self.Player = ply
end

function PANEL:SetScale(scale)
    local size = floor(16 * 1.21 * scale)
    local frame_offset = floor((size - floor(16 * scale)) * 0.5)


    self.Scale = scale
    self:SetTall(24 * scale)
    self.Avatar:SetPos(floor(4 * scale) - frame_offset, floor(4 * scale) - frame_offset)
    self.Avatar:SetSize(size, size)
    self.Avatar:SetPlayer(self.Player, 16 * scale)
end

function PANEL:BackgroundOverlayColor(w, h)
    if self.Player == LocalPlayer() then
        surface.SetDrawColor(255, 255, 255, math.sin(CurTime() * 4) * 20 + 25)
        surface.DrawRect(0, 0, w, h)
    elseif self.Player.AchMaster then
        surface.SetDrawColor(255, 255, 0, math.sin(CurTime() * 4) * 20 + 25)
        surface.DrawRect(0, 0, w, h)
    end

    -- Hover
    GAMEMODE.DUtils.FadeHover(self, 1, 0, 0, w, h, ColorAlpha(self:GetTeamColor(), 50), 6)
end

-- Returns Playing when localplayer is a hider, returns team otherwise
function PANEL:GetTeamName()
    local text = ""

    -- Spectators do not need secrecy
    if self.Player:Team() == TEAM_SPECTATOR then
        text = "Spectating"
        -- Hiders cannot know what other people are
    elseif LocalPlayer():Team() == TEAM_HIDE and GAMEMODE.RoundState == ROUND_ACTIVE and not GAMEMODE.SeekerBlinded then
        text = "Playing"
    else
        text = team.GetName(self.Player:Team())
    end

    -- Effects
    if self.Player == LocalPlayer() then
        text = text .. " (You)"
    end

    if self.Player:IsMuted() then
        text = text .. " (Muted)"
    else
        local volume = self.Player:GetVoiceVolumeScale()
        if volume < 1 then
            text = string.format("%s (Volume: %s)", text, math.floor(volume * 100))
        end
    end

    return text
end

-- Similar to GetTeamName but with colors
function PANEL:GetTeamColor()
    if self.Player:Team() == TEAM_SPECTATOR then
        return Color(0, 175, 100)
    elseif LocalPlayer():Team() == TEAM_HIDE and GAMEMODE.RoundState == ROUND_ACTIVE and not GAMEMODE.SeekerBlinded then
        return Color(215, 215, 215)
    else
        return team.GetColor(self.Player:Team())
    end
end

function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
    draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0), alignx, aligny)

    return draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

function PANEL:DoClick()
    local menu = DermaMenu()
    hook.Run("HASScoreboardMenu", menu, self.Player)
    menu:AddSpacer()

    menu:AddOption("Copy Name", function()
        SetClipboardText(self.Player:Name())
    end):SetIcon("icon16/shield.png")

    menu:AddOption("Copy Steam ID (" .. self.Player:Name() .. ")", function()
        SetClipboardText(self.Player:SteamID())
    end):SetIcon("icon16/shield.png")

    menu:Open()
end

vgui.Register("HNS.ScoreboardPlayer", PANEL, "DButton")

local function resort()
    if IsValid(GAMEMODE.Scoreboard) then
        GAMEMODE.Scoreboard:UpdateDimentions()
    end
end

cvars.AddChangeCallback("has_hud_scale", resort, "HNS.ScoreboardUpdate")
cvars.AddChangeCallback("has_scob_sort_reversed", resort, "HNS.ScoreboardUpdate")