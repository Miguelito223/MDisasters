AddCSLuaFile()

ENT.Base 			= "base_anim"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.PrintName = "Tornado"

ENT.Category = "MDisasters"

ENT.Radius = 50000
ENT.Strength = 20000
ENT.Speed = 10
ENT.EnhancedFujitaScale = "EF0"
ENT.Model = "models/props_c17/oildrum001.mdl"  -- Modelo para el tornado
ENT.Mass = 100




function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)  -- Cambia a VPHYSICS momentáneamente

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(self.Mass)
            phys:EnableMotion(false)
        end

        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetNoDraw(true)  -- Haz visible por ahora para test

        local dir = VectorRand()
        dir.z = 0
        dir:Normalize()
        self.Direction = dir
        self.NextDirectionChange = CurTime() + 5

        timer.Simple(100, function()
            if not self:IsValid() then return end
            self:Remove()
        end)
        
        ParticleEffectAttach("tornado", PATTACH_POINT_FOLLOW, self, 0)
        self.Sound = CreateSound(self, "disasters/tornado/tornado_loop.wav")
        self.Sound:ChangeVolume( 1 )
        self.Sound:SetSoundLevel( 120 )
        self.Sound:Play()
    end
end

function ENT:Physics()
    local tornadoPos = self:GetPos()
    for _, ent in ipairs(ents.GetAll()) do
        if ent:IsValid() then
            local distSqr = ent:GetPos():DistToSqr(tornadoPos)
            if distSqr < self.Radius ^ 2 and distSqr > 0 then
                local direction = self.Direction
                local distance = math.sqrt(distSqr)

                -- Fuerza de atracción horizontal
                local pullForce = direction * (self.Strength / distance)


                -- Fuerza vertical proporcional a cercanía (efecto cono)
                local verticalForce = Vector(0, 0, 1) * (self.Strength * 0.5 / distance)

                -- Fuerza de giro/vórtice (perpendicular a la dirección)
                local vortexDir = Vector(-direction.y, direction.x, 0)  -- 90 grados rotado
                local vortexForce = vortexDir * (self.Strength * 0.3 / distance)

                -- Suma de fuerzas totales
                local totalForce = pullForce + verticalForce + vortexForce

                if ent:GetClass() == "prop_physics" then
                    local phys = ent:GetPhysicsObject()
                    -- Aplicar la fuerza modificando la velocidad
                    phys:AddVelocity(totalForce)

                    if math.random(0,50) == 50 then
                        constraint.RemoveAll( ent )
			            ent:GetPhysicsObject():EnableMotion( true )
                    end

                elseif ent:IsPlayer() or ent:IsNPC() then
                    ent:SetVelocity(totalForce)
                end
                
            end
        end
    end
end

function Vec2D(vec)
	return Vector(vec.x, vec.y, 0)
end

function ENT:BounceFromWalls(dir)
	local selfPos = self:GetPos()
	local traceStart = selfPos + (dir * self.Speed)
	local traceEnd = selfPos + (dir * 8 * self.Speed)

	local tr = util.TraceLine({
		start = traceStart,
		endpos = traceEnd,
		mask = MASK_WATER + MASK_SOLID_BRUSHONLY
	})

	if tr.Hit then
        self.Direction = -dir
		self.NextDirectionChange = CurTime() + 5
	end
end

function ENT:Move()
    -- Cambiar levemente la dirección cada 5 segundos
    if CurTime() >= self.NextDirectionChange then
        local randomAngle = Angle(0, math.random(-15, 15), 0)
        self.Direction:Rotate(randomAngle)
        self.Direction:Normalize()
        self.NextDirectionChange = CurTime() + 5
    end

    -- Intentar mover el tornado horizontalmente
    local horizontalMove = self.Direction * self.Speed
    local currentPos = self:GetPos()
    local nextPos = currentPos + horizontalMove

    -- Trazar hacia abajo desde el siguiente punto para encontrar el suelo
    local traceData = {
        start = nextPos + Vector(0, 0, 500),     -- desde arriba
        endpos = nextPos - Vector(0, 0, 1000),   -- hasta abajo
        filter = self
    }
    local tr = util.TraceLine(traceData)

    if tr.Hit then
        -- Coloca el tornado a una altura fija sobre el suelo
        nextPos.z = tr.HitPos.z + 50  -- 50 unidades sobre el suelo
    end

    self:SetPos(nextPos)

    -- Rebote en muros u obstáculos sólidos
    self:BounceFromWalls(self.Direction)
end


function ENT:Think()
    if (SERVER) then
        if !self:IsValid() then return end

        self:Physics()
        self:Move()

        self:NextThink(CurTime())
        return true
    end 
end

function ENT:OnRemove()
    if SERVER then
        self.Sound:Stop()
    end
end


function ENT:Draw()



	self:DrawModel()
	
end