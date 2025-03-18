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
ENT.PushForce = 150
ENT.PushForcePlayer = 150



function ENT:Initialize()

    if (CLIENT) then
        LocalPlayer().Sound = CreateSound(LocalPlayer(), "disasters/earthquake/earthquake_loop.wav")
        LocalPlayer().Sound:SetSoundLevel( 120 )
        LocalPlayer().Sound:ChangeVolume( 1 )
        LocalPlayer().Sound:Play()
    end
    if SERVER then
        -- Timer constante del terremoto
        self:SetModel("models/props_junk/rock001a.mdl") -- Modelo opcional
        self:SetNoDraw(true) -- No se ve, puro efecto
        self:SetSolid(SOLID_NONE)

        timer.Simple(100, function()
            if not self:IsValid() then return end
            self:Remove()
        end)


       
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
            if phys:IsValid() then
                -- Trazar una línea hacia abajo desde el centro de la entidad para ver si está tocando el suelo
                local startPos = ent:GetPos()
                local endPos = startPos - Vector(0, 0, 10)  -- 10 unidades hacia abajo
                local traceData = {
                    start = startPos,
                    endpos = endPos,
                    filter = ent
                }
                local traceResult = util.TraceLine(traceData)

                if traceResult.Hit then
                    phys:AddVelocity(VectorRand() * self.PushForce)

                    if math.random(0, 100) == 100 then
                        constraint.RemoveAll(ent)
                        phys:EnableMotion(true)
                        phys:Wake()
                    end
                end
            end
        end
    end
end

function ENT:Think()
    if (SERVER) then 
        self:DoEarthquake()
        
        self:NextThink(CurTime())
        return true 
    end
end

function ENT:OnRemove()
    -- Detiene sonido y timer
    if (CLIENT) then
        LocalPlayer().Sound:Stop()
    end
    timer.Remove("EarthquakeLoop_" .. self:EntIndex())
end

function ENT:Draw()
    -- Invisible, pero si quieres verlo, cambia esto:
    self:DrawModel()
end
