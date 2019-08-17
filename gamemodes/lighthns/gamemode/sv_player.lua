function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_HIDE)
end

function GM:PlayerSpawn(ply)
	-- Calling base spawn for stuff fixing
	self.BaseClass:PlayerSpawn(ply)

	-- Set current gender
	ply.Gender = ply:GetInfoNum("has_gender", 0) == 1

	-- Setting random gender based model
	if ply.Gender then
		ply:SetModel("models/player/group01/female_0" .. math.random(6) .. ".mdl")
	else
		ply:SetModel("models/player/group01/male_0" .. math.random(9) .. ".mdl")
	end

	-- Setting desired color shade
	ply:SetPlayerColor(self:GetPlayerTeamColor(ply):ToVector())
end