-- Keep main.lua as lightweight as possible, since main.lua gets loaded for **all** widgets at boot time.
-- Even if a widget isn't used by a particular model.
local name = "RF Tool"

local options = {
    { "Source", SOURCE, "Vcel" },
    { "Suffix", STRING, "" }
}

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
    local widget = loadScript("/WIDGETS/RfTool/app.lua")(zone, options)
    return widget
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
