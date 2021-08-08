local PANEL = {}

function PANEL:Init()
    self:NoClipping(true)
    self.Avatar = self:Add("AvatarImage")
    self.Avatar:Dock(FILL)
    self.Avatar:SetPaintedManually(true)
end

function PANEL:Paint(w, h)
    self.Avatar:PaintManual()

    if self.Material then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.Material)
        surface.DrawTexturedRect(-self.OffsetX, -self.OffsetY, self.FrameW, self.FrameH)
    end
end

function PANEL:Think()
    if not IsValid(self.Ply) then return end

    if GAMEMODE.CVars.AvatarFrames:GetBool() then
        if not self.Material and not self.AttemptedFrame then
            self:RequestFrame()
        end
    elseif self.Material or self.AttemptedFrame then
        self.Material = nil
        self.AttemptedFrame = false
    end
end

function PANEL:RequestFrame()
    -- Attempt once
    self.AttemptedFrame = true
    local ply = self.Ply
    if ply:IsBot() then return end

    -- Already cached
    if GAMEMODE.AvatarFrames[ply:SteamID64()] then
        self.Material = GAMEMODE.AvatarFrames[ply:SteamID64()]
        self:HandleDimensions()
        return
    elseif GAMEMODE.AvatarFrames[ply:SteamID64()] == false then
        return
    end

    -- Already saved
    local path = string.format("hns_avatarframes_cache/%s.png", ply:SteamID64())
    if file.Exists("hns_avatarframes_cache", "DATA") and file.Exists(path, "DATA") then
        GAMEMODE.AvatarFrames[ply:SteamID64()] = Material("data/" .. path)
        self.Material = GAMEMODE.AvatarFrames[ply:SteamID64()]
        self:HandleDimensions()
        return
    end

    -- Get frame from steam profile
    -- Then save to data/
    http.Fetch("https://steamcommunity.com/profiles/" .. ply:SteamID64(), function(body)
        if not IsValid(self) or not IsValid(ply) then return end
        local _, _, url = string.find(body, [[<div class="profile_avatar_frame">%s*<img src="(.-)">]])

        if not url then
            GAMEMODE.AvatarFrames[ply:SteamID64()] = false
            return
        end

        http.Fetch(url, function(src)
            if not IsValid(self) or not IsValid(ply) then return end

            if not file.Exists("hns_avatarframes_cache", "DATA") then
                file.CreateDir("hns_avatarframes_cache")
            end

            file.Write(path, src)

            GAMEMODE.AvatarFrames[ply:SteamID64()] = Material("data/" .. path)
            self.Material = GAMEMODE.AvatarFrames[ply:SteamID64()]
            self:HandleDimensions()
        end)
    end)
end

function PANEL:HandleDimensions()
    local w, h = self:GetSize()
    local x, y = w, h

    w, h = math.floor(w * 1.22), math.floor(h * 1.22)
    -- Force power of two, frames may look ugly otherwise
    if w % 2 ~= 0 then
        w = w + 1
    end

    if h % 2 ~= 0 then
        h = h + 1
    end

    self.OffsetX, self.OffsetY = (w - x) / 2, (h - y) / 2
    self.FrameW, self.FrameH = w, h
end

function PANEL:SetPlayer(ply, size)
    self.Avatar:SetPlayer(ply, size)
    self.Ply, self.AvatarSize = ply, size

    self:RequestFrame()
end

vgui.Register("HNS.Avatar", PANEL, "DPanel")