AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Wind"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "MDisasters"

function ENT:Initialize()

    if SERVER then
        self:SetModel("models/props_junk/PopCan01a.mdl") -- invisible
        self:SetNoDraw(true)
        self:SetSolid(SOLID_NONE)

        mdisasters.weather_target.Wind_dir = Vector(math.random(-1000,1000), math.random(-1000,1000),0)
        mdisasters.weather_target.Wind_speed = math.random(5, 10)
        mdisasters.weather_target.Temperature = math.random(5, 15)
        mdisasters.weather_target.Humidity = math.random(25, 40)
        mdisasters.weather_target.Pressure = math.random(980, 990)
        
    end
end

function ENT:OnRemove()
 	if (SERVER) then	
        mdisasters.weather_target.Wind_dir = mdisasters.weather_original.Wind_dir 
        mdisasters.weather_target.Wind_speed = mdisasters.weather_original.Wind_speed
        mdisasters.weather_target.Temperature = mdisasters.weather_original.Temperature
        mdisasters.weather_target.Humidity = mdisasters.weather_original.Humidity
        mdisasters.weather_target.Pressure = mdisasters.weather_original.Pressure
	end
end

function ENT:Think()
    self:NextThink(CurTime() + 1)
    return true
end

function ENT:Draw()
    -- Invisible
end
