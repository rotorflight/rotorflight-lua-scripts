-- Keep main.lua as lightweight as possible, since main.lua gets loaded for **all** widgets at boot time.
-- Even if a widget isn't used by a particular model.
local name = "RF Stats"

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
    local widget = loadScript("/WIDGETS/RfStats/app.lua")(zone, options)
    return widget
end

local function update(widget, options)
    if widget.update then widget.update(widget, options) end
end

local function refresh(widget, event, touchState)
    if widget.refresh then widget.refresh(widget, event, touchState) end
end

local function background(widget)
    if widget.background then widget.background(widget) end
end

return {
    useLvgl = true,
    name = name,
    options = { },
    create = create,
    update = update,
    refresh = refresh,
    background = background,
}
