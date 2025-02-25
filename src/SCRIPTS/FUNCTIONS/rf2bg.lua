assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
rf2.protocol = assert(rf2.loadScript("protocols.lua"))()
rf2.mspQueue = assert(rf2.loadScript("MSP/mspQueue.lua"))()
rf2.mspQueue.maxRetries = rf2.protocol.maxRetries
rf2.mspHelper = assert(rf2.loadScript("MSP/mspHelper.lua"))()
assert(rf2.loadScript(rf2.protocol.mspTransport))()
assert(rf2.loadScript("MSP/common.lua"))()
local background = assert(rf2.loadScript("background.lua"))()

return { run = background }
