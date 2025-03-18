function convars()
    CreateConVar( "mdisasters_hud_oxygen_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_hud_temperature_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_hud_damage_oxygen_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_hud_damage_temperature_enabled", "1", {FCVAR_ARCHIVE}, "" )
end


hook.Add( "InitPostEntity", "mdisasters_convars_init_sh", convars)