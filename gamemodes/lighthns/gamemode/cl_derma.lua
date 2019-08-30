local PANEL = {}

function PANEL:Init()
	self:SetSize(306, 178)
	self:Center()
	self:MakePopup()
	self:SetTitle("Team selection")
	self:SetBackgroundBlur(true)
	self:DockPadding(0, 0, 0, 0)
	-- Overriding Paint() breaks BackgroundBlur
	self.PP = self:Add("DPanel") -- PaintPanel
	self.PP:MoveToBack()
	self.PP:Dock(FILL)
	self.PP.Paint = function(this, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
		draw.RoundedBox(0, 0, 0, w, 24, Color(25, 25, 25))
	end
	-- Buttons
	self.Play = self:Add("DButton")
	self.Play:SetPos(2, 26)
	self.Play:SetSize(150, 150)
	self.Play:TDLib() -- Styling
		:ClearPaint():Outline(Color(220, 20, 60), 2):FillHover(Color(220, 20, 60), LEFT):Text("")
		:On("PaintOver", function(this, w, h)
			draw.SimpleText("PLAY!", "HNS.HUD.Fafy.Timer", w / 2, h / 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("PLAY!", "HNS.HUD.Fafy.Timer", w / 2 - 1, h / 2 - 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end)
		-- Send net and close
		:NetMessage("HNS.JoinPlaying", function() self:Close() end)

	self.Spec = self:Add("DButton")
	self.Spec:SetPos(154, 26)
	self.Spec:SetSize(150, 150)
	self.Spec:TDLib() -- Styling
		:ClearPaint():Outline(Color(0, 175, 100), 2):FillHover(Color(0, 175, 100), RIGHT):Text("")
		:On("PaintOver", function(this, w, h)
			draw.SimpleText("SPECTATE", "HNS.HUD.Fafy.Timer", w / 2, h / 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("SPECTATE", "HNS.HUD.Fafy.Timer", w / 2 - 1, h / 2 - 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end)
		-- Send net and close
		:NetMessage("HNS.JoinSpectating", function() self:Close() end)
end

vgui.Register("HNS.F2.Derma", PANEL, "DFrame")

PANEL = {}

function PANEL:Init()
	self:SetSize(400, 260)
	self:Center()
	self:MakePopup()

	self:SetTitle("GFL | Hide and Seek")

	self.Text = self:Add("DLabel")
	self.Text:SetPos(12, 34)
	self.Text:SetContentAlignment(7)
	self.Text:SetFont("DermaDefault")
	self.Text:SetText("Welcome to GFL Hide and Seek! \n\nHow to play:\nHiders (blue team) have to avoid the Seekers until the round ends to win.\nSeekers (red team) have to tag (touch) all Hiders to win the round.\n\nKeys:\nF1 = Open this window.\nF2 = Change teams.\nR = Play a taunt")
	self.Text:SizeToContents()
	-- Play button
	self.Play = self:Add("DButton")
	self.Play:SetPos(8, 182)
	self.Play:SetSize(188, 70)
	self.Play:TDLib() -- Styling
		:ClearPaint():Outline(Color(220, 20, 60), 2):FillHover(Color(220, 20, 60), LEFT):Text("")
		:On("PaintOver", function(this, w, h)
			draw.SimpleText("Let's Play!", "HNS.HUD.Fafy.Timer", w / 2, h / 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Let's Play!", "HNS.HUD.Fafy.Timer", w / 2 - 1, h / 2 - 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end):On("DoClick", function(this)
			self:Close()
			-- Open once
			if !GAMEMODE.TeamSelectionOpenedFromF1 then
				GAMEMODE.TeamSelectionOpenedFromF1 = true
				vgui.Create("HNS.F2.Derma")
			end
		end)

	-- Preferences panel
	self.Prefs = self:Add("DButton")
	self.Prefs:SetPos(204, 182)
	self.Prefs:SetSize(188, 31)
	self.Prefs:TDLib() -- Styling
		:ClearPaint():Outline(Color(0, 255, 255), 2):FillHover(Color(0, 255, 255), TOP):Text(""):On("PaintOver", function(this, w, h)
			draw.SimpleText("Preferences", "HNS.HUD.DR.Medium", w / 2, h / 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Preferences", "HNS.HUD.DR.Medium", w / 2 - 1, h / 2 - 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end):On("DoClick", function(this)
			self:Close() vgui.Create("HNS.Prefs.Derma")
		end)

	-- Achievements
	self.Achs = self:Add("DButton")
	self.Achs:SetPos(204, 221)
	self.Achs:SetSize(188, 31)
	self.Achs:TDLib()
		:ClearPaint():Outline(Color(125, 0, 255), 2):FillHover(Color(125, 0, 255), BOTTOM):Text(""):On("PaintOver", function(this, w, h)
			draw.SimpleText("Achievements", "HNS.HUD.DR.Medium", w / 2, h / 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Achievements", "HNS.HUD.DR.Medium", w / 2 - 1, h / 2 - 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end):On("DoClick", function()
			-- Add your own achievements addon, I'll use a custom one I made but is shitty anyways
			self:Close()
			RunConsoleCommand("say", "!achievements")
		end)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
	draw.RoundedBox(0, 0, 0, w, 24, Color(25, 25, 25))
end

vgui.Register("HNS.F1.Derma", PANEL, "DFrame")
if !GAMEMODE then
	vgui.Create("HNS.F1.Derma")
end

PANEL = {}

function PANEL:Init()
	self:SetSize(400, 300)
	self:Center()
	self:MakePopup()
	self:DockPadding(0, 24, 0, 0)

	self:SetTitle("GFL | Player Preferences")

	self.Tabs = self:Add("DPropertySheet")
	self.Tabs:Dock(FILL)
	self.Tabs:DockPadding(-4, 0, 0, 0)
	self.Tabs:SetFadeTime(0)
	self.Tabs.Paint = nil

	-- HUD tab
	self.Interface = self:Add("DPanel")
	self.Interface.Paint = nil

	self.Interface.HUDSlider = self.Interface:Add("DNumSlider")
	self.Interface.HUDSlider:Dock(TOP)
	self.Interface.HUDSlider:DockMargin(45, 10, 0, 0)
	self.Interface.HUDSlider:SetMinMax(1, #GAMEMODE.HUDs)
	self.Interface.HUDSlider:SetDecimals(0)
	self.Interface.HUDSlider:SetValue(GAMEMODE.CVars.HUD:GetInt())
	-- Disable all elements besides the slider
	self.Interface.HUDSlider.Label:Dock(NODOCK)
	self.Interface.HUDSlider.Label:SetMouseInputEnabled(false)
	-- Make number white (no racist I promise)
	self.Interface.HUDSlider.TextArea:SetTextColor(COLOR_WHITE)
	-- Snap to whole numbers and update convar
	self.Interface.HUDSlider.OnValueChanged = function(this, value)
		value = math.Round(value)
		this:SetValue(value)
		-- Update HUD and text
		RunConsoleCommand("has_hud", value)
		self.Interface.HUDText:SetText("Current HUD: " .. (GAMEMODE.HUDs[GAMEMODE.CVars.HUD:GetInt()] || GAMEMODE.HUDs[1]).Name)
	end

	-- Current HUD text
	self.Interface.HUDText = self.Interface:Add("DLabel")
	self.Interface.HUDText:Dock(TOP)
	self.Interface.HUDText:DockMargin(0, 0, 0, 4)
	self.Interface.HUDText:SetFont("DermaDefault")
	self.Interface.HUDText:SetColor(COLOR_WHITE)
	self.Interface.HUDText:SetContentAlignment(8)
	self.Interface.HUDText:SetText("Current HUD: " .. (GAMEMODE.HUDs[GAMEMODE.CVars.HUD:GetInt()] || GAMEMODE.HUDs[1]).Name)

	-- Adding checkboxes
	self.Interface.AddCheckBox = function(this, convar, text)
		local box = this:Add("DCheckBoxLabel")
		box:Dock(TOP)
		box:DockMargin(44, 0, 44, 4)
		box:SetText(text)
		box:SetChecked(GetConVar(convar):GetBool())
		-- Center text
		box.Label:Dock(FILL)
		box.Label:DockMargin(20, 0, 0, 1)
		-- Update ConVar
		box.OnChangeAdditional = function() end
		box.OnChange = function(_, value)
			RunConsoleCommand(convar, value && 1 || 0)
			-- Run another change
			box:OnChangeAdditional(value)
		end
		this[convar] = box
	end

	self.Interface:AddCheckBox("has_showid", "Show other players' Steam ID?")
	self.Interface:AddCheckBox("has_scob_ontop", "Put yourself at the top of the scoreboard?")
	self.Interface:AddCheckBox("has_showspeed", "Show movement speed?")

	-- Speed positions
	self.Interface.SpeedP = self.Interface:Add("DPanel")
	self.Interface.SpeedP:Dock(TOP)
	self.Interface.SpeedP:DockMargin(0, 2, 0, 4)
	self.Interface.SpeedP.Paint = function(this, w, h)
		draw.SimpleText("Speed box position ( X Y ):", "DermaDefault", 46, h / 2, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	self.Interface.SpeedX = self.Interface.SpeedP:Add("DNumberWang")
	self.Interface.SpeedX:SetPos(180, 2)
	self.Interface.SpeedX:SetSize(50, 22)
	self.Interface.SpeedX:SetMinMax(45, ScrW() - 45)
	self.Interface.SpeedX:SetValue(GAMEMODE.CVars.SpeedX:GetInt())
	self.Interface.SpeedX:SetConVar("has_speedx")

	self.Interface.SpeedY = self.Interface.SpeedP:Add("DNumberWang")
	self.Interface.SpeedY:SetPos(234, 2)
	self.Interface.SpeedY:SetSize(50, 22)
	self.Interface.SpeedY:SetMinMax(30, ScrH() - 30)
	self.Interface.SpeedY:SetValue(GAMEMODE.CVars.SpeedY:GetInt())
	self.Interface.SpeedY:SetConVar("has_speedy")

	-- Center button
	self.Interface.SpeedC = self.Interface.SpeedP:Add("DButton")
	self.Interface.SpeedC:SetPos(288, 2)
	self.Interface.SpeedC:SetSize(50, 22)
	self.Interface.SpeedC:SetText("Center")
	self.Interface.SpeedC.DoClick = function()
		self.Interface.SpeedX:SetValue(ScrW() / 2)
		self.Interface.SpeedY:SetValue(ScrH() / 2)
	end
	-- Enable/Disable
	self.Interface.SpeedX:SetEnabled(GAMEMODE.CVars.ShowSpeed:GetBool())
	self.Interface.SpeedY:SetEnabled(GAMEMODE.CVars.ShowSpeed:GetBool())
	self.Interface.SpeedC:SetEnabled(GAMEMODE.CVars.ShowSpeed:GetBool())
	self.Interface["has_showspeed"].OnChangeAdditional = function(this, value)
		self.Interface.SpeedX:SetEnabled(value)
		self.Interface.SpeedY:SetEnabled(value)
		self.Interface.SpeedC:SetEnabled(value)
	end

	self.Tabs:AddSheet("HUD - Interface", self.Interface, "icon16/paintbrush.png")

	-- Playermodel color and gender
	self.Playermodel = self:Add("DPanel")
	self.Playermodel.Paint = function(this, w, h)
		draw.SimpleText("Current Colors ", "DermaDefaultBold", w / 2, 0, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.RoundedBox(0, w / 2 - 38, 16, 30, 30, GAMEMODE:GetTeamShade(TEAM_HIDE, GAMEMODE.CVars.HiderColor:GetString()))
		draw.RoundedBox(0, w / 2 + 8, 16, 30, 30, GAMEMODE:GetTeamShade(TEAM_SEEK, GAMEMODE.CVars.SeekerColor:GetString()))
		draw.SimpleText("Hiding", "DermaDefaultBold", w / 2 - 44, 14, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		draw.SimpleText(GAMEMODE.CVars.HiderColor:GetString(), "DermaDefault", w / 2 - 44, 28, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		draw.SimpleText("Seeking", "DermaDefaultBold", w / 2 + 44, 14, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(GAMEMODE.CVars.SeekerColor:GetString(), "DermaDefault", w / 2 + 44, 28, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	-- Color buttons
	for i = 1, 2 do
		local grid = self.Playermodel:Add("DGrid")
		grid:SetPos(i == 1 && 119 || 199, 51)
		grid:SetCols(2)
		grid:SetColWide(35)
		grid:SetRowHeight(35)
		-- For each color
		for name, color in pairs(GAMEMODE[i == 1 && "HiderColors" || "SeekerColors"]) do
			local button = grid:Add("DColorButton")
			button:SetSize(30, 30)
			button:SetColor(color)
			button:SetTooltip(name)
			button.DoClick = function()
				-- Update convars
				RunConsoleCommand(i == 1 && "has_hidercolor" || "has_seekercolor", name)
			end

			grid:AddItem(button)
		end
	end

	-- Model stands
	for i = 1, 2 do
		local stand = self.Playermodel:Add("DModelPanel")
		stand:Dock(i == 1 && LEFT || RIGHT)
		stand:SetWide(120)
		stand:SetFOV(35)
		stand:SetModel(LocalPlayer():GetModel())
		stand.Entity.GetPlayerColor = function()
			if i == 1 then
				return GAMEMODE:GetTeamShade(TEAM_HIDE, GAMEMODE.CVars.HiderColor:GetString()):ToVector()
			else
				return GAMEMODE:GetTeamShade(TEAM_SEEK, GAMEMODE.CVars.SeekerColor:GetString()):ToVector()
			end
		end
	end

	-- Gender option
	self.Playermodel.Gender = self.Playermodel:Add("DButton")
	self.Playermodel.Gender:Dock(BOTTOM)
	self.Playermodel.Gender.Color = GAMEMODE.CVars.Gender:GetBool() && Color(255, 105, 180) || Color(75, 150, 225)
	self.Playermodel.Gender:SetTall(28)
	self.Playermodel.Gender:TDLib() -- Styling
		:ClearPaint():Outline(self.Playermodel.Gender.Color, 2):BarHover(self.Playermodel.Gender.Color, 4):Text(GAMEMODE.CVars.Gender:GetBool() && "Gender: Female" || "Gender: Male", "DermaDefaultBold"):On("DoClick", function(this)
			-- Update cvar
			RunConsoleCommand("has_gender", !GAMEMODE.CVars.Gender:GetBool() && 1 || 0)
			-- Update color and text
			this.Color = !GAMEMODE.CVars.Gender:GetBool() && Color(255, 105, 180) || Color(75, 150, 225)
			this:TDLib():ClearPaint():Outline(this.Color, 2):BarHover(this.Color, 4):Text(!GAMEMODE.CVars.Gender:GetBool() && "Gender: Female" || "Gender: Male", "DermaDefaultBold")
		end)

	self.Tabs:AddSheet("Player Model", self.Playermodel, "icon16/user.png")

	self.Crosshair = self:Add("DPanel")
	self.Crosshair.XHair = {}
	self.Crosshair.Paint = function(this, w, h)
		draw.RoundedBox(0, w - 84, 6, 80, 80, Color(125, 125, 125))
		self.Crosshair.XHair.Size = GAMEMODE.CVars.CrosshairSize:GetInt()
		self.Crosshair.XHair.Gap = GAMEMODE.CVars.CrosshairGap:GetInt()
		self.Crosshair.XHair.Thick = GAMEMODE.CVars.CrosshairThick:GetInt()
		self.Crosshair.XHair.Color = Color(GAMEMODE.CVars.CrosshairR:GetInt(), GAMEMODE.CVars.CrosshairG:GetInt(), GAMEMODE.CVars.CrosshairB:GetInt(), GAMEMODE.CVars.CrosshairA:GetInt())
		GAMEMODE:DrawCrosshair(w - 44, 46, self.Crosshair.XHair)

		draw.SimpleText("Size:", "DermaDefault", 285, 110, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Gap:", "DermaDefault", 285, 134, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Thick:", "DermaDefault", 285, 158, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	-- Checkbox
	self.Crosshair.Enabled = self.Crosshair:Add("DCheckBoxLabel")
	self.Crosshair.Enabled:SetPos(300, 200)
	self.Crosshair.Enabled:SetText("Enable?")
	self.Crosshair.Enabled:SetConVar("has_crosshair_enable")

	-- Color picker
	self.Crosshair.Picker = self.Crosshair:Add("DColorMixer")
	self.Crosshair.Picker:SetWide(288)
	self.Crosshair.Picker:SetConVarR("has_crosshair_r")
	self.Crosshair.Picker:SetConVarG("has_crosshair_g")
	self.Crosshair.Picker:SetConVarB("has_crosshair_b")
	self.Crosshair.Picker:SetConVarA("has_crosshair_a")

	-- Crosshair sizes
	for i = 1, 3 do
		local wang = self.Crosshair:Add("DNumberWang")

		wang:SetPos(290, i == 1 && 100 || i == 2 && 124 || 148)
		wang:SetSize(50, 22)
		wang:SetConVar("has_crosshair_" .. (i == 1 && "size" || i == 2 && "gap" || "thick"))
		wang:SetValue(GetConVar("has_crosshair_" .. (i == 1 && "size" || i == 2 && "gap" || "thick")):GetInt())
	end

	self.Tabs:AddSheet("Crosshair", self.Crosshair, "icon16/cross.png")

	-- Style tabs
	for _, item in ipairs(self.Tabs:GetItems()) do
		item.Tab.GetTabHeight = function() return 24 end
		item.Tab:TDLib() -- Styling
			:ClearPaint():Background(Color (25, 25, 25)):BarHover(Color(75, 75, 75), 2):SetTransitionFunc(function(this) return this:IsActive() end):FadeHover(Color (75, 75, 75))
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 24, w, h, Color(50, 50, 50))
	draw.RoundedBoxEx(6, 0, 0, w, 24, Color(25, 25, 25), true, true)
end

vgui.Register("HNS.Prefs.Derma", PANEL, "DFrame")

-- Scoreboard
PANEL = {}

function PANEL:Init()
	self:SetSize(550, ScrH() - 100)
	self:Center()
	self:MakePopup()
	self:SetKeyboardInputEnabled(false) -- Not needed
	self:SetTitle("Scoreboard - Hide and Seek")
	self:DockPadding(0, 94, 0, 0)

	-- Load materials
	self.Mats = {
		["Map"] = Material("icon16/map.png"),
		["User"] = Material("icon16/user.png"),
		["Blue"] = Material("icon16/flag_blue.png"),
		["Red"] = Material("icon16/flag_red.png"),
		["Green"] = Material("icon16/flag_green.png"),
		["Time"] = Material("icon16/time.png"),
		["Friend"] = Material("icon16/user_add.png"),
		["Mute"] = Material("icon16/sound.png"),
		["Muted"] = Material("icon16/sound_mute.png"),
		["Local"] = Material("icon16/asterisk_yellow.png"),
		["Star"] = Material("icon16/star.png"),
	}

	-- GFL button
	self.GFL = self:Add("DButton")
	self.GFL:SetPos(0, 24)
	self.GFL:SetSize(200, 64)
	self.GFL:TDLib() -- Styling
		:ClearPaint():Text("Games For Life", "DermaLarge"):Blur(2):LinedCorners():CircleHover():SetOpenURL("https://gflclan.com/forums")

	-- Sorting buton
	self.Sorter = self:Add("DButton")
	self.Sorter:SetPos(456, 59)
	self.Sorter:SetSize(89, 24)
	self.Sorter:TDLib()
		:ClearPaint():Outline(COLOR_WHITE, 2):CircleHover():Text("")
		:On("Paint", function(this, w, h)
			if GAMEMODE.CVars.Sort:GetInt() == 1 then
				draw.SimpleTextOutlined("Entity ID", "DermaDefaultBold", w / 2, h / 2, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
			elseif GAMEMODE.CVars.Sort:GetInt() == 2 then
				draw.SimpleTextOutlined("Points", "DermaDefaultBold", w / 2, h / 2, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
			else
				draw.SimpleTextOutlined("Name", "DermaDefaultBold", w / 2, h / 2, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
			end
		end):On("DoClick", function()
			if GAMEMODE.CVars.Sort:GetInt() == 1 then
				GAMEMODE.CVars.Sort:SetInt(2)
			elseif GAMEMODE.CVars.Sort:GetInt() == 2 then
				GAMEMODE.CVars.Sort:SetInt(3)
			else
				GAMEMODE.CVars.Sort:SetInt(1)
			end
			self:UpdateList()
		end)

	-- Players
	self.Playing = self:Add("DScrollPanel")
	self.Playing:Dock(TOP)
	self.Playing:DockPadding(0, 0, 0, 6)
	-- Spectators
	self.Spectating = self:Add("DScrollPanel")
	self.Spectating:Dock(FILL)

	-- Fill list
	self:UpdateList()
end

function PANEL:Paint(w, h)
	-- Using surface so this doesn't fuck up too badly
	surface.SetDrawColor(0, 0, 0, 125)
	surface.DrawRect(0, 0, w, 88)
	-- Map info
	surface.SetDrawColor(255, 255, 255, 255)

	surface.SetMaterial(self.Mats.Map) surface.DrawTexturedRect(206, 26, 16, 16)
	draw.SimpleTextOutlined(game.GetMap(), "DermaDefaultBold", 228, 32, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))

	-- Players' info
	surface.SetMaterial(self.Mats.User) surface.DrawTexturedRect(206, 48, 16, 16)
	draw.SimpleTextOutlined(player.GetCount() .. "/" .. game.MaxPlayers(), "DermaDefaultBold", 250, 55, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	surface.SetMaterial(self.Mats.Blue) surface.DrawTexturedRect(276, 48, 16, 16)
	draw.SimpleTextOutlined(team.NumPlayers(TEAM_HIDE), "DermaDefaultBold", 310, 55, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	surface.SetMaterial(self.Mats.Red) surface.DrawTexturedRect(328, 48, 16, 16)
	draw.SimpleTextOutlined(team.NumPlayers(TEAM_SEEK), "DermaDefaultBold", 362, 55, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
	surface.SetMaterial(self.Mats.Green) surface.DrawTexturedRect(380, 48, 16, 16)
	draw.SimpleTextOutlined(team.NumPlayers(TEAM_SPECTATOR), "DermaDefaultBold", 414, 55, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))

	-- Round info
	surface.SetMaterial(self.Mats.Time) surface.DrawTexturedRect(206, 70, 16, 16)
	draw.SimpleTextOutlined("Round " .. GAMEMODE.RoundCount .. " | " .. string.ToMinutesSeconds(GAMEMODE.TimeLeft), "DermaDefaultBold", 228, 77, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
end

function PANEL:UpdateList()
	self.Playing:Clear()
	self.Spectating:Clear()

	-- Hide/Show spectators scroll panel
	if team.NumPlayers(TEAM_SPECTATOR) > 0 then
		self.Spectating:Show()
		self.Playing:Dock(TOP)
		self.Spectating:Dock(FILL)
		-- Size playing
		self.Playing:SetTall(math.min(ScrH() - 312 + 40, 42 * (player.GetCount() - team.NumPlayers(TEAM_SPECTATOR))))
	else
		self.Spectating:Hide()
		self.Playing:Dock(FILL)
		self.Spectating:Dock(NODOCK)
	end

	-- Store players
	local plys = player.GetAll()
	-- Sort
	if GAMEMODE.CVars.Sort:GetInt() == 1 then
		table.sort(plys, function(a, b) return a:EntIndex() < b:EntIndex() end)
	elseif GAMEMODE.CVars.Sort:GetInt() == 2 then
		table.sort(plys, function(a, b) return a:Frags() > b:Frags() end)
	else
		table.sort(plys, function(a, b) return a:Name() < b:Name() end)
	end
	if GAMEMODE.CVars.ShowOnTop:GetBool() then
		table.RemoveByValue(plys, LocalPlayer())
		table.insert(plys, 1, LocalPlayer())
	end

	-- Start adding players
	for _, ply in pairs(plys) do
		local button = self[ply:Team() == TEAM_SPECTATOR && "Spectating" || "Playing"]:Add("DButton")

		button:Dock(TOP)
		button:DockMargin(0, 0, 0, 6)
		button:SetTall(36)
		button:SetText("")

		if ply.AchMaster then
			button:SetTooltip(ply:Name() .. " has all achievements!")
		end

		button.Avatar = button:Add("AvatarImage")
		button.Avatar:SetPos(2, 2)
		button.Avatar:SetSize(32, 32)
		button.Avatar:SetPlayer(ply, 64)

		button.Paint = function(this, w, h)
			-- BG
			if this:IsHovered() then
				surface.SetDrawColor(75, 75, 75, 175)
				surface.DrawRect(0, 0, w, h)
			else
				surface.SetDrawColor(0, 0, 0, 125)
				surface.DrawRect(0, 0, w, h)
				-- Ply glow
				if ply == LocalPlayer() then
					surface.SetDrawColor(255, 255, 255, math.sin(CurTime() * 4) * 20 + 25)
					surface.DrawRect(0, 0, w, h)
				elseif ply.AchMaster then
					surface.SetDrawColor(255, 255, 0, math.sin(CurTime() * 4) * 20 + 25)
					surface.DrawRect(0, 0, w, h)
				end
			end
			-- Player square
			if GAMEMODE.RoundState != ROUND_ACTIVE || LocalPlayer():Team() != TEAM_HIDE || ply:Team() == TEAM_SPECTATOR then
				surface.SetDrawColor(team.GetColor(ply:Team()))
			else
				surface.SetDrawColor(255, 255, 255, 255)
			end
			surface.DrawRect(0, 0, 36, 36)

			-- Player relationship
			surface.SetDrawColor(255, 255, 255, 255)
			if ply:IsMuted() then
				surface.SetMaterial(self.Mats.Muted)
			elseif ply == LocalPlayer() then
				surface.SetMaterial(self.Mats.Local)
			elseif ply:GetFriendStatus() != "none" && ply:GetFriendStatus() != "blocked" then
				surface.SetMaterial(self.Mats.Friend)
			else
				surface.SetDrawColor(0, 0, 0, 0) -- Think smart
			end
			surface.DrawTexturedRect(w - 26, 10, 16, 16)

			-- Stars
			if ply.AchMaster then
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(self.Mats.Star)
				surface.DrawTexturedRect(w / 2 - 8, h / 2 - 16, 16, 16)
				surface.DrawTexturedRect(w / 2 - 17, h / 2, 16, 16)
				surface.DrawTexturedRect(w / 2 + 1, h / 2, 16, 16)
			end

			-- Player info
			draw.SimpleTextOutlined(ply:Name(), "DermaDefaultBold", 40, 8, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
			draw.SimpleTextOutlined("Points: " .. ply:Frags() .. " | Ping: " .. ply:Ping(), "DermaDefault", 40, 24, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 125))
		end

		button.DoClick = function(this)
			local menu = DermaMenu()
			menu:AddOption(ply:IsMuted() && "Unmute" || "Mute", function()
				ply:SetMuted(!ply:IsMuted())
			end):SetIcon(ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
			menu:AddOption("Open Profile", function()
				ply:ShowProfile()
			end):SetIcon("icon16/user.png")

			menu:AddSpacer()

			menu:AddOption("Copy Name", function()
				SetClipboardText(ply:Name())
			end):SetIcon("icon16/shield.png")
			menu:AddOption("Copy Steam ID (" .. ply:Name() .. ")", function()
				SetClipboardText(ply:SteamID())
			end):SetIcon("icon16/shield.png")

			menu:Open()
		end
	end
end

vgui.Register("HNS.Scoreboard", PANEL, "DFrame")