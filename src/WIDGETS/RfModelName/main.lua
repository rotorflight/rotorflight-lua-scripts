local name = "RF Model Name"
local versionString = "v0.1.0"

if lvgl == nil then
    return {
        name = name,
        options = { },
        create = function() end,
        refresh = function()
            lcd.drawText(10, 10, "LVGL support required", COLOR_THEME_WARNING)
        end,
    }
end

local function create(zone, options)
    --print("RfModelName: create called")
    local widget = loadScript("/WIDGETS/RfModelName/app.lua")(zone, options)
    return widget
end

local function update(widget, options)
    --print("RfModelName: update called")    
    if widget and widget.update then widget.update(widget, options) end
end

local function refresh(widget, event, touchState)
    --print("RfModelName: refresh called")    
    if widget and widget.refresh then widget.refresh(widget, event, touchState) end
end

local function background(widget)
    --print("RfModelName: background called")
    if widget and widget.background then widget.background(widget) end
end

local function translate(widget)
    --print("RfModelName: translate called")
    if widget and widget.translate then widget.translate(widget) end
end

-- See https://github.com/EdgeTX/edgetx/blob/main/radio/src/lua/widgets.cpp
return { useLvgl = true, name = name, options = {}, create = create, update = update, refresh = refresh, background = background, translate = translate }
