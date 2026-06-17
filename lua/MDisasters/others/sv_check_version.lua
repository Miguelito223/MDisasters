-- Checks the workshop page for version number.
local function RunCheck()
    http.Fetch(MDisasters.WorkShopURL, function(code)
        local lV = tonumber(string.match(code, "Version:(.-)<"))
        if not lV then return end -- Unable to locate last version
        if MDisasters.Version >= lV then return end
        MDisasters.msg("Version " .. lV .. " is out!")
        cookie.Set("md_nextv", lV)
    end)
end
local function RunLogic()
    -- Check if a newer version is out
    local lV = cookie.GetNumber("md_nextv", MDisasters.Version)
    if cookie.GetNumber("md_nextvcheck", 0) > os.time() then
        if lV > MDisasters.Version then
            MDisasters.msg("Version " .. lV .. " is out!")
        end
    else
        RunCheck()
        cookie.Set("md_nextvcheck", os.time() + 129600) -- Check in 1½ day
    end
end
hook.Add("PlayerInitialSpawn", "MDisasters_checkversion", RunLogic)