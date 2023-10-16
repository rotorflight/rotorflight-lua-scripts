rfBaseDir = "/SCRIPTS/RF2/"
apiVersion = 0
protocol = assert(loadScript(rfBaseDir.."protocols.lua"))()
assert(loadScript(rfBaseDir..protocol.mspTransport))()
assert(loadScript(rfBaseDir.."MSP/common.lua"))()
local background = assert(loadScript(rfBaseDir.."background.lua"))()

return { run=background }
