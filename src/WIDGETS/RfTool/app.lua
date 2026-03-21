-- RfTool widget
local zone, options = ...

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
    if not getValue then return options.sourceName .. ": " end
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

local function publishStateChangedEvent(newState)
    for k, v in pairs(rfWidgets) do
        if v.onStateChanged then
            rf2.call(v.onStateChanged, v, newState)
        end
    end
end

local previousArmState = 0
local function setArmState(widget)
    if not getValue then return end -- not available at boot time
    local armState = getValue("ARM")
    --[NIR
    -- Use ANT instead of ARM in the simulator
    if rf2 and rf2.runningInSimulator then armState = getValue("ANT") end
    --]]
    if armState ~= previousArmState then
        previousArmState = armState
        local state = bit32.btest(armState, 1) and "armed" or "disarmed"
        widget:setState(state)
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

local function initializeRf2GlobalVar()
    -- rf2 is the *only* global variable that is used by the Rotorflight scripts.
    --print("RF2: Before rf2.lua: ", collectgarbage("count") * 1024)
    assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
    --rf2.showMemoryUsage("rf2 loaded")
end

local function loadScripts(widget)
    -- load required scripts
    rf2.radio = rf2.executeScript("radios")
    rf2.mspQueue = rf2.executeScript("MSP/mspQueue")
    rf2.mspQueue.maxRetries = 3
    rf2.mspHelper = rf2.executeScript("MSP/mspHelper")

    -- load tasks
    uiTask = rf2.executeScript("ui_lvgl_runner")
    backgroundTask = rf2.executeScript("background")
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
                { type = "label", text = function() return widget.state end, w = widget.zone.x, align = CENTER },
                { type = "label", text = function() return widget.options:getText() end, w = widget.zone.x, align = CENTER },
            }
        }
    });

    widget.visible = true
end

w.update = function(widget, options)
    widget.options = options
    if options and options.Source and getFieldInfo then
        local fieldInfo = getFieldInfo(options.Source)
        if fieldInfo then
            widget.options.sourceName = fieldInfo.name
        end
    end

    if lvgl.isFullScreen() or lvgl.isAppMode() then
        rf2.restartUi()
    else
        showWidget(widget)
    end
end

w.background = function(widget, calledFromRefresh)
    if widget.state == "compiling" then
        compileTask = compileTask or assert(loadScript("/SCRIPTS/RF2/COMPILE/compile.lua"))()
        if compileTask() == 1 then
            compileTask = nil
            widget.state = "loading"
        end
        return
    elseif widget.state == "loading"
        and (getTime() - timeCreated) / 100 > 1 -- bootgrace timeout
    then
        if not rf2.widget then
            rf2.widget = widget
        end
        widget.state = "unknown protocol"
    elseif widget.state == "unknown protocol" then
        local protocol = rf2.executeScript("F/getProtocol")()
        if protocol then
            loadScripts(widget)
            widget.state = "ready"
        end
    end

    setArmState(widget)

    if not calledFromRefresh then
        widget.visible = false
        if uiTask then
            -- uiTask also handles mspQueue in the background, so make sure to call it
            -- even when the widget isn't visible.
            uiTask()
        end
    end

    if backgroundTask then
        backgroundTask(widget)
    end
end

local redrawWidget = false
w.refresh = function(widget, event, touchState)
    if uiTask ~= nil then
        if redrawWidget or not widget.visible then
            -- If we immediately show the widget after lvgl.exitFullScreen(), the widget if briefly
            -- displayed in full screen mode. Using redrawWidget prevents that.
            showWidget(widget)
            redrawWidget = false
        end

        local noUi = not(lvgl.isFullScreen() or lvgl.isAppMode())
        local result = uiTask(event, touchState, noUi)
        if lvgl.isFullScreen() and result == 2 then
            lvgl.exitFullScreen()
            redrawWidget = true
        end
    end

    w.background(widget, true)
end

initializeRf2GlobalVar()
rf2.registerWidget = registerWidget

return w
