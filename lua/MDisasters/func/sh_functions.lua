function convert_AngleToVector(angle)
   return angle:Forward()
end
   
function convert_VectorToAngle(vector)
   return vector:Angle()
end

function isOutdoor(ent)
   local traceData = {}
   traceData.start = ent:GetPos()
   traceData.endpos = ent:GetPos() + Vector(0, 0, 1000)  -- 1000 units hacia arriba
   traceData.filter = ent
   local tr = util.TraceLine(traceData)

   if ent:IsPlayer() then
      net.Start("md_isOutdoor")
      net.WriteBool(tr.Hit)
      net.Send(ent)
      ent.mdisasters.area.isoutdoor = tr.Hit
   end

   return not tr.Hit  -- Si no golpea nada arriba, está al aire libre
end