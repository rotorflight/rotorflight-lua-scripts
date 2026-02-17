local name = "Model Name"
local versionString = "v0.1.0"
-- local mspName = nil

if lvgl == nil then
    return {
        name = name,
        options = { },
        create = (function() end),
        refresh = function()
            lcd.drawText(10, 10, "LVGL support required", COLOR_THEME_WARNING)
        end,
    }
end

local function getModelName()
    local modelName = rf2 and rf2.model and rf2.model.name or nil

    -- if not mspName and rf2 then
    --     rf2.useApi("mspName").getModelName(function(page, name) mspName = name end, self)
    -- end
    -- local modelName = mspName

    if not modelName then
         modelName = model.getInfo().name
    end
    return modelName or "Unknown"
end

local function create(zone, options)
    print("modelname: create called")    

    local widget = { 
        zone = zone,
        options = options,
    }

    return widget
end

local function showWidget(widget)
    lvgl.clear();
    lvgl.build({
        { 
            type = "box", flexFlow = lvgl.FLOW_COLUMN, children = 
            {
                { type = "label", text = function() return getModelName() end, w = widget.zone.x, align = CENTER },
            }
        }
    });
end

-- Update function (called when options change)
local function update(widget, options)
    --print("modelname: update called")    
    widget.options = options
    showWidget(widget)
end

local function refresh(widget, event, touchState)
    --print("modelname: refresh called")    
    local modelName = getModelName()
    --print(modelName)

    if not rf2 then return end
    if not widget.registered then
        widget.ping = function(w) rf2.print("Ping!!!") end
        rf2.registerWidget(widget)
        widget.registered = true
    end

    if rf2 and rf2.widgetIsAlivePing then rf2.widgetIsAlivePing(widget) end
end

local function background(widget)
    --print("modelname: background called")
    if rf2 and rf2.widgetIsAlivePing then rf2.widgetIsAlivePing(widget) end
end

local function translate(widget)
    print("modelname: translate called")
end

-- See https://github.com/EdgeTX/edgetx/blob/main/radio/src/lua/widgets.cpp
return { useLvgl = true, name = name, options = {}, create = create, update = update, refresh = refresh, background = background, translate = translate }
