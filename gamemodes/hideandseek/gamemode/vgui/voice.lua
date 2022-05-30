local floor = math.floor
local ceil = math.ceil
local PANEL = {}

local COLOR_WHITE = Color(255, 255, 255)
local COLOR_GRAY = Color(215, 215, 215)

function PANEL:Init()
    self:SetScale(GAMEMODE.CVars.HUDScale:GetFloat())
    self:DockPadding(0, 0, 0, 0)
    self.Players = {}
end

function PANEL:Think()
    local scale = GAMEMODE.CVars.HUDScale:GetFloat()
    if self.Scale ~= scale then
        self:SetScale(scale)
    end
end

function PANEL:SetScale(scale)
    self.Scale = scale

    self:SetSize(125 * scale, ScrH() - 50 * scale)
    self:SetPos(ScrW() - 133 * scale, 0)
end

function PANEL:Paint(w, h)
end

vgui.Register("HNS.VoiceContainer", PANEL, "DPanel")

PANEL = {}

function PANEL:Init()
    self:Dock(BOTTOM)
    self.Blur = GAMEMODE.BlurMaterial

    self.LastSegment = CurTime()
    self.Avatar = self:Add("HNS.Avatar")
    self.Segments = {}
end

function PANEL:Think()
    if not IsValid(self.Player) then
        self:Remove()
        return
    end

    local scale = GAMEMODE.CVars.HUDScale:GetFloat()

    -- Resize when scale changes
    if scale ~= self.Scale then
        self:SetScale(scale)
    end

    local time = CurTime()

    -- Fade out and remove when not spoken for > 3 secs
    if self.LastSpoke then
        local left = time - self.LastSpoke

        self:SetAlpha(255 - left / 3 * 255)

        if left > 3 then
            self:Remove()
        end
    else
        self:SetAlpha(255)
    end

    -- Segments
    if self.CanGraph and time - self.LastSegment  > 0.10 / scale then
        table.insert(self.Segments, { t = time, v = self.Player:VoiceVolume() })
        self.LastSegment = time
    end

    -- Remove segments here, otherwise we get many errors in the draw hook
    -- We remove segments when they're off the panel and are not drawn
    for i = 1, #self.Segments do
        local seg = self.Segments[i]
        if not seg then continue end

        if (CurTime() - seg.t) * 125 / 3 * scale > 130 * scale then
            table.remove(self.Segments, i)
            i = i - 1
        end
    end
end

function PANEL:SetPlayer(ply)
    self.Player = ply
    self.Avatar:SetPlayer(ply, 32)
    self:SetScale(GAMEMODE.CVars.HUDScale:GetFloat())

    self.CanGraph = ply ~= LocalPlayer() or GAMEMODE.CVars.VoiceLoopback:GetBool()
end

function PANEL:SetScale(scale)
    local size = floor(16 * 1.21 * scale)
    local frame_offset = floor((size - floor(16 * scale)) * 0.5)

    self.Scale = scale
    self:SetTall(24 * scale)
    self:DockMargin(0, 2 * scale, 0, 0)
    self.Avatar:SetPos(4 * scale - frame_offset, 4 * scale - frame_offset)
    self.Avatar:SetSize(size, size)
    self.Avatar:SetPlayer(self.Player, 16 * scale)
end

function PANEL:Paint(w, h)
    if not IsValid(self.Player) then return end

    local scale = GAMEMODE.CVars.HUDScale:GetFloat()

    local blurx, blury = self:LocalToScreen(0, 0)
    render.SetScissorRect(blurx, blury, blurx + w, blury + h, true)
    surface.SetMaterial(self.Blur)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(-blurx, -blury, ScrW(), ScrH())
    render.SetScissorRect(0, 0, 0, 0, false)
    -- Fill and outline
    surface.SetDrawColor(0, 0, 0, 125)
    surface.DrawRect(0, 0, w, h)

    --self:BarGraph(w, h, scale)
    self:LineGraph(w, h, scale)

    surface.SetDrawColor(150, 150, 150, 255)
    surface.DrawOutlinedRect(0, 0, w, h)


    -- PFP fill and outline
    surface.DrawOutlinedRect(4 * scale - 1, 4 * scale - 1, 16 * scale + 2, 16 * scale + 2)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(4 * scale, 4 * scale, 16 * scale, 16 * scale)

    if GAMEMODE.CVars.ShowID:GetBool() then
        self:ShadowedText(self.Player:Name(), "HNSHUD.RobotoThin", 23 * scale, h / 2 - 3 * scale, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        self:ShadowedText(self.Player:SteamID(), "HNSHUD.TahomaThin", 23 * scale + 1, h / 2 + 4 * scale, COLOR_GRAY, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
        self:ShadowedText(self.Player:Name(), "HNSHUD.RobotoThin", 23 * scale, h / 2, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:BarGraph(w, h, scale)
    for i = 1, #self.Segments do
        local seg = self.Segments[i]
        if not seg then continue end

        local x = (CurTime() - seg.t) * 125 / 3 * scale

        if x > 125 * scale then
            table.remove(self.Segments, i)
            i = i - 1
        else
            local tint = GAMEMODE:GetPlayerTeamColor(self.Player) or team.GetColor(self.Player:Team())
            local tall = seg.v * 50 * scale

            surface.SetDrawColor(tint.r, tint.g, tint.b, 255)
            surface.DrawRect(w - x, h - tall, 1 * scale, tall)
        end
    end
end

function PANEL:LineGraph(w, h, scale)
    for i, seg in ipairs(self.Segments) do
        if i < 2 or i >= #self.Segments then continue end
        local segLast = self.Segments[i - 1]
        if not segLast then continue end

        local x1 = w - (CurTime() - seg.t - 0.1) * 125 / 3 * scale
        local x2 = w - (CurTime() - segLast.t - 0.1) * 125 / 3 * scale
        local tall1 = h - segLast.v * 50 * scale
        local tall2 = h - seg.v * 50 * scale
        local tint = GAMEMODE:GetPlayerTeamColor(self.Player) or team.GetColor(self.Player:Team())

        -- Background
        draw.NoTexture()
        surface.SetDrawColor(tint.r, tint.g, tint.b, 125)
        surface.DrawPoly({
            { x = x2, y = h },
            { x = x2, y = tall1 },
            { x = x1, y = tall2 },
            { x = x1, y = h },
        })

        surface.SetDrawColor(tint.r, tint.g, tint.b, 255)
        surface.DrawLine(x2, tall1, x1, tall2)
    end
end

function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
    draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0), alignx, aligny)

    return draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

vgui.Register("HNS.VoicePlayer", PANEL, "DPanel")