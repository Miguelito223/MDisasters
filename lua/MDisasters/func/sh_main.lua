function MDisasters:convert_AngleToVector(angle)
   return angle:Forward()
end
   
function MDisasters:convert_VectorToAngle(vector)
   return vector:Angle()
end

function MDisasters:GetPhysicsMultiplier()

	return (200/3) / ( 1 / ( engine.TickInterval() ) )
end

function MDisasters:HitChance(chance)
	if (SERVER) then 
	
		return math.random() < ( math.Clamp(chance * MDisasters:GetPhysicsMultiplier(),0,100)/100)
	elseif (CLIENT) then 
	
		return math.random() < ( math.Clamp(chance * MDisasters:GetFrameMultiplier(),0,100)/100)

	
	end
end