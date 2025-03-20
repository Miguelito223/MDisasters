function convert_AngleToVector(angle)
   return angle:Forward()
end
   
function convert_VectorToAngle(vector)
   return vector:Angle()
end

function isOutdoors(ent)
   local traceData = {}
   traceData.start = ent:GetPos()
   traceData.endpos = ent:GetPos() + Vector(0, 0, 1000)  -- 1000 units hacia arriba
   traceData.filter = ent
   local tr = util.TraceLine(traceData)
   return not tr.Hit  -- Si no golpea nada arriba, está al aire libre
end