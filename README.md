# Light Hide and Seek

A recoding of the classic Hide and Seek gamemode for Garry's Mod that is more secure, optimized and customizable.

I am using [Threebow](https://www.threebow.com/)'s [Derma Lib](https://threebow.gitbooks.io/tdlib/) for cool looking derma (the windows).

This gamemode WILL CONFLICT with [classic Hide and Seek](https://steamcommunity.com/sharedfiles/filedetails/?id=266512527), so make sure you uninstall it.

## Main Features

* Multiple HUDs and settings.
* Player gender and color shade choices.
* More server-side settings and optimization.
* More secure (pretty sure I'm not using SendLua anywhere).
* Active development.
* Per-server achievements.

## TO DO
* Votemap (currently, you'll need to hook your own votemap to `HASVotemapStart`)

## ConVars (server settings)

`has_maxrounds`  *Number* = Rounds until hook `HASVotemapStart` is run.

`has_timelimit` *Seconds* = Time until a round ends. 0 means that the round will only end when there are no more hiders or seekers.

`has_envdmgallowed` *Boolean (0 or 1)* = Will `trigger_hurt` kill players?

`has_blindtime` *Seconds* = Time the seekers are blinded (can be 0 if you want chaos)

`has_hidereward` *Number* = Points (frags) to award hiders when they win the round.

`has_seekreward` *Number* = Points (frags) to award seekers when they tag a hider.

`has_hiderrunspeed` *Number* = Speed at which hiders run.

`has_seekerrunspeed` *Number* = Speed at which seekers run.

`has_hiderwalkspeed` *Number* = Speed at which hiders walk.

`has_seekerwalkspeed` *Number* = Speed at which seekers walk.

`has_jumppower` *Number* = Power everyone jumps with.

`has_clickrange` *Number* = Range at which seekers will tag hiders using click tag.

`has_scob_text` *Text* = Text the scoreboard will show on the button at the top left corner. Requires a map change or closing the scoreboard with the X button to take effect.

`has_scob_url` *Text* = URL the scoreboard button will open. Needs to start with "https://" and DOES REQUIRE QUOTES when setting from console ("" <- these).

## Additional info

This gamemode was created to be exclusive to the GFL community, but now is free for everyone to use, that's why you may see server references, bad commit names or me just being a dick on the comments on older commits.
