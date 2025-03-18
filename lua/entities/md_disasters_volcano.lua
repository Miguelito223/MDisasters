AddCSLuaFile()

ENT.Base 			= "base_anim"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.PrintName = "volcano"

ENT.Category = "MDisasters"

ENT.Mass = 100

ENT.Model = "models/disasters/volcano/volcano.mdl"

function ENT:Initialize()

    self:DrawShadow( false)
    self:SetModelScale(10, 0)

    if (SERVER) then
        self:SetModel( self.Model )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( ONOFF_USE )

        local phys = self:GetPhysicsObject()

        if (phys:IsValid()) then
            phys:SetMass(self.Mass)
            phys:EnableMotion(false)
        end
		
        timer.Create("Lava_Erupt", 200, 0, function()
            if !self:IsValid() then return end
            self:VolcanoErupt() 
        end)
        
        ParticleEffectAttach("volcano_trail", PATTACH_POINT_FOLLOW, self, 0)
        self.Sound = CreateSound(self, "disasters/volcano/volcano_loop.wav")
        self.Sound:ChangeVolume( 1 )
        self.Sound:SetSoundLevel( 120 )
        self.Sound:Play()
    end
end

function ENT:LavaGlow()

	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.pos = self:GetPos()
		dlight.r = 255
		dlight.g = 67
		dlight.b = 0
		dlight.brightness = 8
		dlight.Decay = 1000
		dlight.Size = 556
		dlight.DieTime = CurTime() + 1
	end
	
end

function ENT:VolcanoErupt()
    self:EmitSound("disasters/volcano/volcano_explosion.wav", 100)
    ParticleEffect( "volcano_explosion", self:GetPos(), Angle(0,0,0) )
    
    local earthquake = ents.Create("md_disasters_earthquake")
    earthquake:Spawn()
    earthquake:Activate()

    for i = 0,5 do
        local rock = ents.Create("md_disasters_meteor")
        rock:Spawn()
        rock:Activate()
        rock:SetPos(self:GetPos() + Vector(0, 0, 100))
        rock:GetPhysicsObject():SetVelocity( Vector(math.random(-10000,10000),math.random(-10000,10000),math.random(5000,10000)) )
        rock:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 ) 
    end
end

function ENT:Think()

	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1	

	if (SERVER) then
	
		self:NextThink(CurTime() + t)
		return true
	
	end
    if CLIENT then
        self:LavaGlow()
    end
			

end

function ENT:OnRemove()
    if SERVER then
        self.Sound:Stop()
    end
    timer.Remove("Lava_Erupt")
end

function ENT:Draw()



	self:DrawModel()
	
end