rfBaseDir = "/SCRIPTS/RF2/"

rf2 = {
    runningInSimulator = string.sub(select(2,getVersion()), -4) == "simu",
    apiVersion = 0
}

rf2.protocol = assert(loadScript(rfBaseDir.."protocols.lua"))()
assert(loadScript(rfBaseDir..rf2.protocol.mspTransport))()
assert(loadScript(rfBaseDir.."MSP/common.lua"))()
local background = assert(loadScript(rfBaseDir.."background.lua"))()

return { run=background }
