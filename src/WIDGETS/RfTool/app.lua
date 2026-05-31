---@diagnostic disable: undefined-global
-- RfTool widget
local zone, options, warning_duplicate = ...
warning_duplicate = warning_duplicate == true

local w = {
    zone = zone,
    options = options
}

local font_tools = assert(loadScript("/SCRIPTS/RF2/F/fontTools.lua"))()

local scriptsCompiled = assert(loadScript("/SCRIPTS/RF2/COMPILE/scripts_compiled.lua"))()
if scriptsCompiled then
    w.state = "loading"
else
    w.state = "compiling"
end

-- Longest possible state string
local STATE_MEASURE_TEXT = "Unknown Protocol"

local function getTelemetryText(options, measure)
    local source = options.sourceName
    if not source or source == "" then return "No source" end

    if measure then
        if #source < 4 then
            source = string.rep("W", 4 - #source) .. source
        end
        return source .. ": 0000" .. (options.Suffix or "")
    end

    -- Not available at boot time
    if not getValue then return source .. ":" end

    local value = getValue(source)
    if value == nil then return source .. ": -" end

    return source .. ": " .. tostring(value) .. (options.Suffix or "")
end

w.options.getText = function(options)
    if not options.sourceName then return "" end
    if not getValue then return " - " .. options.sourceName .. ": " end
    return " - " .. options.sourceName .. ": " .. tostring(getValue(options.sourceName)) .. options.Suffix
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
        -- bit32 is marked as deprecated, so switch to native bit operators
        local state = (armState & 1) ~= 0 and "armed" or "disarmed"
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

local function getStateText(widget)
    local state = widget.state
    return string.upper(string.sub(state, 1, 1)) .. string.sub(state, 2)
end

local function getDisplayedModelName(widget)
    if widget.options.HideModel == 1 then return nil end
    return getModelName()
end

local function showWidget(widget)
    local widget_w = widget.zone.w or widget.zone.x
    local widget_h = widget.zone.h or widget.zone.y
    local displayed_model_name = getDisplayedModelName(widget)
    local show_model = displayed_model_name ~= nil
    local show_state = widget.options.HideState ~= 1
    local show_telemetry = widget.options.HideTelemetry ~= 1
    local telemetry_measure = show_telemetry and getTelemetryText(widget.options, true) or nil
    local row1_text = nil
    local row1_measure = nil
    local row2_text = nil
    local row2_measure = nil
    local text_color = widget.options.TextColor or COLOR_THEME_PRIMARY1

    -- Determine what text to show in row 1 and row 2 based on the options
    if show_model then
        row1_text = displayed_model_name
        row1_measure = displayed_model_name
    end

    if show_state and show_telemetry then
        if row1_text then
            row2_text = function()
                return getStateText(widget) .. " - " .. getTelemetryText(widget.options)
            end
            row2_measure = STATE_MEASURE_TEXT .. " - " .. telemetry_measure
        else
            row1_text = function() return getStateText(widget) end
            row1_measure = STATE_MEASURE_TEXT
            row2_text = function() return getTelemetryText(widget.options) end
            row2_measure = telemetry_measure
        end
    elseif show_state then
        if row1_text then
            row2_text = function() return getStateText(widget) end
            row2_measure = STATE_MEASURE_TEXT
        else
            row1_text = function() return getStateText(widget) end
            row1_measure = STATE_MEASURE_TEXT
        end
    elseif show_telemetry then
        if row1_text then
            row2_text = function() return getTelemetryText(widget.options) end
            row2_measure = telemetry_measure
        else
            row1_text = function() return getTelemetryText(widget.options) end
            row1_measure = telemetry_measure
        end
    end

    if warning_duplicate then
        row1_text = "Warning"
        row1_measure = row1_text
        row2_text = "Use only one RfTool widget"
        row2_measure = row2_text
        text_color = COLOR_THEME_WARNING
    end

    local children = {}

    if row1_text then
        -- Build the lvgl object tree. If no rows are enabled we leave
        -- children empty, which clears the widget while still flowing through
        -- the same render tail.
        local pad_x = 2
        local pad_y = 2
        local row_gap = 1
        local content_w = math.max(1, widget_w - 2 * pad_x)
        local content_h = math.max(1, widget_h - 2 * pad_y)

        if row2_text then
            local top_h = math.max(1, math.floor((content_h - row_gap + 1) / 2))
            local top_font = font_tools.selectFont(top_h, content_w, row1_measure)
            local top_font_h = font_tools.measureFont(top_font)
            local detail_h = math.max(1, content_h - top_font_h - row_gap)
            local detail_font = font_tools.selectFont(detail_h, content_w, row2_measure, top_font)
            local detail_font_h = font_tools.measureFont(detail_font)
            local detail_y = pad_y + top_font_h + row_gap

            children[#children + 1] = {
                type = "label",
                x = pad_x,
                y = pad_y,
                w = content_w,
                h = top_font_h,
                text = row1_text,
                font = top_font,
                color = text_color,
                align = LEFT
            }
            children[#children + 1] = {
                type = "label",
                x = pad_x,
                y = detail_y,
                w = content_w,
                h = detail_font_h,
                text = row2_text,
                font = detail_font,
                color = text_color,
                align = LEFT
            }
        else
            local row_font = font_tools.selectFont(content_h, content_w, row1_measure)
            local row_font_h = font_tools.measureFont(row_font)
            local row_y = pad_y + math.max(0, math.floor((content_h - row_font_h) / 2))

            children[#children + 1] = {
                type = "label",
                x = pad_x,
                y = row_y,
                w = content_w,
                h = row_font_h,
                text = row1_text,
                font = row_font,
                color = text_color,
                align = LEFT
            }
        end
    end

    lvgl.clear()
    lvgl.build(children)

    widget.renderedModelName = displayed_model_name
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

    if warning_duplicate then
        showWidget(widget)
        return
    end

    if lvgl.isFullScreen() or lvgl.isAppMode() then
        rf2.restartUi()
    else
        showWidget(widget)
    end
end

w.background = function(widget, calledFromRefresh)
    if warning_duplicate then
        return
    end

    rf2.rfToolInstanceSeenAt = getTime()

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
    if warning_duplicate then
        if not widget.visible then
            showWidget(widget)
        end
        return
    end

    rf2.rfToolInstanceSeenAt = getTime()

    if uiTask ~= nil then
        if redrawWidget or not widget.visible or widget.renderedModelName ~= getDisplayedModelName(widget) then
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

if warning_duplicate then
    -- Duplicate instances stay warning-only so they do not reinitialize shared RF2 state.
    return w
end

initializeRf2GlobalVar()
rf2.rfToolInstanceSeenAt = getTime()
rf2.registerWidget = registerWidget
rf2.rfToolApiVersion = 1.00

return w
