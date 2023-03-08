COLOR_WHITE = Color(255, 255, 255)
COLOR_HNS_TAG = Color(150, 100, 200)

GM.HiderColors = {
    ["Default"] = Color(0, 50, 175),
    ["Shark"] = Color(75, 150, 225),
    ["Full Blue"] = Color(0, 0, 255),
    ["Dark Blue"] = Color(0, 0, 175),
    ["Cyan"] = Color(0, 255, 255),
    ["Light Blue"] = Color(20, 130, 200),
    ["Purple"] = Color(100, 0, 255)
}

GM.SeekerColors = {
    ["Default"] = Color(175, 75, 50),
    ["Full Red"] = Color(255, 0, 0),
    ["Dark Red"] = Color(175, 0, 0),
    ["Crimson"] = Color(220, 20, 60),
    ["Pink"] = Color(255, 105, 180),
    ["Rose"] = Color(255, 0, 130),
    ["Orange"] = Color(255, 125, 0),
}

-- Get a valid color shade for a team
-- team, key
function GM:GetTeamShade(t, k)
    if t == TEAM_HIDE then
        -- If the key is an invalid color, just return the default one
        return self.HiderColors[k] or self.HiderColors.Default
    elseif t == TEAM_SEEK then
        return self.SeekerColors[k] or self.SeekerColors.Default
    else
        -- Throw error to identify issues
        error("Invalid team! (Got: " .. t .. ")")
    end
end

-- Wrapper for GM:GetTeamShade
function GM:GetPlayerTeamColor(ply)
    if ply:Team() == TEAM_HIDE then
        return self:GetTeamShade(TEAM_HIDE, ply:GetNWString("has_hidercolor", "Default"))
    elseif ply:Team() == TEAM_SEEK then
        return self:GetTeamShade(TEAM_SEEK, ply:GetNWString("has_seekercolor", "Default"))
    end
end

-- I didn't know this function existed, which is why the previous functions exist
function GM:GetTeamColor(ply)
    return self:GetPlayerTeamColor(ply) or team.GetColor(ply:Team())
end