AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Rain"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "MDisasters"

function ENT:Initialize()
    if (CLIENT) then
        LocalPlayer().Sound =  CreateLoopedSound(LocalPlayer(), "ambient/weather/rumble_rain_loop.wav")
    end
    if SERVER then
        mdisasters.weather_target.Wind_dir = Vector(math.random(-1000,1000), math.random(-1000,1000),0)
        mdisasters.weather_target.Wind_speed = math.random(5, 10)
        mdisasters.weather_target.Temperature = math.random(5, 15)
        mdisasters.weather_target.Humidity = math.random(25, 40)
        mdisasters.weather_target.Pressure = math.random(980, 990)
        
        self:SetModel("models/props_junk/PopCan01a.mdl") -- invisible prop
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		self.Original_SkyData = {}
        self.Original_SkyData["TopColor"]    = Vector(0.2, 0.2, 0.2)
        self.Original_SkyData["BottomColor"] = Vector(0.2, 0.2, 0.2)
        self.Original_SkyData["DuskScale"]   = 0
			
		self.Reset_SkyData = {}
        self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
        self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
        self.Reset_SkyData["DuskScale"]      = 1
        self.Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00)
		


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

        net.Start("md_clparticles")
        net.WriteString("rain_effect")
        net.Send(ply)

        net.Start("md_clparticles_ground")
        net.WriteString("rain_effect_ground")
        net.Send(ply)


    end
end

function ENT:OnRemove()
	if (SERVER) then		
        mdisasters.weather_target.Wind_dir = mdisasters.weather_original.Wind_dir 
        mdisasters.weather_target.Wind_speed = mdisasters.weather_original.Wind_speed
        mdisasters.weather_target.Temperature = mdisasters.weather_original.Temperature
        mdisasters.weather_target.Humidity = mdisasters.weather_original.Humidity
        mdisasters.weather_target.Pressure = mdisasters.weather_original.Pressure

		for i=0, 40 do
			timer.Simple(i/100, function()
				paintSky_Fade(self.Reset_SkyData,0.05)
			end)
		end
		setMapLight("t")
    end
    if CLIENT then
        LocalPlayer().Sound:Stop()
    end
end

function ENT:Think()
    local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate


    if (SERVER) then
        self:RainEffect()
        self:NextThink(CurTime() +  t)
        return true
    end
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end
