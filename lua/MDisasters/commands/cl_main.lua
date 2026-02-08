function convars()
    CreateConVar( "MDisasters_hud_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_debug_draw_enabled", "0", FCVAR_ARCHIVE, "Activar modo debug de MDisasters" )
end


hook.Add( "InitPostEntity", "MDisasters_convars_cl", convars)