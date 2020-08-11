GM.UpdateFonts = function()
	local GAMEMODE = GM || GAMEMODE
	local scale = GAMEMODE.CVars.HUDScale:GetInt()

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

	surface.CreateFont("HNSHUD.TahomaLarge", {
		font = "Tahoma",
		size = 22 * scale,
		weight = 300 * scale,
	})

	surface.CreateFont("HNSHUD.Marlett", {
		font = "Trebuchet MS",
		size = 18 * scale,
		weight = 300 * scale,
	})

	surface.CreateFont("HNSHUD.CorbelSmall", {
		font = "Roboto",
		size = 9 * scale,
		weight = 272 * scale,
	})
end

GM.UpdateFonts()
cvars.AddChangeCallback("has_hud_scale", GM.UpdateFonts, "HNS.UpdateFonts")

surface.CreateFont("HNS.VerdanaMedium", {
	font = "Verdana",
	size = 22,
	weight = 275,
})
surface.CreateFont("HNS.VerdanaLarge", {
	font = "Verdana",
	size = 28,
	weight = 575,
})

surface.CreateFont("HNS.RobotoSmall", {
	font = "Roboto",
	size = 18,
	weight = 550,
	antialias = true,
})
surface.CreateFont("HNS.RobotoMedium", {
	font = "Roboto",
	size = 20,
	antialias = true,
})
surface.CreateFont("HNS.RobotoBig", {
	font = "Roboto",
	size = 38,
	weight = 600,
	antialias = true,
})
surface.CreateFont("HNS.RobotoTeamSelection", {
	font = "Roboto",
	size = 30,
	weight = 550,
	antialias = true,
})
surface.CreateFont("HNS.RobotoLarge", {
	font = "Roboto Bold",
	size = 48,
	antialias = true,
})
surface.CreateFont("HNS.RobotoSpec", {
	font = "Roboto Bold",
	size = 84,
	antialias = true,
})