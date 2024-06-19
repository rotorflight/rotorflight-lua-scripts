local toolName = "TNS|Rotorflight 2|TNE"
chdir("/SCRIPTS/RF2")

apiVersion = 0
mcuId = nil
runningInSimulator = string.sub(select(2,getVersion()), -4) == "simu"
rf2 = {
    log = function(str)
        local f = io.open("/LOGS/rf2.log", 'a')
        io.write(f, str .. "\n")
        io.close(f)
    end
}

local run = nil
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()

if scriptsCompiled then
    protocol = assert(loadScript("protocols.lua"))()
    radio = assert(loadScript("radios.lua"))().msp
    assert(loadScript(protocol.mspTransport))()
    assert(loadScript("MSP/common.lua"))()
    run = assert(loadScript("ui.lua"))()
else
    run = assert(loadScript("COMPILE/compile.lua"))()
end

return { run=run }
