chdir("/SCRIPTS/RF2")

local run = nil
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()
local useLvgl = false

if scriptsCompiled then
    --print("RF2: Before rf2.lua: ", collectgarbage("count") * 1024)
    assert(loadScript("rf2.lua"))()
    --rf2.showMemoryUsage("rf2 loaded")
    rf2.protocol = rf2.executeScript("protocols")
    --rf2.showMemoryUsage("protocols loaded")
    rf2.radio = rf2.executeScript("radios").msp
    --rf2.showMemoryUsage("radios loaded")
    rf2.mspQueue = rf2.executeScript("MSP/mspQueue")
    --rf2.showMemoryUsage("MSP queue loaded")
    rf2.mspQueue.maxRetries = rf2.protocol.maxRetries
    rf2.mspHelper = rf2.executeScript("MSP/mspHelper")
    --rf2.showMemoryUsage("MSP helper loaded")
    rf2.executeScript(rf2.protocol.mspTransport)
    --rf2.showMemoryUsage("mspTransport loaded")
    rf2.mspCommon = rf2.executeScript("MSP/common")
    --rf2.showMemoryUsage("common loaded")

    if rf2.canUseLvgl then
        local settings = rf2.loadSettings()
        if settings["useLvgl"] == nil or settings["useLvgl"] == 1 then useLvgl = true end
    end

    if useLvgl then
        run = rf2.executeScript("ui_lvgl_runner")
    else
        run = rf2.executeScript("ui_lcd")
    end
    --rf2.showMemoryUsage("ui loaded")
else
    run = assert(loadScript("COMPILE/compile.lua"))()
    collectgarbage()
end

return { run = run, useLvgl = useLvgl }
