-- Can't use util.TraceHull on ShouldCollide
-- Because it fucks up clientside when high ping
AddCSLuaFile()

ENT.Type = "anim"
ENT.DisableDuplicator = true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
    self:SetAngles(Angle(0, 0, 0))
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:SetModel("models/props_phx/misc/gibs/egg_piece4.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCustomCollisionCheck(true)

    self:SetOwnerHeight(0)
    self:SetOwnerHeightCrouched(0)
    self.Collisions = {}
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "OwnerModel")
    self:NetworkVar("Float", 0, "OwnerHeight")
    self:NetworkVar("Float", 1, "OwnerHeightCrouched")
end

function ENT:SetPlayer(ply)
    self:CollisionRulesChanged()
    self:SetOwner(ply)
    self:SetOwnerModel(ply:GetModel())

    local mins, maxs = ply:OBBMins(), ply:OBBMaxs()
    self:PhysicsInitBox(Vector(mins.x, mins.y, -1), Vector(maxs.x, maxs.y, 0))
    self:SetMoveType(MOVETYPE_NONE)

    local _, hull = ply:GetHull()
    self:SetOwnerHeight(hull.z )

    _, hull = ply:GetHullDuck()
    self:SetOwnerHeightCrouched(hull.z)

    if CLIENT then
        self.PlayerSetCL = true
        self:DestroyShadow()
    end
end

function ENT:Draw()
end

function ENT:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:Team() == TEAM_SPECTATOR then
        if SERVER then self:Remove() end
        return
    elseif CLIENT and not self.PlayerSetCL then
        self:SetPlayer(owner)
    end

    local pos = owner:GetPos()

    if owner:Crouching() then
        pos.z = pos.z + (self:GetOwnerHeightCrouched() * owner:GetModelScale())
    else
        pos.z = pos.z + (self:GetOwnerHeight() * owner:GetModelScale())
    end

    self:SetPos(pos)

    -- Refresh bounding boxes
    if owner:GetModel() ~= self:GetOwnerModel() then
        self:SetPlayer(owner)
    end

    -- Refresh collisions cache
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then continue end

        local should = ply:Team() ~= TEAM_SPECTATOR and ply:GetPos().z > pos.z

        if self.Collisions[ply:EntIndex()] ~= should then
            self:CollisionRulesChanged()
            self.Collisions[ply:EntIndex()] = should
        end
    end
end

function ENT:ShouldCollide(ent)
    if not IsValid(ent) or not ent:IsPlayer() then
        return false
    end

    return self.Collisions[ent:EntIndex()] or false
end