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
	self:SetSize(400, 240)
	self:Center()
	self:MakePopup()

	self:SetTitle("GFL | Hide and Seek")

	self.Text = self:Add("DLabel")
	self.Text:Dock(TOP)
	self.Text:SetContentAlignment(7)
	self.Text:SetFont("HNS.HUD.DR.Medium")
	self.Text:SetText("This server is running under a recoded version of\nHide and Seek made by Fafy. Derma elements use\nThree's Derma Lib (TDLib) made by Threebow.\n\nMake sure you read the !motd and follow the rules\nF1 = Open this again. F2 = Team selection")
	self.Text:SizeToContents()
	-- Play button
	self.Play = self:Add("DButton")
	self.Play:SetPos(8, 162)
	self.Play:SetSize(200, 70)
	self.Play:TDLib() -- Styling
		:ClearPaint():Outline(Color(220, 20, 60), 2):FillHover(Color(220, 20, 60), LEFT):Text("")
		:On("PaintOver", function(this, w, h)
			draw.SimpleText("Let's Play!", "HNS.HUD.Fafy.Name", w / 2, h / 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Let's Play!", "HNS.HUD.Fafy.Name", w / 2 - 1, h / 2 - 1, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
	self.Prefs:SetPos(242, 182)
	self.Prefs:SetSize(120, 30)
	self.Prefs:TDLib() -- Styling
		:ClearPaint():Outline(Color(0, 255, 255), 2):BarHover(Color(0, 255, 255), 4):Text("Preferences", "HNS.HUD.DR.Medium")
		:On("DoClick", function(this)
			self:Close() vgui.Create("HNS.Prefs.Derma")
		end)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
	draw.RoundedBox(0, 0, 0, w, 24, Color(25, 25, 25))
end

vgui.Register("HNS.F1.Derma", PANEL, "DFrame")

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

	self.Tabs:AddSheet("Crosshair", self.Crosshair, "icon16/cross.png")
	self.Tabs:SwitchToName("Crosshair")

	-- Style tabs
	for _, item in ipairs(self.Tabs:GetItems()) do
		item.Tab.GetTabHeight = function() return 24 end
		item.Tab:TDLib() -- Styling
			:ClearPaint():Background(Color (25, 25, 25)):BarHover(Color(75, 75, 75), 2):SetTransitionFunc(function(this) return this:IsActive() end):FadeHover(Color (75, 75, 75))
	end

	-- Crosshair sizes
	for i = 1, 3 do
		local wang = self.Crosshair:Add("DNumberWang")

		wang:SetPos(290, i == 1 && 100 || i == 2 && 124 || 148)
		wang:SetSize(50, 22)
		wang:SetConVar("has_crosshair_" .. (i == 1 && "size" || i == 2 && "gap" || "thick"))
		wang:SetValue(GetConVar("has_crosshair_" .. (i == 1 && "size" || i == 2 && "gap" || "thick")):GetInt())
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 24, w, h, Color(50, 50, 50))
	draw.RoundedBoxEx(6, 0, 0, w, 24, Color(25, 25, 25), true, true)
end

vgui.Register("HNS.Prefs.Derma", PANEL, "DFrame")

-- Scoreboard
