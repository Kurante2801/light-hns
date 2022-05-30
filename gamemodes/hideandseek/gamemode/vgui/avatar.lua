-- Panel size should be: x * 1.22 where x is one of 16, 32, 64, 128, etc
local PANEL = {}

PANEL.PaddingMultiplier = 1.22

function PANEL:Init()
    self.Avatar = self:Add("AvatarImage")
    self.Avatar:Dock(FILL)
    self.Avatar:SetPaintedManually(true)
end

function PANEL:Paint(w, h)
    self.Avatar:PaintManual()

    if self.Material then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.Material)
        surface.DrawTexturedRect(0, 0, w, h)
    end
end

function PANEL:PerformLayout(w, h)
    self.PaddingX = (w - w / self.PaddingMultiplier) * 0.5
    self.PaddingY = (h - h / self.PaddingMultiplier) * 0.5
    self:DockPadding(self.PaddingX, self.PaddingY,self.PaddingX, self.PaddingY)
end

function PANEL:SetPlayer(ply, size)
    self.Avatar:SetPlayer(ply, size)
    self.Ply, self.AvatarSize = ply, size

    self:RequestFrame()
end

vgui.Register("HNS.Avatar", PANEL, "HNS.AvatarFrame")