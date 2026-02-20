-- Keep main.lua as lightweight as possible, since main.lua gets loaded for **all** widgets at boot time. Even if a widget isn't used by a particular model.
local name = "RF Tool"
local options = {
    { "Source",       SOURCE, "Vcel" },
    { "Text Color",   COLOR,  COLOR_THEME_PRIMARY1 },
    { "Suffix",       STRING, "" },
    { "Show Min/Max", BOOL,   1  }
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
    --print("RfTool: create called")
    local widget = loadScript("/WIDGETS/RfTool/app.lua")(zone, options)
    return widget
end

local function update(widget, options)
    --print("RfTool: update called")    
    if widget and widget.update then widget.update(widget, options) end
end

local function refresh(widget, event, touchState)
    --print("RfTool: refresh called")    
    if widget and widget.refresh then widget.refresh(widget, event, touchState) end
end

local function background(widget)
    --print("RfTool: background called")
    if widget and widget.background then widget.background(widget) end
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
