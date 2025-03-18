function Player_Body_Set(ply)
    ply.mdisasters = {}
    ply.mdisasters.body = {}
    ply.mdisasters.body.Temperature = 36.6
    ply.mdisasters.body.Oxygen = 100

    ply.mdisasters.area = {}
    ply.mdisasters.area.local_wind = 0
    ply.mdisasters.area.isoutdoor = false

    ply:SetNWFloat("BodyTemperature", ply.mdisasters.body.Temperature)
    ply:SetNWFloat("BodyOxygen", ply.mdisasters.body.Oxygen)
    ply:SetNWFloat("BodyWind", ply.mdisasters.body.local_wind)
end

function Player_Body_Reset(ply)
    ply.mdisasters.body.Temperature = 36.6
    ply.mdisasters.body.Oxygen = 100

    ply:SetNWFloat("BodyTemperature", ply.mdisasters.body.Temperature)
    ply:SetNWFloat("BodyOxygen", ply.mdisasters.body.Oxygen)
end

function Weather_Update()
    mdisasters.weather.Temperature = math.Clamp(mdisasters.weather.Temperature, -273.3, 273.3)
    mdisasters.weather.Pressure = math.Clamp(mdisasters.weather.Pressure, 0, math.huge)
    mdisasters.weather.Humidity  = math.Clamp(mdisasters.weather.Humidity, 0, 100)


    mdisasters.weather.Temperature = Lerp(0.005, mdisasters.weather.Temperature, mdisasters.weather.Temperature_change)
    mdisasters.weather.Pressure = Lerp(0.005, mdisasters.weather.Pressure, mdisasters.weather.Pressure_change)
    mdisasters.weather.Wind_speed = Lerp(0.005, mdisasters.weather.Wind_speed, mdisasters.weather.Wind_speed_change)
    mdisasters.weather.Humidity = Lerp(0.005, mdisasters.weather.Humidity, mdisasters.weather.Humidity_change)
    mdisasters.weather.Wind_dir = LerpVector(0.005, mdisasters.weather.Wind_dir, mdisasters.weather.Wind_dir_change)


    Temperature()
    Humidity()
    Oxygen()
    Pressure()
    Wind()
end

function Temperature()

    if GetConVar("mdisasters_hud_temperature_enabled"):GetBool() == false then return end


	local temp = mdisasters.weather.Temperature 
	local humidity = mdisasters.weather.Humidity
	local compensation_max = 10   -- degrees 
	local body_heat_genK = engine.TickInterval() -- basically 1 degree Celsius per second
	local body_heat_genMAX = 0.01/4
	local fire_heat_emission = 50
    local plys = player.GetAll()

    local function updatevars()
        for k,v in pairs(plys) do

			local heatscale               = 0
			local coolscale               = 0

			local core_equilibrium           =  math.Clamp((37 - v.mdisasters.body.Temperature)*body_heat_genK, -body_heat_genMAX, body_heat_genMAX)
			local heatsource_equilibrium     =  math.Clamp((fire_heat_emission * (heatscale ))*body_heat_genK, 0, body_heat_genMAX * 1.3)  -- must be negative cause we wanna temperature difference to only be valid if player is colder than 
			local coldsource_equilibrium     =  math.Clamp((fire_heat_emission * ( coolscale))*body_heat_genK,body_heat_genMAX * -1.3, 0)  -- must be negative cause we wanna temperature difference to only be valid if player is colder than 
		
			local ambient_equilibrium        = math.Clamp(((temp - v.mdisasters.body.Temperature)*body_heat_genK), -body_heat_genMAX*1.1, body_heat_genMAX * 1.1)
			
			if temp >= 5 and temp <= 37 then
				ambient_equilibrium          = 0
			end

            v.mdisasters.body.Temperature = math.Clamp(v.mdisasters.body.Temperature + core_equilibrium  + heatsource_equilibrium + coldsource_equilibrium + ambient_equilibrium, 24, 44)
            
            v:SetNWFloat("BodyTemperature", v.mdisasters.body.Temperature)
        end
    end
    local function Damage()
        if GetConVar("mdisasters_hud_damage_temperature_enabled"):GetBool() == false then return end

        for k,v in pairs(plys) do
            local tempbody = v.mdisasters.body.Temperature
			local alpha_hot  =  1-((44-math.Clamp(tempbody,39,44))/5)
			local alpha_cold =  ((35-math.Clamp(tempbody,24,35))/11)
            
			if math.random(1,25) == 25 then
				if alpha_cold != 0 then
					
					InflictDamage(v, v, "cold", alpha_hot + alpha_cold)
					
					v:SetWalkSpeed( v:GetWalkSpeed() - (alpha_cold + 1) )
					v:SetRunSpeed( v:GetRunSpeed() - (alpha_cold + 1)  )
				
					
				
				elseif alpha_hot != 0 then
					
					InflictDamage(v, v, "heat", alpha_hot + alpha_cold)
					
					v:SetWalkSpeed( v:GetWalkSpeed() - (alpha_hot - 1) )
					v:SetRunSpeed( v:GetRunSpeed() - (alpha_hot - 1)  )
					
					
				else					
					v:SetWalkSpeed( 200 )
					v:SetRunSpeed( 240 )
				end
            end

            if mdisasters.weather.Temperature <= 5 then
                v.mdisasters.body.Temperature = v.mdisasters.body.Temperature + 0.001
            elseif mdisasters.weather.Temperature >= 35 then
                v.mdisasters.body.Temperature = v.mdisasters.body.Temperature - 0.001
            elseif  mdisasters.weather.Temperature <= -100 then
                v.mdisasters.body.Temperature = v.mdisasters.body.Temperature - 0.01
            elseif mdisasters.weather.Temperature >= 100 then
                v.mdisasters.body.Temperature = v.mdisasters.body.Temperature + 0.01
            elseif mdisasters.weather.Temperature <= -500 then
                v.mdisasters.body.Temperature = v.mdisasters.body.Temperature - 0.1
            elseif mdisasters.weather.Temperature >= 500 then
                v.mdisasters.body.Temperature = v.mdisasters.body.Temperature + 0.1
            end

            if v:WaterLevel() >= 3 then
                v.mdisasters.body.Temperature = v.mdisasters.body.Temperature - 0.001
            end
            
            if v.mdisasters.body.Temperature >= 45 or v.mdisasters.body.Temperature <= 25 then 
                if v:Alive() then v:Kill() end 
            end
        end     
    end
    Damage()
    updatevars()
end

function Humidity()
    
end

function Pressure()
    
end

function Wind()
    
end

local delay = 0

function Oxygen() 
    
    if GetConVar("mdisasters_hud_oxygen_enabled"):GetBool() == false then return end

    if CurTime() < delay then return end

    for k, v in pairs(player.GetAll()) do
        
        if v:WaterLevel() >= 3 then
            if CurTime() < delay then return end
            
            v.mdisasters.body.Oxygen = math.Clamp( v.mdisasters.body.Oxygen - 5,0,100 )
            
            
        else
            v.mdisasters.body.Oxygen = math.Clamp( v.mdisasters.body.Oxygen + 5,0,100 )
        end

        if v.mdisasters.body.Oxygen <= 0 then
            if GetConVar("mdisasters_hud_damage_oxygen_enabled"):GetBool() == false then return end


            if math.random(1,5) == 5 then
                local dmg = DamageInfo()
                dmg:SetDamage( math.random(1,25) )
                dmg:SetAttacker( v )
                dmg:SetDamageType( DMG_DROWN  )
            
        
                v:TakeDamageInfo(  dmg)
            end
        end

        v:SetNWFloat("BodyOxygen", v.mdisasters.body.Oxygen)
    end
    delay = CurTime() + 0.5
end

hook.Add("Think", "Weather_Update", Weather_Update)
hook.Add("PlayerInitialSpawn", "Player_body_set", Player_Body_Set)
hook.Add("PlayerSpawn", "Player_body_set", Player_Body_Reset)
