assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
rf2.protocol = assert(rf2.loadScript(rf2.rfBaseDir.."protocols.lua"))()
assert(rf2.loadScript(rf2.rfBaseDir..rf2.protocol.mspTransport))()
assert(rf2.loadScript(rf2.rfBaseDir.."MSP/common.lua"))()
local background = assert(rf2.loadScript(rf2.rfBaseDir.."background.lua"))()

return { run = background }
