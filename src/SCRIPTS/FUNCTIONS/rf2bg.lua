local initialized = false
local backgroundTask = nil

local function startup()
    if not initialized then
        assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
        rf2.mspQueue = rf2.executeScript("MSP/mspQueue")
        rf2.mspQueue.maxRetries = 3
        rf2.mspHelper = rf2.executeScript("MSP/mspHelper")
        backgroundTask = rf2.executeScript("background")
        initialized = true
    else
        backgroundTask()
    end
end

return { run = startup }
