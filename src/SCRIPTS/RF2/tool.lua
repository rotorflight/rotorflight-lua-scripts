chdir("/SCRIPTS/RF2")

local run = nil
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()
local useLvgl = false

if scriptsCompiled then
    --print("RF2: Before rf2.lua: ", collectgarbage("count") * 1024)
    assert(loadScript("rf2.lua"))()
    --rf2.showMemoryUsage("rf2 loaded")
    rf2.protocol = assert(rf2.loadScript("protocols.lua"))()
    --rf2.showMemoryUsage("protocols loaded")
    rf2.radio = assert(rf2.loadScript("radios.lua"))().msp
    --rf2.showMemoryUsage("radios loaded")
    rf2.mspQueue = assert(rf2.loadScript("MSP/mspQueue.lua"))()
    --rf2.showMemoryUsage("MSP queue loaded")
    rf2.mspQueue.maxRetries = rf2.protocol.maxRetries
    rf2.mspHelper = assert(rf2.loadScript("MSP/mspHelper.lua"))()
    --rf2.showMemoryUsage("MSP helper loaded")
    assert(rf2.loadScript(rf2.protocol.mspTransport))()
    --rf2.showMemoryUsage("mspTransport loaded")
    rf2.mspCommon = assert(rf2.loadScript("MSP/common.lua"))()
    --rf2.showMemoryUsage("common loaded")

    if rf2.canUseLvgl then
        local settings = rf2.loadSettings()
        if settings["useLvgl"] == nil or settings["useLvgl"] == 1 then useLvgl = true end
    end

    if useLvgl then
        run = assert(rf2.loadScript("ui_lvgl_runner.lua"))()
    else
        run = assert(rf2.loadScript("ui_lcd.lua"))()
    end
    --rf2.showMemoryUsage("ui loaded")
else
    run = assert(loadScript("COMPILE/compile.lua"))()
    collectgarbage()
end

return { run = run, useLvgl = useLvgl }
