function convars()
    CreateConVar( "mdisasters_hud_enabled", "1", {FCVAR_ARCHIVE}, "" )
end


hook.Add( "InitPostEntity", "mdisasters_convars_cl", convars)