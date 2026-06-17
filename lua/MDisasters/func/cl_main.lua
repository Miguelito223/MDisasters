function MDisasters.CreateLoopedSound(client, sound)
	local sound = Sound(sound)

	CSPatch = CreateSound(client, sound)
	CSPatch:Play()
	return CSPatch
	
end

function MDisasters.StopLoopedSound(client, sound)
	CSPatch = MDisasters.CreateLoopedSound(client, sound)
	CSPatch:Stop()
	return CSPatch
	
end