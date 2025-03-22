AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Rain"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "MDisasters"

function ENT:Initialize()
    if SERVER then
        mdisasters.weather_target.Wind_dir = Vector(math.random(-1000,1000), math.random(-1000,1000),0)
        mdisasters.weather_target.Wind_speed = math.random(5, 15)
        mdisasters.weather_target.Temperature = math.random(-5, 0)
        mdisasters.weather_target.Humidity = math.random(25, 40)
        mdisasters.weather_target.Pressure = math.random(980, 990)
        
        self:SetModel("models/props_junk/PopCan01a.mdl") -- invisible prop
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)


        self.snowProps = {}
		self.Original_SkyData = {}
        self.Original_SkyData["TopColor"]    = Vector(0.2, 0.2, 0.2)
        self.Original_SkyData["BottomColor"] = Vector(0.2, 0.2, 0.2)
        self.Original_SkyData["DuskScale"]   = 0
		
        net.Start("md_sendloopsound")
        net.WriteString("weather/wind/wind_effect.wav")
        net.Broadcast()

		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end 
        

        setMapLight("d")

        self:SetNoDraw(true)
    end
end

function ENT:RainEffect()
    for _, ply in ipairs(player.GetAll()) do

        if isOutdoor(ply) then
            net.Start("md_clparticles")
            net.WriteString("snow_effect")
            net.Send(ply)

        end
    end
end

function ENT:OnRemove()
	if (SERVER) then		
        mdisasters.weather_target.Wind_dir = mdisasters.weather_original.Wind_dir 
        mdisasters.weather_target.Wind_speed = mdisasters.weather_original.Wind_speed
        mdisasters.weather_target.Temperature = mdisasters.weather_original.Temperature
        mdisasters.weather_target.Humidity = mdisasters.weather_original.Humidity
        mdisasters.weather_target.Pressure = mdisasters.weather_original.Pressure

        Reset_SkyData = {}
        Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
        Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
        Reset_SkyData["DuskScale"]      = 1
        Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00)   

		for i=0, 40 do
			timer.Simple(i/100, function()
				paintSky_Fade(Reset_SkyData,0.05)
			end)
		end

		setMapLight("t")
        
        net.Start("md_stoploopsound")
        net.WriteString("weather/wind/wind_effect.wav")
        net.Broadcast()
    end
end

function ENT:SpawnSnowground()
    local pos = self:GetPos() -- Cambia esto por la posición que quieras
    local tr = util.TraceLine({
        start = pos + Vector(0, 0, 512),
        endpos = pos - Vector(0, 0, 512),
        mask = MASK_SOLID_BRUSHONLY
    })

    if tr.Hit then
        util.Decal("SnowFootprintLeft", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
    end
end

function ENT:Think()
    local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate

    if (SERVER) then
        self:SpawnSnowground()
        self:RainEffect()
        self:NextThink(CurTime() +  t)
        return true
    end
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end
