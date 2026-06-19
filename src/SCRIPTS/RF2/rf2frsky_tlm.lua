-- Mirror Rotorflight FrSky telemetry IDs into Lua telemetry sensors so
-- S.Port, F.Port, and FBUS users get the same short names that CRSF/ELRS
-- users see. This does not rename native EdgeTX/OpenTX sensors; it creates
-- parallel aliases with stable, friendly names.

local aliases = {
    { sourceName = "5100", aliasId = 0xEF00, aliasName = "BEAT", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5110", aliasId = 0xEF10, aliasName = "AdjF", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5111", aliasId = 0xEF11, aliasName = "AdjV", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5120", aliasId = 0xEF20, aliasName = "MDL#", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5121", aliasId = 0xEF21, aliasName = "Mode", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5122", aliasId = 0xEF22, aliasName = "ARM",  unit = UNIT_RAW, prec = 0 },
    { sourceName = "5123", aliasId = 0xEF23, aliasName = "ARMD", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5124", aliasId = 0xEF24, aliasName = "Resc", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5125", aliasId = 0xEF25, aliasName = "Gov",  unit = UNIT_RAW, prec = 0 },
    { sourceName = "5128", aliasId = 0xEF28, aliasName = "EscF", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5129", aliasId = 0xEF29, aliasName = "Esc#", unit = UNIT_RAW, prec = 0 },
    { sourceName = "512B", aliasId = 0xEF2B, aliasName = "Es2#", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5130", aliasId = 0xEF30, aliasName = "PID#", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5131", aliasId = 0xEF31, aliasName = "RTE#", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5132", aliasId = 0xEF32, aliasName = "LED#", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5133", aliasId = 0xEF33, aliasName = "BAT#", unit = UNIT_RAW, prec = 0 },
    { sourceName = "51A0", aliasId = 0xEFA0, aliasName = "CPtc", unit = UNIT_DEGREE, prec = 1 },
    { sourceName = "51A1", aliasId = 0xEFA1, aliasName = "CRol", unit = UNIT_DEGREE, prec = 1 },
    { sourceName = "51A2", aliasId = 0xEFA2, aliasName = "CYaw", unit = UNIT_DEGREE, prec = 1 },
    { sourceName = "51A3", aliasId = 0xEFA3, aliasName = "CCol", unit = UNIT_DEGREE, prec = 1 },
    { sourceName = "51A4", aliasId = 0xEFA4, aliasName = "Thr",  unit = UNIT_PERCENT, prec = 1 },
    { sourceName = "51D0", aliasId = 0xEFD0, aliasName = "CPU%", unit = UNIT_PERCENT, prec = 0 },
    { sourceName = "51D1", aliasId = 0xEFD1, aliasName = "SYS%", unit = UNIT_PERCENT, prec = 0 },
    { sourceName = "51D2", aliasId = 0xEFD2, aliasName = "RT%",  unit = UNIT_PERCENT, prec = 0 },
    { sourceName = "5210", aliasId = 0xEE10, aliasName = "Hdg",  unit = UNIT_DEGREE, prec = 1 },
    { sourceName = "5250", aliasId = 0xEE50, aliasName = "Capa", unit = UNIT_MAH, prec = 0 },
    { sourceName = "5258", aliasId = 0xEE58, aliasName = "EscC", unit = UNIT_MAH, prec = 0 },
    { sourceName = "525A", aliasId = 0xEE5A, aliasName = "Es2C", unit = UNIT_MAH, prec = 0 },
    { sourceName = "5260", aliasId = 0xEE60, aliasName = "Cel#", unit = UNIT_RAW, prec = 0 },
    { sourceName = "5268", aliasId = 0xEE68, aliasName = "EscP", unit = UNIT_PERCENT, prec = 0 },
    { sourceName = "5269", aliasId = 0xEE69, aliasName = "Esc%", unit = UNIT_PERCENT, prec = 0 },
    { sourceName = "52F0", aliasId = 0xEEF0, aliasName = "DBG0", unit = UNIT_RAW, prec = 0 },
    { sourceName = "52F1", aliasId = 0xEEF1, aliasName = "DBG1", unit = UNIT_RAW, prec = 0 },
    { sourceName = "52F2", aliasId = 0xEEF2, aliasName = "DBG2", unit = UNIT_RAW, prec = 0 },
    { sourceName = "52F3", aliasId = 0xEEF3, aliasName = "DBG3", unit = UNIT_RAW, prec = 0 },
    { sourceName = "52F4", aliasId = 0xEEF4, aliasName = "DBG4", unit = UNIT_RAW, prec = 0 },
    { sourceName = "52F5", aliasId = 0xEEF5, aliasName = "DBG5", unit = UNIT_RAW, prec = 0 },
    { sourceName = "52F6", aliasId = 0xEEF6, aliasName = "DBG6", unit = UNIT_RAW, prec = 0 },
    { sourceName = "52F8", aliasId = 0xEEF8, aliasName = "DBG7", unit = UNIT_RAW, prec = 0 },
}

local lookupInterval = 2
local nextLookup = 0

local function resolveSourceId(alias)
    if getFieldInfo == nil then
        return
    end

    local field = getFieldInfo(alias.sourceName)
    if field then
        alias.sourceId = field.id
    else
        alias.sourceId = nil
    end
end

local function readValue(alias)
    if getFieldInfo ~= nil then
        if alias.sourceId == nil then
            return nil
        end
        return getValue(alias.sourceId)
    end

    return getValue(alias.sourceName)
end

local function run()
    if getFieldInfo ~= nil and rf2.clock() >= nextLookup then
        nextLookup = rf2.clock() + lookupInterval
        for i = 1, #aliases do
            resolveSourceId(aliases[i])
        end
    end

    for i = 1, #aliases do
        local alias = aliases[i]
        local value = readValue(alias)
        if value ~= nil then
            setTelemetryValue(alias.aliasId, 0, 0, value, alias.unit, alias.prec, alias.aliasName)
        end
    end
end

return {
    run = run
}
