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