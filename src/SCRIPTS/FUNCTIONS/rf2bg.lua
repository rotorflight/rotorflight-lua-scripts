rfBaseDir = "/SCRIPTS/RF2/"

apiVersion = 0
runningInSimulator = string.sub(select(2,getVersion()), -4) == "simu"

protocol = assert(loadScript(rfBaseDir.."protocols.lua"))()
assert(loadScript(rfBaseDir..protocol.mspTransport))()
assert(loadScript(rfBaseDir.."MSP/common.lua"))()
local background = assert(loadScript(rfBaseDir.."background.lua"))()

return { run=background }
