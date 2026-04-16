local mspFlightStats = rf2.useApi("mspFlightStats")
local flighStats = mspFlightStats.getDefaults()

local doReadStats = true
local lastArmedState = false
local lastTelemetryUpdate = 0
local lastReadAttempt = 0

local function checkArmedChanged()
    local arm = getValue("ARM")
    local currentArmedState = (arm == 1 or arm == 3)
    if lastArmedState == true and currentArmedState == false then
        doReadStats = true
    end
    lastArmedState = currentArmedState
end

local function readStats()
    checkArmedChanged()
    
    local now = rf2.clock()

    if (doReadStats or flighStats.stats_total_flights.value == nil) and (now - lastReadAttempt > 2) then
        if rf2.mspQueue:isProcessed() then
            mspFlightStats.read(nil, nil, flighStats)
            lastReadAttempt = now
            doReadStats = false
        end
    end

    if not rf2.mspQueue:isProcessed() then
        rf2.mspQueue:processQueue()
    end

    if flighStats.statsEnabled.value and flighStats.statsEnabled.value == 1 then
        if now - lastTelemetryUpdate >= 1 then
            lastTelemetryUpdate = now
            if flighStats.stats_total_flights.value then
                setTelemetryValue(0x2001, 0, 0, flighStats.stats_total_flights.value, UNIT_RAW, 0, "FlyC")
                setTelemetryValue(0x2002, 0, 0, flighStats.stats_total_time_s.value, UNIT_RAW, 0, "FlyT")
                setTelemetryValue(0x2003, 0, 0, flighStats.stats_total_dist_m.value, UNIT_RAW, 0, "FlyD")
            end
        end
    end
    
end

return { readStats = readStats }