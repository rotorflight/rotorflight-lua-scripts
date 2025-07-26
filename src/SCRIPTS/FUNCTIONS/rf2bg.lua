assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
rf2.mspQueue = rf2.executeScript("MSP/mspQueue")
rf2.mspQueue.maxRetries = 3
rf2.mspHelper = rf2.executeScript("MSP/mspHelper")
local background = rf2.executeScript("background")

return { run = background }
