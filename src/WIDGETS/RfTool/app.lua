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


-- Longest possible state string
local STATE_MEASURE_TEXT = "Unknown Protocol"
local FONT_SIZES = { XXLSIZE, DBLSIZE, MIDSIZE, STDSIZE, SMLSIZE, TINSIZE }
-- Not available on older EdgeTX versions
local xlsize = _G["XLSIZE"]
if type(xlsize) == "number" then
    table.insert(FONT_SIZES, 2, xlsize)
end

local function measureFont(font_const, max_w, test_string)
    local test_text = test_string or "X"
    local text_w, text_h = lcd.sizeText(test_text, font_const)

    if max_w and text_w > max_w then return -1 end

    return text_h
end

local function selectFittingFont(available_w, available_h, test_string, start_index)
    start_index = start_index or 1
    for i = start_index, #FONT_SIZES do
        local font_const = FONT_SIZES[i]
        if font_const then
            local font_h = measureFont(font_const, available_w, test_string)
            -- Allow a bit of extra height
            if font_h > 0 and font_h <= available_h + 2 then
                return font_const, i
            end
        end
    end

    -- Fallback to the smallest font if nothing fits
    return FONT_SIZES[#FONT_SIZES], #FONT_SIZES
end

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
        local text_color = widget.options.TextColor or COLOR_THEME_PRIMARY1

        if row2_text then
            local top_h = math.max(1, math.floor((content_h - row_gap + 1) / 2))
            local top_font, top_index = selectFittingFont(content_w, top_h, row1_measure)
            local top_font_h = measureFont(top_font)
            local detail_h = math.max(1, content_h - top_font_h - row_gap)
            -- The second font should be smaller than the first one, so start
            -- looking from the next smaller font than the one used for row 1
            local detail_font = selectFittingFont(content_w, detail_h, row2_measure, math.min(top_index + 1, #FONT_SIZES))
            local detail_font_h = measureFont(detail_font)
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
            local row_font = selectFittingFont(content_w, content_h, row1_measure)
            local row_font_h = measureFont(row_font)
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

initializeRf2GlobalVar()
rf2.registerWidget = registerWidget
rf2.rfToolApiVersion = 1.00

return w
