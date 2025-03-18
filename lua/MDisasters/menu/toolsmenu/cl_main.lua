MDisasters_time = CurTime()

local function AddControlCB(CPanel, label, command)
	return CPanel:CheckBox( label, command )
end
local function AddControlLabel( CPanel, label )
	return  CPanel:Help( language.GetPhrase(label) )
end
local function AddControlSlider( CPanel, label, command, min, max, dp  )
	return  CPanel:NumSlider( label, command, min, max, dp );
end

local function AddComboBox( CPanel, title, listofitems, convar)
		
	local combobox, label = CPanel:ComboBox( language.GetPhrase(title), convar)
		
		
	for k, item in pairs(listofitems) do
		combobox:AddChoice(item)
	end
		
	return combobox
end
	
local function CreateTickboxConVariable(CPanel, desc, convarname)
	local CB = AddControlCB(CPanel, language.GetPhrase(desc), convarname)
	
 
	CB.OnChange = function( panel, bVal ) 
		if (CurTime() - MDisasters_time) < 1 then return end 

		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( convarname ) ) then return end
			net.Start( "md_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
			
			timer.Simple(0.1, function()
				if( CB ) then
					CB:SetValue( GetConVar(( convarname )):GetFloat() );
				end
			end)
		end
	end

	
	return CB 
	
end

local function CreateSliderConVariable(CPanel, desc, minvar, maxvar, dp, convarname)
	local CB = AddControlSlider( CPanel, language.GetPhrase(desc), convarname, minvar, maxvar, dp  )
	

	CB.OnValueChanged = function( panel, val )
		if (CurTime() - MDisasters_time) < 1 then return end 
		
		
		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and !Created ) then
			if ( tonumber(val) ) == cvars.Number( convarname )  then return end
			net.Start( "md_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat( tonumber(val) );
			net.SendToServer();
			
			timer.Simple(0.1, function()
				
				if( CB ) then
					CB:SetValue( GetConVar(( convarname )):GetFloat() );
				end
			end)
		end
		
	end

	
	return CB
end

local function MDisastersSettings( CPanel )
    CreateTickboxConVariable(CPanel, "Enable Oxygen" ,"mdisasters_hud_oxygen_enabled");
    CreateTickboxConVariable(CPanel, "Enable Temp" ,"mdisasters_hud_temperature_enabled");
    CreateTickboxConVariable(CPanel, "Enable Oxygen Damage" ,"mdisasters_hud_damage_oxygen_enabled");
    CreateTickboxConVariable(CPanel, "Enable Temp Damage" ,"mdisasters_hud_damage_temperature_enabled");

end

local function MDisastersSettingsClient( CPanel )
    CreateTickboxConVariable(CPanel, "Enable Hud" ,"mdisasters_hud_enabled");
end

local function MDisastersSettingsServer( CPanel )

end

hook.Add( "AddToolMenuTabs", "MDisasters_Tab", function()
	spawnmenu.AddToolTab( "MDisasters", "#MDisasters", "icon16/weather_clouds.png" )
end)

hook.Add( "PopulateToolMenu", "MDisasters_PopulateMenu", function()
	

	spawnmenu.AddToolMenuOption( "MDisasters", "Shared", "MDisastersSettings", "Main", "", "", MDisastersSettings )
	spawnmenu.AddToolMenuOption( "MDisasters", "Server", "MDisastersSettingsServer", "Main", "", "", MDisastersSettingsServer )
    spawnmenu.AddToolMenuOption( "MDisasters", "Client", "MDisastersSettingsClient", "Main", "", "", MDisastersSettingsClient )


end );
