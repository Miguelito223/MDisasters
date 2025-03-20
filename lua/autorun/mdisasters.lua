mdisasters = {}
mdisasters.name = "MDisasters"
mdisasters.author = "Miguelillo948"
mdisasters.version = "0.0.1"

function msg(...)
    MsgC(Color(43,255,0), "[MDisasters]",Color(255,255,255), ...)
    MsgN()
end

function error(...)
    MsgC(Color(43,255,0), "[MDisasters]",Color(255,0,0), ...)
    MsgN()
end 

local LuaDirectory = "MDisasters"

local function AddLuaFile( File, directory )
	local prefix = string.lower(File)

	if prefix:StartWith("sv_") or  prefix:StartWith("_sv_") then
		if (SERVER) then
			include( directory .. File )
        	msg("Server Include file: " .. File)
		end
	elseif prefix:StartWith("sh_") or  prefix:StartWith("_sh_") then
		if (SERVER) then
			AddCSLuaFile( directory .. File )
			msg("Shared ADDC file: " .. File)
		end
		include( directory .. File )
		msg("Shared Include file: " .. File)
	elseif prefix:StartWith("cl_") or  prefix:StartWith("_cl_")then
		if (SERVER) then
			AddCSLuaFile( directory .. File )
			msg("Client ADDC file: " .. File)
		elseif (CLIENT) then
			include( directory .. File )
			msg("Client Include file: " .. File)
		end
	end
end

local function LoadLuaFiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddLuaFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		msg("Included Directory:" .. v)
		LoadLuaFiles( directory .. v )
	end
end

LoadLuaFiles( LuaDirectory )

local ParticlesDirectory = "particles/MDisasters"

local function AddParticlesFile( File, directory )
	game.AddParticles(directory .. File)
    msg("Added File: " .. File)
end

local function loadParticles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".pcf" ) then
			AddParticlesFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		msg("Included Directory: " .. v)
		loadParticles( directory .. v )
	end
end

loadParticles( ParticlesDirectory )

PrecacheParticleSystem("meteor_trail")
PrecacheParticleSystem("volcano_trail")
PrecacheParticleSystem("tornado")
PrecacheParticleSystem("volcano_explosion")
PrecacheParticleSystem("rain_effect")
PrecacheParticleSystem("rain_effect_ground")


msg("MDisasters Loaded")
