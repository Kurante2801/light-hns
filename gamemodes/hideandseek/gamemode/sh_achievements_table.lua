GM.Achievements = {}

GM.Achievements["1kchampion"] = {
	Name = "Seeking Champion",
	Desc = "Catch 1000 players through-out your seeking career..",
	Goal = 1000,
	Reward = 50000
}

GM.Achievements["submission"] = {
	Name = "Submission!",
	Desc = "As a seeker, have a hider run into you.",
	Reward = 1000
}

GM.Achievements["crowd"] = {
	Name = "Three's a Crowd!",
	Desc = "As a hider, win a round with 2 or more other hiders close-by.",
	Reward = 1000
}

GM.Achievements["bike"] = {
	Name = "A Wise Man Once Said",
	Desc = "RED! This isn't the time to use that!",
	Reward = 1000
}

GM.Achievements["lasthiding"] = {
	Name = "Last Man Hiding",
	Desc = "Win a round as the last hider (with at least 4 other players)",
	Reward = 5000
}

GM.Achievements["closecall"] = {
	Name = "Close Call",
	Desc = "As a seeker, end the round by catching a hider in the last 10 seconds.",
	Reward = 1000
}

GM.Achievements["mario"] = {
	Name = "Mario the Italian Seeker",
	Desc = "As a seeker, catch a hider Mario style.",
	Reward = 1000
}

GM.Achievements["tranquillity"] = {
	Name = "Hiding in Tranquillity",
	Desc = "Wait for a total of 5 hours in your hiding career.",
	Goal = 18000,
	Reward = 100000
}

GM.Achievements["conversationalist"] = {
	Name = "Conversationalist",
	Desc = "As a hider, let the seekers know they're bad by talking a lot.",
	Reward = 5000
}

GM.Achievements["ticklefight"] = {
	Name = "Magic Words",
	Desc = "Starts out fun, ends in tears.",
	Reward = 1000
}

GM.Achievements["anotherway"] = {
	Name = "Another Way Through",
	Desc = "As a seeker, break something to hastily catch a hider.",
	Reward = 1000
}

GM.Achievements["rubberlegs"] = {
	Name = "Rubber Legs",
	Desc = "Break your legs 50 times.",
	Goal = 50,
	Reward = 2000
}

-- Cache count, to not call table.Count again
GM.AchievementsCount = table.Count(GM.Achievements)
-- While we're at it
game.AddParticles("particles/explosion.pcf")
PrecacheParticleSystem("bday_confetti")
PrecacheParticleSystem("bday_confetti_colors")