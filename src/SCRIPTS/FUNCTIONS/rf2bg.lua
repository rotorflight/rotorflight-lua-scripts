assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
rf2.mspQueue = rf2.executeScript("MSP/mspQueue")
rf2.mspQueue.maxRetries = 3
rf2.mspHelper = rf2.executeScript("MSP/mspHelper")
rf2.mspCommon = rf2.executeScript("MSP/common")
local background = rf2.executeScript("background")

return { run = background }
