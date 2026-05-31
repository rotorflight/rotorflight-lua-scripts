---@diagnostic disable: undefined-global
-- Keep main.lua as lightweight as possible, since main.lua gets loaded for **all** widgets at boot time.
-- Even if a widget isn't used by a particular model.
local name = "RF Tool"

--- this is for VSCode extnension 'EdgeTX Dev Kit'
---@type WidgetScript

---@type WidgetOptions
local options = {
    { "Source", SOURCE, "Vcel" },
    { "Suffix", STRING, "" },
    { "HideModel", BOOL, 0},
    { "HideState", BOOL, 0 },
    { "HideTelemetry", BOOL, 0 },
    { "TextColor", COLOR, COLOR_THEME_PRIMARY1 }
}
-- newly added options in EdgeTX don't get their set default value,
-- so the color is black by default when "updating" the widget.

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
    return loadScript("/WIDGETS/RfTool/app.lua")(zone, options, rf2 ~= nil)
end

local function update(widget, options)
    if widget.update then
        rf2.call(widget.update, widget, options)
    end
end

local function refresh(widget, event, touchState)
    if widget.refresh then
        rf2.call(widget.refresh, widget, event, touchState)
    end
end

local function background(widget)
    if widget.background then
        rf2.call(widget.background, widget)
    end
end

-- local function translate(widget)
--     --print("RfTool: translate called")
--     if widget and widget.translate then widget.translate(widget) end
-- end

return {
    useLvgl = true,
    name = name,
    options = options,
    create = create,
    update = update,
    refresh = refresh,
    background = background,
    --translate = translate
}
