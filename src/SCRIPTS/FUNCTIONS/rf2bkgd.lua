chdir("/SCRIPTS/RF")
apiVersion = 0
protocol = assert(loadScript("protocols.lua"))()
assert(loadScript(protocol.mspTransport))()
assert(loadScript("MSP/common.lua"))()
local background = assert(loadScript("background.lua"))()

return { run=background }
