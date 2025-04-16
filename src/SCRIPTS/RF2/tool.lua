local baseDir = "/SCRIPTS/RF2/"
chdir(baseDir)

local run = nil
local scriptsCompiled = assert(loadScript(baseDir.."COMPILE/scripts_compiled.lua"))()

if scriptsCompiled then
    --print("RF2: Before rf2.lua: ", collectgarbage("count") * 1024)
    assert(loadScript(baseDir.."rf2.lua"))()
    --rf2.showMemoryUsage("rf2 loaded")
    rf2.protocol = assert(rf2.loadScript("protocols.lua"))()
    --rf2.showMemoryUsage("protocols loaded")
    rf2.radio = assert(rf2.loadScript("radios.lua"))()
    --rf2.showMemoryUsage("radios loaded")
    rf2.mspQueue = assert(rf2.loadScript("MSP/mspQueue.lua"))()
    --rf2.showMemoryUsage("MSP queue loaded")
    rf2.mspQueue.maxRetries = rf2.protocol.maxRetries
    rf2.mspHelper = assert(rf2.loadScript("MSP/mspHelper.lua"))()
    --rf2.showMemoryUsage("MSP helper loaded")
    assert(rf2.loadScript(rf2.protocol.mspTransport))()
    --rf2.showMemoryUsage("mspTransport loaded")
    assert(rf2.loadScript("MSP/common.lua"))()
    --rf2.showMemoryUsage("common loaded")

    run = assert(rf2.loadScript("ui.lua"))()
    --rf2.showMemoryUsage("ui loaded")

else
    run = assert(loadScript(baseDir.."COMPILE/compile.lua"))()
    collectgarbage()
end

return { run = run }
