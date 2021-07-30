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
    self:SetOwner(ply)
    self:SetOwnerModel(ply:GetModel())

    if CLIENT then
        self.PlayerSetCL = true
        self:DestroyShadow()
    end

    local mins, maxs = ply:OBBMins(), ply:OBBMaxs()
    self:PhysicsInitBox(Vector(mins.x, mins.y, -1), Vector(maxs.x, maxs.y, 0))
    self:SetMoveType(MOVETYPE_NONE)

    self:SetOwnerHeight(maxs.z)

    local _, hull = ply:GetHullDuck()
    self:SetOwnerHeightCrouched(hull.z)
end

function ENT:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then
        return
    elseif CLIENT and not self.PlayerSetCL then
        self:SetPlayer(owner)
    end

    local pos = owner:GetPos()

    if owner:Crouching() then
        pos.z = pos.z + self:GetOwnerHeightCrouched()
    else
        pos.z = pos.z + self:GetOwnerHeight()
    end

    self:SetPos(pos)

    -- Refresh bounding boxes
    if owner:GetModel() ~= self:GetOwnerModel() then
        self:SetPlayer(owner)
    end
end