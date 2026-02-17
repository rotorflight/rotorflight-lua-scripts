local name = "rftool"
local versionString = "v0.1.0"
local compile = nil
local run = nil
local useLvgl = false
local timeCreated = nil

if lvgl == nil then
    return {
        name = name,
        options = { },
        create = (function() end),
        refresh = function()
            lcd.drawText(10, 10, "LVGL support required", COLOR_THEME_WARNING)
        end,
    }
end

local rfWidgets = {}
local function registerWidget(widget)
    table.insert(rfWidgets, widget)
end

local function widgetIsAlivePing(widget)
    for k, v in pairs(rfWidgets) do
        if v == widget then
            print("Received ping from widget, updating lastPing time")
            v.lastPing = getTime()
            return
        end
    end
end

local timeLastPing = nil
local function ping()
    if timeLastPing ~= nil and (getTime() - timeLastPing) / 100 < 1 then
        return
    end

    timeLastPing = getTime()
    for k, v in pairs(rfWidgets) do
        if v.lastPing ~= nil  and (getTime() - v.lastPing) / 100 > 5 then
            -- widget is considered dead, remove it from the list
            print("Widget considered dead, removing it")
            table.remove(rfWidgets, k)
        elseif v.ping then
            local status, err = pcall(v.ping, v)
        end
    end
end

local function create(zone, options)
    print("RF2: create called")

    local widget = { 
        zone = zone,
        options = options,
    }

    timeCreated = getTime()

    local scriptsCompiled = assert(loadScript("/SCRIPTS/RF2/COMPILE/scripts_compiled.lua"))()
    if scriptsCompiled then
        widget.state = "loading"
    else
        compile = assert(loadScript("/SCRIPTS/RF2/COMPILE/compile.lua"))()
        widget.state = "compiling"
    end

    return widget
end

local function loadScripts(widget)
    --print("RF2: Before rf2.lua: ", collectgarbage("count") * 1024)
    assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
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
        print("Using LVGL UI")
        run = rf2.executeScript("ui_lvgl_runner")
    else
        print("Using LCD UI")
        run = rf2.executeScript("ui_lcd")
    end
    --rf2.showMemoryUsage("ui loaded")
end

local function showWidget(widget)
    lvgl.clear();
    lvgl.build({
        { 
            type = "box", flexFlow = lvgl.FLOW_COLUMN, children = 
            {
                { type = "label", text = "Rotorflight", w = widget.zone.x, align = CENTER },
            }
        }
    });
end

-- Update function (called when options change)
local function update(widget, options)
    --rf2.print("update called")
    widget.options = options

    if (lvgl.isFullScreen() or lvgl.isAppMode()) then
        rf2.showMainMenu()
    else
        showWidget(widget)
    end
end

-- local lastHelloTime = nil

local function refresh(widget, event, touchState)
    -- print("refresh called")

    -- if lastHelloTime == nil or (getTime() - lastHelloTime) / 100 > 1 then
    --     print("rftool says hello!")
    --     lastHelloTime = getTime()
    -- end

    if widget.state == "compiling" then 
        if compile ~= nil then
            local result = compile()
            if result == 1 then
                compile = nil
                widget.state = "loading"
            end
            return
        end
    elseif widget.state == "loading" and (getTime() - timeCreated) / 100 > 5 then -- bootgrace timeout
        loadScripts(widget)
        widget.state = "ready"

        rf2.model = { name = "test" }
        rf2.print(rf2 and rf2.shared and rf2.shared.modelName or "Unknown")

        rf2.registerWidget = registerWidget
        rf2.widgetIsAlivePing = widgetIsAlivePing
    end

    local noUi = not(lvgl.isFullScreen() or lvgl.isAppMode())
    if run ~= nil then
        run(event, touchState, noUi)
    end

    ping()
end

local function background(widget)
    --rf2.print("background called")
end

return { useLvgl = true, name = name, options = {}, create = create, update = update, refresh = refresh, background = background }
