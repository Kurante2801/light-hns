local PANEL = {}

local COLOR_WHITE = Color(255, 255, 255)
local COLOR_GRAY = Color(255, 255, 255)

function PANEL:Init()
    self:SetScale(GAMEMODE.CVars.HUDScale:GetInt())
    self.Players = {}
end

function PANEL:Think()
    local scale = GAMEMODE.CVars.HUDScale:GetInt()
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

    self.Avatar = self:Add("HNS.Avatar")
end

function PANEL:Think()
    if not IsValid(self.Player) then
        self:Remove()
        return
    end

    local scale = GAMEMODE.CVars.HUDScale:GetInt()

    if scale ~= self.Scale then
        self:SetScale(scale)
    end

    if self.LastSpoke and CurTime() - self.LastSpoke > 3 then
        self:Remove()
    end
end

function PANEL:SetPlayer(ply)
    self.Player = ply
    self.Avatar:SetPlayer(ply, 32)
    self:SetScale(GAMEMODE.CVars.HUDScale:GetInt())
end

function PANEL:SetScale(scale)
    self.Scale = scale
    self:SetTall(24 * scale)
    self.Avatar:SetPos(4 * scale, 4 * scale)
    self.Avatar:SetSize(16 * scale, 16 * scale)
    self.Avatar:SetPlayer(self.Player, 16 * scale)
end

function PANEL:Paint(w, h)
    if not IsValid(self.Player) then return end

    local scale = GAMEMODE.CVars.HUDScale:GetInt()

    local blurx, blury = self:LocalToScreen(0, 0)
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
    -- PFP fill and outline
    surface.DrawOutlinedRect(4 * scale - 1, 4 * scale - 1, 16 * scale + 2, 16 * scale + 2)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(4 * scale, 4 * scale, 16 * scale, 16 * scale)

    self:ShadowedText(self.Player:Name(), "HNSHUD.RobotoThin", 23 * scale, h / 2 - 3 * scale, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    self:ShadowedText(self.Player:SteamID(), "HNSHUD.TahomaThin", 23 * scale + 1, h / 2 + 4 * scale, COLOR_GRAY, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
    draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0), alignx, aligny)

    return draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

vgui.Register("HNS.VoicePlayer", PANEL, "DPanel")