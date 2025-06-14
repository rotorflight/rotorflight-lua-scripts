assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
rf2.protocol = rf2.executeScript("protocols")
rf2.mspQueue = rf2.executeScript("MSP/mspQueue")
rf2.mspQueue.maxRetries = rf2.protocol.maxRetries
rf2.mspHelper = rf2.executeScript("MSP/mspHelper")
rf2.executeScript(rf2.protocol.mspTransport)
rf2.mspCommon = rf2.executeScript("MSP/common")
local background = rf2.executeScript("background")

return { run = background }
