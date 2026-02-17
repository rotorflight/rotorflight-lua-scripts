local zone, options = ...

local w = {
    zone = zone,
    options = options
}

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

w.update = function(widget, options)
    widget.options = options
    showWidget(widget)
end

w.background = function(widget)
    if rf2 and rf2.widgetIsAlivePing then rf2.widgetIsAlivePing(widget) end
end

w.refresh = function(widget, event, touchState)
    widget.background(widget)

    local modelName = getModelName()

    if not rf2 then return end
    --print(modelName)

    if not widget.registered then
        widget.ping = function(w) rf2.print("Ping!!!") end
        rf2.registerWidget(widget)
        widget.registered = true
    end
end

return w
