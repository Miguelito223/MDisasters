AddCSLuaFile()

ENT.Base = "base_anim"

ENT.Spawnable = true
ENT.AdminOnly = false
ENT.PrintName = "Earthquake"
ENT.Category = "MDisasters"

ENT.Radius = 1500
ENT.ShakeIntensity = 15
ENT.ShakeDuration = 1
ENT.ShakeFreq = 5 -- frecuencia de la sacudida
ENT.PushForce = 15000
ENT.PushForcePlayer = 150


function ENT:Initialize()
    self:SetModel("models/props_junk/rock001a.mdl") -- Modelo opcional
    self:SetNoDraw(true) -- No se ve, puro efecto
    self:SetSolid(SOLID_NONE)

    if SERVER then
        -- Timer constante del terremoto
        timer.Create("EarthquakeLoop_" .. self:EntIndex(), 0.1, 1000, function()
            if not IsValid(self) then return end
            self:DoEarthquake()
        end)

        -- Sonido de terremoto constante
        self:EmitSound("disasters/earthquake/earthquake_loop.wav", 100, 100, 1, CHAN_LOOPING)
    end
end

function ENT:DoEarthquake()
    local pos = self:GetPos()

    -- Sacude la pantalla cerca del epicentro
    util.ScreenShake(pos, self.ShakeIntensity, self.ShakeFreq, self.ShakeDuration, self.Radius)

    for _, ent in ipairs(ents.GetAll()) do
        if ent:IsPlayer() or ent:IsNPC() then
            -- ⚡ Empuje solo horizontal (X, Y), sin levantar en Z
            local randVec = VectorRand()
            randVec.z = 0  -- Elimina componente vertical
            local pushForce = randVec:GetNormalized() * self.PushForcePlayer
            
            if ent:IsOnGround() then
                ent:SetVelocity(pushForce)
            end
        else
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) and ent:IsOnGround() then
                phys:ApplyForceCenter(VectorRand() * self.PushForce)

                if math.random(0, 100) == 100 then
                    constraint.RemoveAll(ent)
                    phys:EnableMotion(true)
                end
            end
        end
    end
end

function ENT:OnRemove()
    -- Detiene sonido y timer
    self:StopSound("disasters/earthquake/eartquake.wav")
    timer.Remove("EarthquakeLoop_" .. self:EntIndex())
end

function ENT:Draw()
    -- Invisible, pero si quieres verlo, cambia esto:
    -- self:DrawModel()
end
