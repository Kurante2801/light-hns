GM.UpdateFonts = function()
	local self = GM || GAMEMODE
	local scale = self.CVars.HUDScale:GetInt()

	surface.CreateFont("HNSHUD.VerdanaMedium", {
		font = "Verdana",
		size = 11 * scale,
		weight = 190 * scale,
	})

	surface.CreateFont("HNSHUD.TahomaSmall", {
		font = "Tahoma",
		size = 7 * scale,
		weight = 280 * scale,
	})

	surface.CreateFont("HNSHUD.TahomaThin", {
		font = "Tahoma",
		size = 7 * scale,
		weight = 140 * scale,
	})

	surface.CreateFont("HNSHUD.VerdanaLarge", {
		font = "Verdana",
		size = 14 * scale,
		weight = 287 * scale,
	})

	surface.CreateFont("HNSHUD.RobotoLarge", {
		font = "Roboto",
		size = 16 * scale,
		weight = 200 * scale,
	})
end

GM.UpdateFonts()
cvars.AddChangeCallback("has_hud_scale", GM.UpdateFonts, "HNS.UpdateFonts")

surface.CreateFont("HNS.HUD.Fafy.Name", {
	font = "Verdana",
	size = 22,
	weight = 275,
})
surface.CreateFont("HNS.HUD.Fafy.Timer", {
	font = "Verdana",
	size = 28,
	weight = 575,
})

surface.CreateFont("HNS.HUD.DR.Small", {
	font = "Roboto Bold",
	size = 15,
	antialias = true,
})
surface.CreateFont("HNS.HUD.DR.Medium", {
	font = "Roboto",
	size = 20,
	antialias = true,
})
surface.CreateFont("HNS.HUD.DR.Big", {
	font = "Roboto",
	size = 38,
	weight = 600,
	antialias = true,
})
surface.CreateFont("HNS.HUD.DR.TeamSelection", {
	font = "Roboto",
	size = 30,
	weight = 550,
	antialias = true,
})
surface.CreateFont("HNS.HUD.DR.Large", {
	font = "Roboto Bold",
	size = 48,
	antialias = true,
})
surface.CreateFont("HNS.HUD.DR.Spec", {
	font = "Roboto Bold",
	size = 84,
	antialias = true,
})