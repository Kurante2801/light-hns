-- Shared utils
GM.DUtils = {}

GM.DUtils.FadeHover = function(panel, id, x, y, w, h, color, speed, func)
    color = color or Color(255, 255, 255)
    surface.SetDrawColor(ColorAlpha(color, GAMEMODE.DUtils.LerpNumber(panel, id, 0, color.a, speed, func)))
    surface.DrawRect(x, y, w, h)
end

GM.DUtils.LerpNumber = function(panel, id, value1, value2, speed, func)
    -- Lerps don't exist yet
    if not panel.Lerps then
        panel.Lerps = {}
    end

    -- ID lerp doesn't exist
    if not panel.Lerps[id] then
        panel.Lerps[id] = value1
    end

    speed = speed or 6
    func = func or function(s) return s:IsHovered() end
    panel.Lerps[id] = Lerp(FrameTime() * speed, panel.Lerps[id], func(panel) and value2 or value1)

    return panel.Lerps[id]
end

GM.DUtils.Outline = function(x, y, w, h, thick, color)
    surface.SetDrawColor(color)

    for i = 0, thick - 1 do
        surface.DrawOutlinedRect(x + i, y + i, w - 2 * i, h - 2 * i)
    end
end

local PANEL = {}

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

function PANEL:Think()
    if GAMEMODE.CVars.AvatarFrames:GetBool() then
        if not self.Material and not self.AttemptedFrame then
            self:HandleFrame()
        end
    elseif self.Material then
        self:HandleFrame()
    end
end

function PANEL:SetPlayer(ply, size)
    self.Avatar:SetPlayer(ply, size)
    self.Ply, self.AvatarSize = ply, size

    self:HandleFrame()
end

function PANEL:HandleFrame()
    local ply, size = self.Ply, self.AvatarSize

    -- Can we see frames
    if not GAMEMODE.CVars.AvatarFrames:GetBool() then
        self:SetSize(size, size)
        self:DockPadding(0, 0, 0, 0)

        if self.Padding then
            local x, y = self:GetPos()
            self:SetPos(x + self.Padding, y + self.Padding)
        end

        self.Material = nil
        self.Padding = nil
        self.AttemptedFrame = false
        return
    end

    -- Attempt once
    self.AttemptedFrame = true

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
    local size = self.AvatarSize
    local frameSize = math.floor(size * 1.22)
    -- Force power of two, frames may look ugly otherwise
    if frameSize % 2 ~= 0 then
        frameSize = frameSize + 1
    end

    self:SetSize(frameSize, frameSize)

    local padding = (frameSize - size) / 2
    self:DockPadding(padding, padding, padding, padding)

    local x, y = self:GetPos()
    self:SetPos(x - padding, y - padding)

    self.Padding = padding
end

vgui.Register("HNS.Avatar", PANEL, "DPanel")