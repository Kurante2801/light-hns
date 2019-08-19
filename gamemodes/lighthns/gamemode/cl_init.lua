-- Create local cvars for customization
GM.CVars = GM.CVars || {}
GM.CVars.HUD = CreateClientConVar("has_hud", 1, true, false)
GM.CVars.HiderColor = CreateClientConVar("has_hidercolor", "Default", true, true)
GM.CVars.SeekerColor = CreateClientConVar("has_seekercolor", "Default", true, true)
GM.CVars.Gender = CreateClientConVar("has_gender", 0, true, true)
GM.CVars.ShowID = CreateClientConVar("has_showid", 1, true, false)
GM.CVars.CrosshairEnable = CreateClientConVar("has_crosshair_enable", "0", true, false)
GM.CVars.CrosshairColor = CreateClientConVar("has_crosshair_color", "55 215 75 225", true, false)
GM.CVars.CrosshairSize = CreateClientConVar("has_crosshair_size", 8, true, false)
GM.CVars.CrosshairGap = CreateClientConVar("has_crosshair_gap", 6, true, false)
GM.CVars.CrosshairThick = CreateClientConVar("has_crosshair_thick", 4, true, false)

-- Includes
include("sh_init.lua")
include("cl_fonts.lua")
include("cl_hud.lua")

-- Receive a chat message from gamemode
net.Receive("HNS.Say", function()
	local sayTable = net.ReadTable()
	chat.AddText(unpack(sayTable))
end)
-- Play sounds
net.Receive("HNS.PlaySound", function()
	local path = net.ReadString()
	surface.PlaySound(path)
end)

-- Stamina manager
GM.Stamina = 100
function GM:Tick()
	-- Blind time check
	GAMEMODE.SeekerBlind = timer.Exists("")

	-- Stop sprinting
	if self.Stamina <= 0 then
		RunConsoleCommand("-speed")
	end

	-- Show spectators
	for _, ply in ipairs(player.GetAll()) do
		-- If we shouldn't be able to see the camera
		if !IsValid(ply) || ply:Team() != TEAM_SPECTATOR || ply  == LocalPlayer() || (ply:Team() != TEAM_SPECTATOR && (!LocalPlayer():IsAdmin() && !LocalPlayer():IsUserGroup("trialadmin"))) then
			-- If camera exists, delete it
			if IsValid(ply.SpecCamera) then
				ply.SpecCamera:Remove()
			end
		-- If we should see the camrea
		else
			-- If camera doesn't exist, create it
			if !IsValid(ply.SpecCamera) then
				ply.SpecCamera = ents.CreateClientProp("models/dav0r/camera.mdl")
			end
			ply.SpecCamera:SetPos(ply:EyePos())
			ply.SpecCamera:SetAngles(ply:EyeAngles())
		end
	end
end

function GM:PostDrawOpaqueRenderables()
	-- Stop if we aren't spectating or aren't admins(while playing)
	if LocalPlayer():Team() != TEAM_SPECTATOR && !LocalPlayer():IsAdmin() && !LocalPlayer():IsUserGroup("trialadmin") then return end

	-- Draw spectators' names
	ang = LocalPlayer():EyeAngles()
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)
	col = ColorAlpha(team.GetColor(TEAM_SPECTATOR), 75)

	for _, ply in ipairs(team.GetPlayers(TEAM_SPECTATOR)) do
		-- Don't draw ourselves
		if ply == LocalPlayer() then continue end

		-- Draw a text above head
		cam.Start3D2D(ply:EyePos() + Vector(0, 0, 24), Angle(0, ang.y, 90), 0.075)
			draw.SimpleTextOutlined(ply:Name(), "HNS.HUD.DR.Large", 0, 0, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0, 0, 0, 125))
			draw.SimpleTextOutlined(ply:SteamID(), "HNS.HUD.DR.Spec", 0, 54, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0, 0, 0, 125))
		cam.End3D2D()
	end
end

function GM:KeyPress(ply, key)
	if ply != LocalPlayer() then return end
	-- Scoreboard
	if key == IN_ATTACK2 && ply:KeyDown(IN_SCORE) && IsValid(self.Scoreboard) then
		self.Scoreboard:MakePopup()
	end
	-- Stamina
	if key == IN_SPEED then
		if self.Stamina <= 0 || ply:Team() == TEAM_SPECTATOR then return end

		if ply:GetVelocity():Length2D() >= 65 then
			self.Stamina = math.Clamp(self.Stamina - 1, 0, 100)
		end
		-- Stop regen
		timer.Remove("HNS.StaminaRegen")
		timer.Remove("HNS.StaminaDelay")
		-- Drain stamina
		timer.Create("HNS.StaminaDrain", 0.055, 0, function()
			if ply:GetVelocity():Length2D() >= 65 then
				self.Stamina = math.Clamp(self.Stamina - 1, 0, 100)
			end
		end)
	end
end

function GM:KeyRelease(ply, key)
	if ply != LocalPlayer() then return end

	if key == IN_SPEED then
		-- Stop drain
		timer.Remove("HNS.StaminaDrain")
		-- Create delay
		timer.Create("HNS.StaminaDelay", 2, 1, function()
				timer.Create("HNS.StaminaRegen", 0.05, 0, function()
				self.Stamina = math.Clamp(self.Stamina + 0.4, 0, 100)
				-- Stop regenerating after we reach 100
				if self.Stamina >= 100 then
					timer.Remove("HNS.StaminaRegen")
				end
			end)
		end)
	end
end