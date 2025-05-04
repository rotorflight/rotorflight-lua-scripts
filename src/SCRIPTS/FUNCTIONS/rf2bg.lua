assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
rf2.protocol = assert(rf2.loadScript(rf2.baseDir.."protocols.lua"))()
rf2.mspQueue = assert(rf2.loadScript(rf2.baseDir.."MSP/mspQueue.lua"))()
rf2.mspQueue.maxRetries = rf2.protocol.maxRetries
rf2.mspHelper = assert(rf2.loadScript(rf2.baseDir.."MSP/mspHelper.lua"))()
assert(rf2.loadScript(rf2.baseDir..rf2.protocol.mspTransport))()
rf2.mspCommon = assert(rf2.loadScript(rf2.baseDir.."MSP/common.lua"))()
local background = assert(rf2.loadScript(rf2.baseDir.."background.lua"))()

return { run = background }
