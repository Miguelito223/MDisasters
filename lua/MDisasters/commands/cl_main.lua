function convars()
    CreateConVar( "MDisasters_hud_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_debug_enabled", "0", FCVAR_ARCHIVE, "Mostrar información de depuración de desastres.")

end


hook.Add( "InitPostEntity", "MDisasters_convars_cl", convars)