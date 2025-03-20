function PostSpawnCL(ply)
    LocalPlayer().mdisasters = {}
    
    LocalPlayer().mdisasters.HUD = {}
    LocalPlayer().mdisasters.HUD.NextWarningSoundTime = CurTime()
    LocalPlayer().mdisasters.HUD.NextHeartSoundTime   = CurTime()
    LocalPlayer().mdisasters.HUD.NextVomitTime        = CurTime()
    LocalPlayer().mdisasters.HUD.NextVomitBloodTime   = CurTime()
    LocalPlayer().mdisasters.HUD.VomitIntensity       = 0
    LocalPlayer().mdisasters.HUD.BloodVomitIntensity  = 0
    LocalPlayer().mdisasters.HUD.NextSneezeTime       = CurTime()
    LocalPlayer().mdisasters.HUD.NextSneezeBigTime  = CurTime()
    LocalPlayer().mdisasters.HUD.SneezeIntensity       = 0
    LocalPlayer().mdisasters.HUD.SneezeBigIntensity  = 0

    LocalPlayer().mdisasters.Outside = {}
    LocalPlayer().mdisasters.Outside.IsOutside     = false
    LocalPlayer().mdisasters.Outside.OutsideFactor = 0

    LocalPlayer().Sounds = {}
end

hook.Add("InitPostEntity", "PostSpawncl", PostSpawnCL)