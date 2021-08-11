local linux = system.IsLinux()

GM.UpdateFonts = function()
    local GAMEMODE = GM or GAMEMODE
    local scale = GAMEMODE.CVars.HUDScale:GetInt()

    surface.CreateFont("HNSHUD.VerdanaMedium", {
        font = "Verdana",
        size = 11 * scale,
        weight = 380,
    })

    surface.CreateFont("HNSHUD.TahomaSmall", {
        font = linux and "Verdana Bold" or "Tahoma",
        size = 7 * scale,
        weight = 560,
    })

    surface.CreateFont("HNSHUD.TahomaThin", {
        font = linux and "Verdana" or "Tahoma",
        size = 7 * scale,
        weight = 280,
    })

    surface.CreateFont("HNSHUD.VerdanaLarge", {
        font = "Verdana",
        size = 14 * scale,
        weight = 575,
    })

    surface.CreateFont("HNSHUD.RobotoLarge", {
        font = linux and "Verdana" or "Roboto",
        size = 16 * scale,
        weight = 400,
    })

    surface.CreateFont("HNSHUD.TahomaLarge", {
        font = linux and "Arial" or "Tahoma",
        size = 22 * scale,
        weight = 600,
    })

    surface.CreateFont("HNSHUD.RobotoThin", {
        font = linux and "Arial" or "Roboto",
        size = 9 * scale,
        weight = 500,
    })
end

GM.UpdateFonts()
cvars.AddChangeCallback("has_hud_scale", GM.UpdateFonts, "HNS.UpdateFonts")

surface.CreateFont("HNS.RobotoSmall", {
    font = linux and "Verdana Bold" or "Roboto Black",
    size = 18,
    weight = 550,
    antialias = true,
})

surface.CreateFont("HNS.RobotoThin", {
    font = linux and "Arial" or "Roboto",
    size = 18,
    weight = 275,
})

surface.CreateFont("HNS.RobotoLarge", {
    font = linux and "Verdana Bold" or "Roboto Black",
    size = 30,
})

surface.CreateFont("HNS.RobotoSpec", {
    font = linux and "Verdana" or "Roboto Bold",
    size = 84,
    antialias = true,
})