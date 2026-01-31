chdir("/SCRIPTS/RF2")

local run = nil
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()
local useLvgl = false

if scriptsCompiled then
    --print("RF2: Before rf2.lua: ", collectgarbage("count") * 1024)
    assert(loadScript("rf2.lua"))()
    --rf2.showMemoryUsage("rf2 loaded")
    rf2.radio = rf2.executeScript("radios")
    --rf2.showMemoryUsage("radios loaded")
    rf2.mspQueue = rf2.executeScript("MSP/mspQueue")
    --rf2.showMemoryUsage("MSP queue loaded")
    rf2.mspQueue.maxRetries = 3
    rf2.mspHelper = rf2.executeScript("MSP/mspHelper")
    --rf2.showMemoryUsage("MSP helper loaded")

    local canUseLvgl = rf2.executeScript("F/canUseLvgl")()
    if canUseLvgl then
        local settings = rf2.loadSettings()
        if settings["useLvgl"] == nil or settings["useLvgl"] == 1 then useLvgl = true end
    end

    if useLvgl then
        run = rf2.executeScript("ui_lvgl_runner")
    else
        run = rf2.executeScript("ui_lcd")
    end
    --rf2.showMemoryUsage("ui loaded")

    rf2.isTool = true
else
    run = assert(loadScript("COMPILE/compile.lua"))()
    collectgarbage()
end

return { run = run, useLvgl = useLvgl }
