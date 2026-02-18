local zone, options = ...

local w = { 
    zone = zone,
    options = options,
}

local scriptsCompiled = assert(loadScript("/SCRIPTS/RF2/COMPILE/scripts_compiled.lua"))()
if scriptsCompiled then
    w.state = "loading"
else
    w.state = "compiling"
end

local compileTask = nil
local uiTask = nil
local backgroundTask = nil

local timeCreated = getTime()

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

    uiTask = rf2.executeScript("ui_lvgl_runner")
    --uiTask = rf2.executeScript("ui_lcd")
    --rf2.showMemoryUsage("ui loaded")

    backgroundTask = rf2.executeScript("background")
    --rf2.showMemoryUsage("background loaded")
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

w.update = function(widget, options)
    widget.options = options

    if (lvgl.isFullScreen() or lvgl.isAppMode()) then
        rf2.showMainMenu()
    else
        showWidget(widget)
    end
end

w.background = function(widget)
    if widget.state ~= "ready" then return end

    ping()

    if backgroundTask ~= nil then 
        backgroundTask(widget) 
    end
end

w.refresh = function(widget, event, touchState)
    if widget.state == "compiling" then
        compileTask = compileTask or assert(loadScript("/SCRIPTS/RF2/COMPILE/compile.lua"))() 
        if compileTask() == 1 then
            compileTask = nil
            widget.state = "loading"
        end
        return
    elseif widget.state == "loading" and (getTime() - timeCreated) / 100 > 5 then -- bootgrace timeout
        loadScripts(widget)
        widget.state = "ready"

        rf2.model = { name = "test" }
        rf2.print(rf2 and rf2.shared and rf2.shared.modelName or "Unknown")

        rf2.registerWidget = registerWidget
        rf2.widgetIsAlivePing = widgetIsAlivePing -- TODO: replace ping with destroy + unregisterWidget once this gets implemented in the EdgeTX widget interface, see https://github.com/EdgeTX/edgetx/issues/7104
    end

    local noUi = not(lvgl.isFullScreen() or lvgl.isAppMode())
    if uiTask ~= nil then
        uiTask(event, touchState, noUi)
    end

    w.background(widget)
end


return w
