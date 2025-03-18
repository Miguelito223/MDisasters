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
        else
            print("[Tornado] Physics object is INVALID")
        end

        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetNoDraw(false)  -- Haz visible por ahora para test

        local bounds = getMapBounds()
        if not bounds then
            print("[Tornado] Map bounds not valid!")
            self:Remove()
            return
        end
        self.MapMinBounds = bounds[1]
        self.MapMaxBounds = bounds[2]

        local dir = VectorRand()
        dir.z = 0
        dir:Normalize()
        self.Direction = dir
        self.NextDirectionChange = CurTime() + 5
        
        ParticleEffectAttach("tornado", PATTACH_POINT_FOLLOW, self, 0)
        self:EmitSound("disasters/tornado/tornado_loop.wav", 100, 100, 1, CHAN_LOOPING)

        print("[Tornado] Initialized successfully at", self:GetPos())
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

                    if math.random(0,25) == 25 then
                        constraint.RemoveAll( ent )
			            ent:GetPhysicsObject():EnableMotion( true )
                    end

                elseif ent:IsPlayer() or ent:IsNPC() then
                    local vec = (8 * 25) * Vector(0,0,math.random(0,10)/10) + (Vector(10,10,0)*math.sin(CurTime()*4))
                    ent:SetVelocity(totalForce + vec)
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
		print("[Tornado] Rebotó contra pared. Normal:", tr.HitNormal)
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

	-- Intentar mover el tornado
	local newPos = self:GetPos() + self.Direction * self.Speed
	self:SetPos(newPos)

	-- Hacer el rebote si choca con algo sólido
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

end


function ENT:Draw()



	self:DrawModel()
	
end