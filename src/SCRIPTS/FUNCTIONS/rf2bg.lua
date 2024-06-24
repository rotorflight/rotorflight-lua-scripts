assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
rf2.protocol = assert(loadScript(rf2.rfBaseDir.."protocols.lua"))()
assert(loadScript(rf2.rfBaseDir..rf2.protocol.mspTransport))()
assert(loadScript(rf2.rfBaseDir.."MSP/common.lua"))()
local background = assert(loadScript(rf2.rfBaseDir.."background.lua"))()

return { run = background }
