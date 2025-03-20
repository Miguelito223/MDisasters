function CreateLoopedSound(client, sound)
	local sound = Sound(sound)

	CSPatch = CreateSound(client, sound)
	CSPatch:Play()
	return CSPatch
	
end

function StopLoopedSound(client, sound)
	CSPatch = CreateLoopedSound(client, sound)
	CSPatch:Stop()
	return CSPatch
	
end

function isOutdoors(ent)
   local traceData = {}
   traceData.start = ent:GetPos()
   traceData.endpos = ent:GetPos() + Vector(0, 0, 1000)  -- 1000 units hacia arriba
   traceData.filter = ent
   local tr = util.TraceLine(traceData)

   LocalPlayer().mdisasters.Outside.IsOutside = tr.Hit
   
   return not tr.Hit  -- Si no golpea nada arriba, está al aire libre
end