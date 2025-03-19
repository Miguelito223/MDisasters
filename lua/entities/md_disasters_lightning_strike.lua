AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Lightning Strike"
ENT.Category = "MDisasters"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT  -- IMPORTANTE

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_junk/PopCan01a.mdl")
        self:SetNoDraw(false)  -- Solo en SERVER

        local startPos = self:GetPos() + Vector(0, 0, 1000)
        local endPos = self:GetPos()

        self:SetNWVector("StartPos", startPos)
        self:SetNWVector("EndPos", endPos)
        self:SetNWFloat("BeamStartTime", CurTime())
        self:SetNWFloat("BeamDuration", 0.3)

        sound.Play("ambient/energy/zap1.wav", endPos, 120, 100, 1)
       
        local explosion = ents.Create("env_explosion")
        if IsValid(explosion) then
            explosion:SetPos(endPos)
            explosion:SetOwner(self)
            explosion:Spawn()
            explosion:SetKeyValue("iMagnitude", "100") -- Potencia de la explosión
            explosion:Fire("Explode", "", 0)
        end

        timer.Simple(2, function()
            if IsValid(self) then self:Remove() end
        end)
    end
end


function ENT:Think()
    if CLIENT then
        local endPos = self:GetNWVector("EndPos")
        local beamStartTime = self:GetNWFloat("BeamStartTime", 0)
        local beamDuration = self:GetNWFloat("BeamDuration", 0.3)
        local elapsed = CurTime() - beamStartTime

        if elapsed <= beamDuration then
            local dlight = DynamicLight(self:EntIndex())
            if dlight then
                dlight.pos = endPos
                dlight.r = 255
                dlight.g = 255
                dlight.b = 200
                dlight.brightness = 4
                dlight.Decay = 500
                dlight.Size = 400
                dlight.DieTime = CurTime() + 0.1
            end
        end
    end
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:DrawTranslucent()
    local startPos = self:GetNWVector("StartPos")
    local endPos = self:GetNWVector("EndPos")
    local beamStartTime = self:GetNWFloat("BeamStartTime", 0)
    local beamDuration = self:GetNWFloat("BeamDuration", 0.3)
    local elapsed = CurTime() - beamStartTime

    if elapsed <= beamDuration then
        render.SetMaterial(Material("cable/blue_elec"))  -- Verifica si este material existe
        render.StartBeam(2)
        render.AddBeam(startPos, 10, 0, Color(255, 255, 255, 255))
        render.AddBeam(endPos, 10, 1, Color(255, 255, 255, 255))
        render.EndBeam()
    end
end