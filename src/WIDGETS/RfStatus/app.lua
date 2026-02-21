-- RfStatus widget
local zone, options = ...
local flighStats = nil

local w = {
    zone = zone,
    options = options
}

local function getTotalFlights()
    if not flighStats then return "Flights: " end
    return "Flights: " .. tostring(flighStats.stats_total_flights.value)
end

local function getTotalTime()
    if not flighStats then return "Total flight time: " end
    return "Total flight time: " .. flighStats.stats_total_time_s.value
end

local function showWidget(widget)
    lvgl.clear();
    lvgl.build({
        { 
            type = "box", flexFlow = lvgl.FLOW_COLUMN, children = 
            {
                { type = "label", text = function() return getTotalFlights() end, w = widget.zone.x, align = CENTER },
                { type = "label", text = function() return getTotalTime() end, w = widget.zone.x, align = CENTER },
            }
        }
    });
end

w.update = function(widget, options)
    widget.options = options
    showWidget(widget)
end

local timeLastPing = nil
w.background = function(widget)
    if rf2 and rf2.widgetIsAlivePing and (timeLastPing == nil or (getTime() - timeLastPing) / 100 >= 1) then 
        rf2.widgetIsAlivePing(widget)
        timeLastPing = getTime()
    end
end

local function onReceivedFlightStats(callbackParam, stats)
    local totalTime = rf2.executeScript("F/formatSeconds")(stats.stats_total_time_s.value)
    stats.stats_total_time_s.value = totalTime
    flighStats = stats
end

w.onStateChanged = function(w, newState)
    -- Possible states: "connected", "disconnected", "armed", "disarmed"
    rf2.print("RfStatus - got new state: %s", newState)

    if newState == "connected" or newState == "disarmed" then
        rf2.useApi("mspFlightStats").read(onReceivedFlightStats)
    end
end

w.refresh = function(widget, event, touchState)
    widget.background(widget)

    if not rf2 then return end

    if not widget.registered then
        rf2.registerWidget(widget)
        widget.registered = true
    end
end

return w
