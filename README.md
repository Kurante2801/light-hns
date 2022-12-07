# Light Hide and Seek

A recoding of the classic Hide and Seek gamemode for Garry's Mod that is more secure, optimized and customizable. The reason I've done this is because I want the gamemode to live again, or not to completely die out as it is my favorite gamemode since years.

This gamemode WILL CONFLICT with [classic Hide and Seek](https://steamcommunity.com/sharedfiles/filedetails/?id=266512527), so make sure you uninstall it.

## Main Features

- Multiple HUDs and settings.
- HUD scaling for people with big screens.
- Player gender and color shade choices.
- More server-side settings and optimization.
- More secure (not using insecure networking).
- Active development.
- Per-server achievements (and you can add your own too!).
- Flashlights for hiders. (disabled by default, see ConVars)

## TO DO

- Votemap (currently, you'll need to hook your own votemap to `HASVotemapStart`)

## ConVars (server settings)

`has_maxrounds` _Number_ = Rounds until hook `HASVotemapStart` is run.

`has_timelimit` _Seconds_ = Time until a round ends. 0 means that the round will only end when there are no more hiders or seekers.

`has_envdmgallowed` _Boolean (0 or 1)_ = Will `trigger_hurt` kill players?

`has_blindtime` _Seconds_ = Time the seekers are blinded (can be 0 if you want chaos)

`has_hidereward` _Number_ = Points (frags) to award hiders when they win the round.

`has_seekreward` _Number_ = Points (frags) to award seekers when they tag a hider.

`has_hiderrunspeed` _Number_ = Speed at which hiders run.

`has_seekerrunspeed` _Number_ = Speed at which seekers run.

`has_hiderwalkspeed` _Number_ = Speed at which hiders walk.

`has_seekerwalkspeed` _Number_ = Speed at which seekers walk.

`has_jumppower` _Number_ = Power everyone jumps with.

`has_clickrange` _Number_ = Range at which seekers will tag hiders using click tag.

`has_scob_text` _Text_ = Text the scoreboard will show on the button at the top left corner. Requires a map change or closing the scoreboard with the X button to take effect.

`has_scob_url` _Text_ = URL the scoreboard button will open. Needs to start with "https://" and DOES REQUIRE QUOTES when setting from console ("" <- these).

`has_lasthidertrail` _Boolean (0 or 1)_ = Will the last hider have a trail following them around?

`has_hiderflashlight` _Boolean (0 or 1)_ = Will hiders be able to use flashlights? They will only be visible for themselves and will not produce a sound.

`has_teamindicators` _Boolean (0 or 1)_ = Will players be able to see their teammates' position with a V over their heads?.

`has_infinitestamina` _Boolean (0 or 1)_ = Can players run forever.

`has_firstcaughtseeks` _Boolean (0 or 1)_ = First player caught will seek next round.

`has_maxstamina` _Number_ = Maximum ammount of stamina players can refill.

`has_staminarefill` _Number_ = Rate at which stamina is filled.

`has_staminadeplete` _Number_ = Rate at which stamina is depleted.

`has_staminawait` _Number_ = How many seconds to wait before filling stamina.

`has_minplayers` _Number_ = Minimum players required to start a round.

## Additional info

This gamemode was created to be exclusive to the GFL community, but now is free for everyone to use, that's why you may see server references, bad commit names or me just being a dick on the comments on older commits.
