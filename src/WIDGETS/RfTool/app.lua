-- RfTool widget
local zone, options = ...

local w = {
    zone = zone,
    options = options
}

local scriptsCompiled = assert(loadScript("/SCRIPTS/RF2/COMPILE/scripts_compiled.lua"))()
local initialWidgetState = scriptsCompiled and "loading" or "compiling"

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

-- RF2 fullscreen pages call options:getText() on the active widget to append
-- widget-specific telemetry text to the subtitle
w.options.getText = function(options)
    if not options.sourceName then return "" end
    if not getValue then return " - " .. options.sourceName .. ": " end
    return " - " .. options.sourceName .. ": " .. tostring(getValue(options.sourceName)) .. options.Suffix
end

local compileTask = nil

local timeCreated = getTime()

-- RF2 is shared across all RfTool instances on a page, so RfTool keeps one
-- shared store under rf2 for cross-instance state and subscribers.
local function getRfToolShared()
    rf2.rfToolShared = rf2.rfToolShared or {}
    rf2.rfToolShared.registeredWidgets = rf2.rfToolShared.registeredWidgets or {}
    return rf2.rfToolShared
end

local function registerWidget(widget)
    -- Subscriber list for widgets that want RfTool onStateChanged callbacks
    local registeredWidgets = getRfToolShared().registeredWidgets
    for i = 1, #registeredWidgets do
        if registeredWidgets[i] == widget then
            return
        end
    end

    registeredWidgets[#registeredWidgets + 1] = widget
end

local function publishStateChangedEvent(newState)
    -- Only explicit subscribers are notified here. Other RfTool instances see
    -- the shared widgetState change in their own refresh/background cycle.
    for k, v in pairs(getRfToolShared().registeredWidgets) do
        if v.onStateChanged then
            rf2.call(v.onStateChanged, v, newState)
        end
    end
end

local previousArmState = 0

-- Multiple RfTool instances can exist on one EdgeTX page, but the RF2 runtime is shared.
-- widgetState in the shared store is the single source of truth. Each widget only keeps
-- local redraw bookkeeping such as needsRedraw and renderedState.
local function setArmState(widget)
    if not getValue then return end -- Not available at boot time
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
    -- This function can also be called from the background task
    -- Multiple RfTool instances can reach the same transition. Only the first
    -- one that changes the shared state should notify subscribers
    if getRfToolShared().widgetState == state then return end

    getRfToolShared().widgetState = state
    -- Any logical state change can affect the rendered widget text on the
    -- normal screen. Mark that surface dirty and let refresh() rebuild it
    -- when widget mode is active.
    self.needsRedraw = true
    if state == "disconnected" then
        rf2.modelName = nil
        previousArmState = 0
    end
    publishStateChangedEvent(state)
end

local function initializeRf2GlobalVar()
    -- rf2 is the *only* global variable that is used by the Rotorflight scripts.
    --print("RF2: Before rf2.lua: ", collectgarbage("count") * 1024)
    assert(loadScript("/SCRIPTS/RF2/rf2.lua"))()
    --rf2.showMemoryUsage("rf2 loaded")
end

local function loadScripts(widget)
    -- Load required scripts
    rf2.radio = rf2.radio or rf2.executeScript("radios")
    rf2.mspQueue = rf2.mspQueue or rf2.executeScript("MSP/mspQueue")
    rf2.mspHelper = rf2.mspHelper or rf2.executeScript("MSP/mspHelper")

    -- uiTask/backgroundTask are RF2 singletons. Sharing them on rf2 avoids
    -- each widget instance creating its own runner with conflicting
    -- fullscreen state.
    rf2.uiTask = rf2.uiTask or rf2.executeScript("ui_lvgl_runner")
    rf2.backgroundTask = rf2.backgroundTask or rf2.executeScript("background")
    -- rf2.widget is the active widget context consumed by RF2 helpers that
    -- need widget-specific data such as subtitle text. It is not a broadcast
    -- to all widgets.
    rf2.widget = widget
end

local function getModelName()
    local modelName = rf2 and rf2.modelName or nil

    if not modelName then
         modelName = model.getInfo().name
    end

    return modelName or "Unknown"
end

local function getStateText()
    local state = getRfToolShared().widgetState
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
                return getStateText() .. " - " .. getTelemetryText(widget.options)
            end
            row2_measure = STATE_MEASURE_TEXT .. " - " .. telemetry_measure
        else
            row1_text = function() return getStateText() end
            row1_measure = STATE_MEASURE_TEXT
            row2_text = function() return getTelemetryText(widget.options) end
            row2_measure = telemetry_measure
        end
    elseif show_state then
        if row1_text then
            row2_text = function() return getStateText() end
            row2_measure = STATE_MEASURE_TEXT
        else
            row1_text = function() return getStateText() end
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

    widget.renderedState = getRfToolShared().widgetState
    widget.renderedModelName = displayed_model_name
    widget.visible = true
end

local function shouldRedrawWidget(widget)
    local displayed_model_name = getDisplayedModelName(widget)

    return widget.needsRedraw
        or not widget.visible
        or widget.renderedState ~= getRfToolShared().widgetState
        or widget.renderedModelName ~= displayed_model_name
end

w.update = function(widget, options)
    widget.options = options
    if options and options.Source and getFieldInfo then
        local fieldInfo = getFieldInfo(options.Source)
        if fieldInfo then
            widget.options.sourceName = fieldInfo.name
        end
    end
    widget.needsRedraw = true

    if lvgl.isFullScreen() or lvgl.isAppMode() then
        if not widget.pendingRf2UiRestart then
            -- Clear the stale normal widget before the fullscreen handoff,
            -- otherwise the previous widget tree can flash briefly before RF2
            -- rebuilds its UI.
            lvgl.clear()
            lvgl.build({})
            widget.visible = false
        end
        -- update() is the first point where the fullscreen transition is
        -- visible, so it clears the stale widget tree early and stores a
        -- one-shot handoff token. refresh() consumes that token and performs
        -- the actual RF2 restart in one place.
        widget.pendingRf2UiRestart = true
    else
        widget.pendingRf2UiRestart = false
    end
end

w.background = function(widget, calledFromRefresh)
    local state = getRfToolShared().widgetState

    if state == "compiling" then
        compileTask = compileTask or assert(loadScript("/SCRIPTS/RF2/COMPILE/compile.lua"))()
        if compileTask() == 1 then
            compileTask = nil
            widget:setState("loading")
        end
        return
    elseif state == "loading"
        and (getTime() - timeCreated) / 100 > 1 -- bootgrace timeout
    then
        if not rf2.widget then
            -- First initialized RfTool instance provides the initial widget context for RF2.
            rf2.widget = widget
        end
        widget:setState("unknown protocol")
    elseif state == "unknown protocol" then
        local protocol = rf2.executeScript("F/getProtocol")()
        if protocol then
            loadScripts(widget)
            widget:setState("ready")
        end
    end

    setArmState(widget)

    if not calledFromRefresh then
        widget.visible = false
        if rf2.uiTask then
            -- uiTask also handles mspQueue in the background, so make sure to
            -- call it even when the widget isn't visible.
            rf2.uiTask(nil, nil, true)
        end
    end

    if rf2.backgroundTask then
        rf2.backgroundTask(widget)
    end
end

w.refresh = function(widget, event, touchState)
    local isWidgetMode = not(lvgl.isFullScreen() or lvgl.isAppMode())

    if not isWidgetMode and rf2 then
        -- Fullscreen RF2 pages should use the widget that actually triggered
        -- the handoff.
        rf2.widget = widget
    end

    if not isWidgetMode and widget.pendingRf2UiRestart then
        widget.pendingRf2UiRestart = false
        rf2.restartUi()
    end

    -- needsRedraw is only for the normal widget surface. Fullscreen/app mode
    -- is driven by RF2.
    if isWidgetMode and shouldRedrawWidget(widget) then
        showWidget(widget)
        widget.needsRedraw = false
    end

    if rf2.uiTask ~= nil then
        local result = rf2.uiTask(event, touchState, isWidgetMode)
        if lvgl.isFullScreen() and result == 2 then
            lvgl.exitFullScreen()
            widget.needsRedraw = true
        end
    end

    w.background(widget, true)
end

initializeRf2GlobalVar()
getRfToolShared().widgetState = getRfToolShared().widgetState or initialWidgetState
rf2.registerWidget = registerWidget
rf2.rfToolApiVersion = 1.00

return w
