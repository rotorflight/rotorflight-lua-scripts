-- RfTool widget
local zone, options = ...

local previousArmState = 0

local w = { 
    zone = zone,
    options = options
}

local scriptsCompiled = assert(loadScript("/SCRIPTS/RF2/COMPILE/scripts_compiled.lua"))()
if scriptsCompiled then
    w.state = "loading"
else
    w.state = "compiling"
end

w.options.getText = function(options) 
    return options.sourceName .. ": " .. tostring(getValue(options.sourceName)) .. options.Suffix 
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

local function publishStateChangedEvent(newState)
    for k, v in pairs(rfWidgets) do
        if v.lastPing ~= nil  and (getTime() - v.lastPing) / 100 > 5 then
            -- previously registered widget is considered dead, remove it from the list
            print("Widget considered dead, removing it")
            table.remove(rfWidgets, k)
        elseif v.onStateChanged then
            local status, err = pcall(v.onStateChanged, v, newState)
        end
    end
end

w.setState = function(self, state)
    -- This function will also be called from the background task
    if self.state == state then return end
    self.state = state
    if state == "disconnected" then
        rf2.modelName = nil
        previousArmState = 0
    end
    publishStateChangedEvent(self.state)
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

    rf2.widget = widget
end

local function getModelName()
    local modelName = rf2 and rf2.modelName or nil

    if not modelName then
         modelName = model.getInfo().name
    end

    return modelName or "Unknown"
end

local function showWidget(widget)
    lvgl.clear();
    lvgl.build({
        { 
            type = "box", flexFlow = lvgl.FLOW_COLUMN, children = 
            {
                { type = "label", text = function() return getModelName() end, w = widget.zone.x, font = DBLSIZE, align = CENTER },
                { type = "label", text = function() return rf2 and rf2.widget.options:getText() or "" end, w = widget.zone.x, align = CENTER },
                { type = "label", text = function() return widget.state end, w = widget.zone.x, align = CENTER },
            }
        }
    });
end

w.update = function(widget, options)
    widget.options = options
    if options and options.Source and getFieldInfo then
        local fieldInfo = getFieldInfo(options.Source)
        if fieldInfo then
            widget.options.sourceName = fieldInfo.name
            print("RF2: source name: ", widget.options.sourceName)
        end
    end

    if (lvgl.isFullScreen() or lvgl.isAppMode()) and widget.state == "connected" then
        rf2.showMainMenu()
    else
        showWidget(widget)
    end
end

local function setArmState(widget)
    if not getValue then return end
    local armState = getValue("ARM")
    if armState ~= previousArmState then
        previousArmState = armState
        local state = bit32.btest(armState, 1) and "armed" or "disarmed"
        widget:setState(state)
    end
end

w.background = function(widget)
    setArmState(widget)

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

        rf2.registerWidget = registerWidget
        rf2.widgetIsAlivePing = widgetIsAlivePing -- TODO: replace ping with destroy + unregisterWidget once destroy gets implemented in the EdgeTX widget interface, see https://github.com/EdgeTX/edgetx/issues/7104
    end

    local noUi = not(lvgl.isFullScreen() or lvgl.isAppMode())
    if uiTask ~= nil then
        uiTask(event, touchState, noUi)
    end

    w.background(widget)
end


return w
