AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Tsunami"
ENT.Category = "MDisasters"
ENT.Spawnable = false

ENT.Model = "models/disasters/tsunami/tsunami.mdl"

function ENT:Initialize()
    if CLIENT then
        LocalPlayer().MDisasters.Sounds.tsunami = MDisasters.CreateLoopedSound(LocalPlayer(), "disasters/water/tsunami_loop.wav")
        LocalPlayer().MDisasters.Sounds.tsunami:Play()
        LocalPlayer().MDisasters.Sounds.tsunami:SetSoundLevel(100)
    end

    if SERVER then
        self:SetModel( self.Model )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( ONOFF_USE )
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetTrigger(true)
        self:SetModelScale(100, 0) -- 🔥 Tsunami gigante

        -- Obtener los límites del mapa
        local bounds = MDisasters_getMapBounds()
        if not bounds then
            MDisasters.msg("Error: Límites del mapa inválidos.")
            self:Remove()
            return
        end

        local min, max, ground = bounds[1], bounds[2], bounds[3]

        -- 🌊 Posición inicial del tsunami
        local spawnOffset = GetConVar("MDisasters_tsunami_offset"):GetInt()
        local spawnSide = math.random(1, 4)
        local spawnPos, velocity

        if spawnSide == 1 then
            spawnPos = Vector(min.x - spawnOffset, (min.y + max.y) / 2, ground.z)
            velocity = Vector(1, 0, 0)
        elseif spawnSide == 2 then
            spawnPos = Vector(max.x + spawnOffset, (min.y + max.y) / 2, ground.z)
            velocity = Vector(-1, 0, 0)
        elseif spawnSide == 3 then
            spawnPos = Vector((min.x + max.x) / 2, min.y - spawnOffset, ground.z)
            velocity = Vector(0, 1, 0)
        else
            spawnPos = Vector((min.x + max.x) / 2, max.y + spawnOffset, ground.z)
            velocity = Vector(0, -1, 0)
        end

        self:SetPos(spawnPos)
        self:SetAngles(velocity:Angle())

        if GetConVar("MDisasters_tsunami_enable_configuration"):GetBool() then
            self.Velocity = velocity * GetConVar("MDisasters_tsunami_velocity"):GetInt()
            self.Force = GetConVar("MDisasters_tsunami_force"):GetInt()
        else
            self.Velocity = velocity * 5000
            self.Force = 5000
        end
    end
end

-- 🔹 Movimiento manual sin físicas
function ENT:Think()
    if SERVER then
        -- Mueve el tsunami sin físicas
        local moveVector = self.Velocity * FrameTime()
        self:SetPos(self:GetPos() + moveVector)

        self:NextThink(CurTime() + 0.1)
        return true
    end
end

-- 🌊 Empuja objetos pero sin bugs
function ENT:Touch(ent)
    if ent == self then return end

    MDisasters.msg("Tsunami golpeando: " .. ent:GetClass() .. " | Fuerza: " .. self.Force) 
    
    local pushForce = self.Velocity:GetNormalized() * self.Force

    if ent:IsPlayer() or ent:IsNPC() then
        ent:SetVelocity(pushForce * 0.5)
        local dmg = DamageInfo()
        dmg:SetDamage( math.random(1,5) )
        dmg:SetAttacker( self )
        dmg:SetDamageType( DMG_GENERIC )
        ent:TakeDamageInfo(dmg)
    else
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:ApplyForceCenter(pushForce * phys:GetMass())    
            constraint.RemoveAll(ent)
            phys:EnableMotion(true)
            phys:Wake()
        end
    end
end

function ENT:OnRemove()
    if CLIENT then
        LocalPlayer().MDisasters.Sounds.tsunami:Stop() 
    end
    self:StopParticles()
end

function ENT:Draw()
    self:DrawModel()
end
