function PostSpawnSV(ply)
    ply.mdisasters = {}
    ply.mdisasters.body = {}
    ply.mdisasters.body.Temperature = 36.6
    ply.mdisasters.body.Oxygen = 100

    ply.mdisasters.area = {}
    ply.mdisasters.area.local_wind = 0
    ply.mdisasters.area.isoutdoor = false
    
    ply.Sounds = {}

    ply:SetNWFloat("BodyTemperature", ply.mdisasters.body.Temperature)
    ply:SetNWFloat("BodyOxygen", ply.mdisasters.body.Oxygen)
    ply:SetNWFloat("BodyWind", ply.mdisasters.body.local_wind)
end

function PostSpawnSV_Reset(ply)
    ply.mdisasters.body.Temperature = 36.6
    ply.mdisasters.body.Oxygen = 100

    ply:SetNWFloat("BodyTemperature", ply.mdisasters.body.Temperature)
    ply:SetNWFloat("BodyOxygen", ply.mdisasters.body.Oxygen)
end

hook.Add("PlayerInitialSpawn", "PostSpawnSV", PostSpawnSV)
hook.Add("PlayerSpawn", "PostSpawnSV_Reset", PostSpawnSV_Reset)