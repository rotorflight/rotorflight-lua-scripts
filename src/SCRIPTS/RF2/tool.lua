chdir("/SCRIPTS/RF2")

local run = nil
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()

if scriptsCompiled then
    assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
    rf2.lastChangedServo = 1
    rf2.protocol = assert(loadScript("protocols.lua"))()
    rf2.radio = assert(loadScript("radios.lua"))().msp
    rf2.mspQueue = assert(loadScript("MSP/mspQueue.lua"))()
    rf2.mspQueue.maxRetries = rf2.protocol.maxRetries
    rf2.mspHelper = assert(loadScript("MSP/mspHelper.lua"))()
    assert(loadScript(rf2.protocol.mspTransport))()
    assert(loadScript("MSP/common.lua"))()

    run = assert(loadScript("ui.lua"))()
else
    run = assert(loadScript("COMPILE/compile.lua"))()
end

return { run=run }
