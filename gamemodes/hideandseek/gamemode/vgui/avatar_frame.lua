-- This is the avatar frame, without the avatar panel (so only the frame)
local PANEL = {}

function PANEL:Paint(w, h)
    if self.Material then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.Material)
        surface.DrawTexturedRect(0, 0, w, h)
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
        return
    elseif GAMEMODE.AvatarFrames[ply:SteamID64()] == false then
        return
    end

    -- Already saved
    local path = string.format("hns_avatarframes_cache/%s.png", ply:SteamID64())
    if file.Exists("hns_avatarframes_cache", "DATA") and file.Exists(path, "DATA") then
        GAMEMODE.AvatarFrames[ply:SteamID64()] = Material("data/" .. path)
        self.Material = GAMEMODE.AvatarFrames[ply:SteamID64()]
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
        end)
    end)
end

function PANEL:SetPlayer(ply)
    self.Ply = ply
    self:RequestFrame()
end

vgui.Register("HNS.AvatarFrame", PANEL, "DPanel")
