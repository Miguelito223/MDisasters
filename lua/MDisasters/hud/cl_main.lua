
hook.Add("HUDPaint", "MDisasters_HUDPaint", function() 

    if GetConVar("mdisasters_hud_enabled"):GetBool() == false then return end 

    local w, h = ScrW(), ScrH() 
    local function boxes()
        draw.RoundedBox(5, 300, 800, 600, 300, Color(0, 0, 0, 129)) 
        draw.RoundedBox(5, 600, 800, 300, 300, Color(0, 0, 0, 129))
        draw.RoundedBox(5, 750, 800, 150, 150, Color(00, 0, 0, 129))  
    end
    local function text()
        draw.DrawText("Temperature: " .. tostring( mdisasters.weather.Temperature ) .. "ºC", "HudDefault", 450, 820, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText("Humidity: " .. tostring( mdisasters.weather.Humidity ) .. " %", "HudDefault", 450, 840, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText("Wind Speed: " .. tostring( mdisasters.weather.Wind_speed ) .. " km/h", "HudDefault", 450, 880, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText("Wind Dir: " .. tostring( mdisasters.weather.Wind_dir:Angle().y ) .. "º", "HudDefault", 450, 920, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText("Body temperature: " .. tostring( LocalPlayer():GetNWFloat("BodyTemperature")) .. "ºC", "HudDefault", 450, 940, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText("Body Oxygen: " .. tostring( LocalPlayer():GetNWFloat("BodyOxygen")) .. " %", "HudDefault", 450, 980, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText("Body Wind speed: " .. tostring(LocalPlayer():GetNWFloat("BodyWind")) .. " km/h", "HudDefault", 450, 1020, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end


    boxes()
    text()
end)