-- Create local cvars for customization
GM.CVars = GM.CVars || {}
GM.CVars.HUD = CreateClientConVar("has_hud", 2, true, false)
GM.CVars.HiderColor = CreateClientConVar("has_hidercolor", "Default", true, true)
GM.CVars.SeekerColor = CreateClientConVar("has_seekercolor", "Default", true, true)
GM.CVars.Gender = CreateClientConVar("has_gender", 0, true, true)
GM.CVars.ShowID = CreateClientConVar("has_showid", 1, true, false)
GM.CVars.ShowOnTop = CreateClientConVar("has_scob_ontop", 0, true, false)
GM.CVars.Sort = CreateClientConVar("has_scob_sort", 1, true, false)
GM.CVars.ShowSpeed = CreateClientConVar("has_showspeed", 0, true, false)
GM.CVars.SpeedX = CreateClientConVar("has_speedx", 45, true, false)
GM.CVars.SpeedY = CreateClientConVar("has_speedy", 30, true, false)
GM.CVars.CrosshairEnable = CreateClientConVar("has_crosshair_enable", "0", true, false)
GM.CVars.CrosshairR = CreateClientConVar("has_crosshair_r", 55, true, false)
GM.CVars.CrosshairG = CreateClientConVar("has_crosshair_g", 215, true, false)
GM.CVars.CrosshairB = CreateClientConVar("has_crosshair_b", 75, true, false)
GM.CVars.CrosshairA = CreateClientConVar("has_crosshair_a", 225, true, false)
GM.CVars.CrosshairSize = CreateClientConVar("has_crosshair_size", 8, true, false)
GM.CVars.CrosshairGap = CreateClientConVar("has_crosshair_gap", 6, true, false)
GM.CVars.CrosshairThick = CreateClientConVar("has_crosshair_thick", 4, true, false)

-- Includes
include("sh_init.lua")
include("cl_fonts.lua")
include("cl_hud.lua")
include("tdlib.lua")
include("cl_derma.lua")
include("sh_achievements_table.lua")

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

net.Receive("HNS.StaminaChange", function()
	local sta = net.ReadInt(8)
	GAMEMODE.Stamina = math.Clamp(GAMEMODE.Stamina + sta, 0, 100)
end)

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

function GM:PlayerBindPress(ply, bind)
	-- Safe check
	if ply != LocalPlayer() then return end

	-- Team selection menu
	if bind == "gm_showteam" then
		vgui.Create("HNS.F2.Derma")
	elseif bind == "gm_showhelp" then
		vgui.Create("HNS.F1.Derma")
	end
end

function GM:ScoreboardShow()
	if !IsValid(self.Scoreboard) then
		self.Scoreboard = vgui.Create("HNS.Scoreboard")
	end
	self.Scoreboard:Show()
	self.Scoreboard:UpdateList()
end

function GM:ScoreboardHide()
	if IsValid(self.Scoreboard) then
		self.Scoreboard:Hide()
	end
end

-- Update playercolor
local function PlayerColorUpdate()
	net.Start("HNS.PlayerColorUpdate")
	net.SendToServer()
end
cvars.AddChangeCallback("has_hidercolor", PlayerColorUpdate)
cvars.AddChangeCallback("has_seekercolor", PlayerColorUpdate)

-- Receive an achievements master
net.Receive("HNS.AchievementsMaster", function()
	local ply = net.ReadEntity()
	ply.AchMaster = true
end)

-- Receive achievements progress
net.Receive("HNS.AchievementsProgress", function()
	GAMEMODE.AchievementsProgress = net.ReadTable()
end)

-- Receive an achievement
net.Receive("HNS.AchievementsGet", function()
	local ply = net.ReadEntity()
	local id = net.ReadString()

	-- Chat
	chat.AddText(COLOR_WHITE, "[", Color(125, 255, 125), "HNS", COLOR_WHITE, "] ", ply, COLOR_WHITE, " has earned ", Color(125, 255, 125), GAMEMODE.Achievements[id].Name, COLOR_WHITE, ".")
	-- Sound
	ply:EmitSound("misc/achievement_earned.wav")
	-- Create particles

	ParticleEffectAttach("bday_confetti", PATTACH_ABSORIGIN_FOLLOW, ply, 0)

	local data = EffectData()
	data:SetOrigin(ply:GetPos())
	util.Effect("PhyscannonImpact", data)

	-- Persistent
	timer.Create("HNS.AchParticles1." .. ply:EntIndex(), 0.3, 10, function()
		if !IsValid(ply) then return end

		ParticleEffectAttach("bday_confetti", PATTACH_ABSORIGIN_FOLLOW, ply, 0)
		local data1 = EffectData()
		data1:SetOrigin(ply:GetPos())
		util.Effect("PhyscannonImpact", data1)
	end)

	timer.Create("HNS.AchParticles2." .. ply:EntIndex(), 0.1, 50, function()
		if !IsValid(ply) then return end

		ParticleEffectAttach("bday_confetti_colors", PATTACH_ABSORIGIN_FOLLOW, ply, 0)
		local data2 = EffectData()
		data2:SetOrigin(ply:GetPos())
		util.Effect("PhyscannonImpact", data2)
	end)
end)

hook.Add("OnPlayerChat", "HNS.Commands", function(ply, text)
	-- Using hooks instead of a function in case there's an addon overriting the gamemode function
	text = string.lower(text)

	-- HUD - Interface section
	if text == "!hnshud" || text == "!hnsmenu" then
		if ply == LocalPlayer() then
			vgui.Create("HNS.Prefs.Derma")
		end
		return true
	end
	-- Playercolors
	if text == "!hnscolors" || text == "!hnscolours" then
		if ply == LocalPlayer() then
			vgui.Create("HNS.Prefs.Derma").Tabs:SwitchToName("Player Model")
		end
		return true
	end
end, HOOK_HIGH)