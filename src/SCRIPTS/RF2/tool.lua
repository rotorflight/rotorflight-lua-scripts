chdir("/SCRIPTS/RF2")

local run = nil
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()

if scriptsCompiled then
    assert(loadScript("rf2.lua"))()
    rf2.protocol = assert(rf2.loadScript("protocols.lua"))()
    rf2.radio = assert(rf2.loadScript("radios.lua"))().msp
    rf2.mspQueue = assert(rf2.loadScript("MSP/mspQueue.lua"))()
    rf2.mspQueue.maxRetries = rf2.protocol.maxRetries
    rf2.mspHelper = assert(rf2.loadScript("MSP/mspHelper.lua"))()
    assert(rf2.loadScript(rf2.protocol.mspTransport))()
    assert(rf2.loadScript("MSP/common.lua"))()

    run = assert(rf2.loadScript("ui.lua"))()
else
    run = assert(loadScript("COMPILE/compile.lua"))()
    collectgarbage()
end

return { run = run }
