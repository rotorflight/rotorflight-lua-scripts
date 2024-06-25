assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
rf2.protocol = assert(rf2.loadScript(rf2.baseDir.."protocols.lua"))()
assert(rf2.loadScript(rf2.baseDir..rf2.protocol.mspTransport))()
assert(rf2.loadScript(rf2.baseDir.."MSP/common.lua"))()
local background = assert(rf2.loadScript(rf2.baseDir.."background.lua"))()

return { run = background }
