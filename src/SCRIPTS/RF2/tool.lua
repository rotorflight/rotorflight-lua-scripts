chdir("/SCRIPTS/RF2")

rf2 = {
    -- global vars
    runningInSimulator = string.sub(select(2,getVersion()), -4) == "simu",
    lastChangedServo = 1, -- TODO: change to 0
    protocol = nil,
    radio = nil,
    mspQueue = nil,
    mspHelper = nil,
    sensor = nil,
    lcdNeedsInvalidate = false,

    -- global functions
    dataBindFields = nil,
    log = nil,

    -- TODO: remove
    apiVersion = 0,
    mcuId = nil
}

local run = nil
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()

if scriptsCompiled then
    rf2.protocol = assert(loadScript("protocols.lua"))()
    rf2.radio = assert(loadScript("radios.lua"))().msp
    rf2.mspQueue = assert(loadScript("MSP/mspQueue.lua"))()
    rf2.mspHelper = assert(loadScript("MSP/mspHelper.lua"))()
    assert(loadScript(rf2.protocol.mspTransport))()
    assert(loadScript("MSP/common.lua"))()

    run = assert(loadScript("ui.lua"))()
else
    run = assert(loadScript("COMPILE/compile.lua"))()
end

return { run=run }
