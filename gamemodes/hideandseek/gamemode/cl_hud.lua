GM.HUDs = {}

GM.HUDs[1] = {
	Name = "Classic",
	Draw = function(this, ply, tint, stamina, timeLeft, roundText, blindTime)
		-- Player info and stamina container
		draw.RoundedBoxEx(16, 20, ScrH() - 80, 200, 80, Color(0, 0, 0, 200), true, true, false, false)
		-- Player info
		draw.SimpleTextOutlined(ply:Name(), "DermaDefaultBold", 32, ScrH() - 70, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))
		draw.SimpleTextOutlined(team.GetName(ply:Team()), "DermaDefault", 32, ScrH() - 56, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))
		-- Stamina
		if ply:Team() != TEAM_SPECTATOR then
			draw.RoundedBoxEx(16, 220, ScrH() - 48, 108, 32, Color(0, 0, 0, 200), false, true, false, true)
			draw.RoundedBox(12, 24, ScrH() - 44, 300, 24, Color(0, 0, 0, 200))
			draw.RoundedBox(12, 24, ScrH() - 44, stamina * 3, 24, ColorAlpha(tint, math.sin(CurTime() * 6) * 50 + 100))
		end

		-- Round indicators
		draw.RoundedBoxEx(16, 20, 0, 128, 72, Color(0, 0, 0, 200), false, false, true, true)
		draw.SimpleTextOutlined(timeLeft, "DermaLarge", 32, 24, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))
		draw.SimpleTextOutlined(roundText, "DermaDefault", 32, 48, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))

		-- Blind time
		if GAMEMODE.SeekerBlinded then
			draw.RoundedBoxEx(16, ScrW() / 2 - 100, 0, 200, 72, Color(0, 0, 0, 200), false, false, true, true)
			draw.SimpleTextOutlined((ply:Team() == TEAM_SEEK && "You" || team.NumPlayers(2) == 1 && "The seeker" || "The seekers") .. " will be unblinded in...", "DermaDefault", ScrW() / 2, 24, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))
			draw.SimpleTextOutlined(blindTime .. " seconds", "DermaDefault", ScrW() / 2, 40, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(10, 10, 10, 100))
		end
	end
}

GM.HUDs[2] = {
	Name = "Fafy",
	Draw = function(this, ply, tint, stamina, timeLeft, roundText, blindTime)
		-- Setting font with surface to get length
		surface.SetFont("HNS.HUD.Fafy.Name")
		this.BarWide, this.TextTall = surface.GetTextSize(ply:Name())
		this.BarWide = math.max(200, this.BarWide + 6)
		-- Drawing name shadow now that we used surface.SetFont
		surface.SetTextColor(0, 0, 0)
		surface.SetTextPos(84, ScrH() - 69 - this.TextTall / 2)
		surface.DrawText(ply:Name())

		-- Avatar image
		draw.RoundedBox(0, 15, ScrH() - 81, 66, 66, tint)
		draw.RoundedBox(0, 16, ScrH() - 80, 64, 64, Color(0, 0, 0))
		this.Avatar:PaintManual()

		-- Player name
		draw.RoundedBox(0, 81, ScrH() - 81, this.BarWide, 24, Color(0, 0, 0, 125))
		draw.SimpleText(ply:Name(), "HNS.HUD.Fafy.Name", 83, ScrH() - 70, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		-- Player team
		this:ShadowedText(team.GetName(ply:Team()), "DermaDefaultBold", 85, ScrH() - 50, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		-- Round and timer bars
		draw.RoundedBox(0, 15, 15, 125, 40, Color(0, 0, 0, 125))
		draw.RoundedBox(0, 15, 60, 125, 20, Color(0, 0, 0, 125))

		-- Round and timer texts
		this:ShadowedText(timeLeft, "HNS.HUD.Fafy.Timer", 76, 34, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		this:ShadowedText(roundText, "DermaDefaultBold", 78, 69, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if GAMEMODE.SeekerBlinded then
			draw.RoundedBox(0, ScrW() / 2 - 100, 15, 200, 50, Color(0, 0, 0, 125))
			this:ShadowedText((ply:Team() == TEAM_SEEK && "You" || team.NumPlayers(2) == 1 && "The seeker" || "The seekers") .. " will be unblinded in...", "DermaDefaultBold", ScrW() / 2, 26, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			this:ShadowedText(blindTime, "HNS.HUD.Fafy.Timer", ScrW() / 2, 47, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-- Stamina bar
		if ply:Team() == TEAM_SPECTATOR then
			this:ShadowedText("Press F2 to join the game!", "DermaDefaultBold", 85, ScrH() - 36, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
			draw.RoundedBox(0, 81, ScrH() - 39, this.BarWide, 24, Color(0, 0, 0, 175))
			draw.RoundedBox(0, 83, ScrH() - 37, (this.BarWide - 4) * stamina / 100, 20, ColorAlpha(tint, math.sin(CurTime() * 4) * 60 + 120))
		end
	end,
	AvatarFunc = function(this)
		this.Avatar = vgui.Create("AvatarImage")
		this.Avatar:SetPos(16, ScrH() - 80)
		this.Avatar:SetSize(64, 64)
		this.Avatar:SetPlayer(LocalPlayer(), 64)
		this.Avatar:SetPaintedManually(true)
		this.Avatar:MoveToBack()
	end,
	ShadowedText = function(this, text, font, x, y, color, aX, aY, shadow, oX, oY)
		draw.SimpleText(text, font, (x || 0) + (oX || 1), (y || 0) + (oY || 1), shadow || Color(0, 0, 0), aX, aY)
		draw.SimpleText(text, font, x, y, color, aX, aY)
	end
}

GM.HUDs[3] = {
	Name = "Compact",
	Draw = function(this, ply, tint, stamina, timeLeft, roundText, blindTime)
		-- So much for a border
		surface.SetDrawColor(tint)
		surface.DrawLine(20, ScrH() - 120, 20, ScrH() - 20)
		surface.DrawLine(330, ScrH() - 120, 330, ScrH() - 20)
		surface.DrawLine(20, ScrH() - 20, 330, ScrH() - 20)
		surface.DrawLine(20, ScrH() - 120, 330, ScrH() - 120)

		-- Stamina
		if ply:Team() != TEAM_SPECTATOR then
			-- Black back
			draw.RoundedBox(0, 25, ScrH() - 50, 300, 25, Color(0, 0, 0, 215))
			-- Tinted bar
			draw.RoundedBox(0, 25, ScrH() - 50, stamina * 3, 25, tint)
		end
		-- Background
		draw.RoundedBox(0, 20, ScrH() - 120, 310, 100, ColorAlpha(tint, 5))
		-- Player name
		draw.SimpleTextOutlined(ply:Name(), "HNS.HUD.Fafy.Name", 25, ScrH() - 65, tint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))
		-- Player team
		draw.SimpleTextOutlined(team.GetName(ply:Team()), "HNS.HUD.Fafy.Name", 325, ScrH() - 65, tint, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))
		-- Time remaining and round count
		draw.SimpleTextOutlined(timeLeft, "HNS.HUD.Fafy.Timer", 25, ScrH() - 106, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))
		draw.SimpleTextOutlined(roundText, "HNS.HUD.Fafy.Name", 25, ScrH() - 85, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))
		-- Time until seeker is unblinded
		if GAMEMODE.SeekerBlinded then
			draw.SimpleTextOutlined((ply:Team() == 1 && "Hide" || ply:Team() == 2 && "Wait" || "Start in") .. ": " .. blindTime, "HNS.HUD.Fafy.Name", 325, ScrH() - 85, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(10, 10, 10, 100))
		end
	end
}


GM.HUDs[4] = {
	Name = "Cinematic",
	Draw = function() end
}

-- Draw HUD
GM.SelectedHUD = GM.HUDs[GM.CVars.HUD:GetInt()] || GM.HUDs[2]
GM.HiderColor = GM:GetTeamShade(TEAM_HIDE, GM.CVars.HiderColor:GetString())
GM.SeekerColor = GM:GetTeamShade(TEAM_SEEK, GM.CVars.SeekerColor:GetString())

local function GetDrawColor()
	if LocalPlayer():Team() == TEAM_HIDE then
		return GAMEMODE:GetTeamShade(TEAM_HIDE, GAMEMODE.CVars.HiderColor:GetString())
	elseif LocalPlayer():Team() == TEAM_SEEK then
		return GAMEMODE:GetTeamShade(TEAM_SEEK, GAMEMODE.CVars.SeekerColor:GetString())
	else
		return team.GetColor(LocalPlayer():Team())
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

local speed, rayEnt, lastLooked, lookedTime, lookedColor

function GM:HUDPaint()
	-- Blind (combined with render hook)
	if self.SeekerBlinded && LocalPlayer():Team() == TEAM_SEEK then
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0))
	end

	self.SelectedHUD = self.HUDs[self.CVars.HUD:GetInt()] || self.HUDs[2]
	-- Create avatar
	if self.SelectedHUD.AvatarFunc && !self.SelectedHUD.Avatar then
		self.SelectedHUD:AvatarFunc()
	end
	-- Draw HUD
	self.SelectedHUD:Draw(LocalPlayer(), GetDrawColor(), self.Stamina, string.ToMinutesSeconds(self.TimeLeft), GetRoundText(), self.TimeLeft - self.RoundLength)

	-- Stuck prevention
	if LocalPlayer():GetCollisionGroup() == COLLISION_GROUP_WEAPON then
		draw.SimpleTextOutlined("Stuck Prevention Enabled", "HNS.HUD.Fafy.Name", ScrW() / 2, ScrH() / 2 + 120, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
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
		speed = LocalPlayer():GetVelocity():Length2D()

		draw.RoundedBox(6, self.CVars.SpeedX:GetInt() - 45, self.CVars.SpeedY:GetInt() - 28, 90, 56, Color(0, 0, 0, speed > 0 && 200 || 100))

		draw.SimpleText("SPEED", "HNS.HUD.DR.Medium", self.CVars.SpeedX:GetInt(), self.CVars.SpeedY:GetInt() - 14, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(math.Round(speed), "HNS.HUD.DR.Big", self.CVars.SpeedX:GetInt(), self.CVars.SpeedY:GetInt() + 10, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	-- Fade out names
	rayEnt = LocalPlayer():GetEyeTrace().Entity
	if !IsValid(LocalPlayer():GetObserverTarget()) && IsValid(rayEnt) && rayEnt:IsPlayer() && (self.RoundState != ROUND_ACTIVE || rayEnt:GetPos():DistToSqr(LocalPlayer():GetPos()) <= 302500) then
		-- From murder gamemode
		lastLooked = rayEnt
		lookedTime = CurTime()
	end

	-- Draw name
	if IsValid(lastLooked) && lookedTime + 2 > CurTime() then
		lookedColor = ColorAlpha(team.GetColor(lastLooked:Team()), (1 - (CurTime() - lookedTime) / 2) * 255)
		draw.SimpleTextOutlined(lastLooked:Name(), "DermaLarge", ScrW() / 2, ScrH() / 2 + 50, lookedColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, lookedColor.a))
		draw.SimpleTextOutlined(team.GetName(lastLooked:Team()), "DermaDefaultBold", ScrW() / 2, ScrH() / 2 + 70, lookedColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, lookedColor.a))
		if self.CVars.ShowID:GetBool() then
			draw.SimpleTextOutlined(lastLooked:SteamID(), "DermaDefaultBold", ScrW() / 2, ScrH() / 2 + 84, lookedColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, lookedColor.a))
		end
	end
end

-- Hide elements
local hide = {
	["CHudWeaponSelection"] = true,
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudPoisonDamageIndicator"] = true,
	["CHudZoom"] = true,
}

function GM:HUDShouldDraw(element)
	return !hide[element]
end

-- Blind time
local mods = {
	["pp_colour_addr "] = -1,
	["pp_colour_addg "] = -1,
	["pp_colour_addb "] = -1,
	["pp_colour_brightness"] = -1,
	["pp_colour_colour"] = 0,
	["pp_colour_contrast"] = 1.4,
	["pp_colour_mulr"] = -1,
	["pp_colour_mulg"] = -1,
	["pp_colour_mulb"] = -1,
}

function GM:RenderScreenspaceEffects()
	if self.SeekerBlinded && LocalPlayer():Team() == TEAM_SEEK then
		DrawColorModify(mods)
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