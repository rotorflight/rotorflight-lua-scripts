local flightMode = {
    [0] = "Fixed Wing",
    "Ext Gov",
    "Governor",
    "Gov Store",
}

local lipoCellCount = {
    [0] = "Auto",
    "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "11S", "12S", "13S", "14S",
}

local lipoCellCount2To4 = {
    [0] = "Auto",
    "2S", "3S", "4S",
}

local lipoCellCount3To8 = {
    [0] = "Auto",
    "3S", "4S", "5S", "6S", "7S", "8S",
}

local lipoCellCountEven6To14 = {
    [0] = "Auto",
    "6S", "8S", "10S", "12S", "14S",
}

local cutoffType = {
    [0] = "Soft",
    "Hard"
}

local cutoffVoltage = {
    [0] = "Disabled",
    "2.8V", "2.9V", "3.0V", "3.1V", "3.2V", "3.3V", "3.4V", "3.5V", "3.6V", "3.7V", "3.8V",
}

local cutoffVoltage25To38 = {
    [0] = "Disabled",
    "2.5V", "2.6V", "2.7V", "2.8V", "2.9V", "3.0V", "3.1V", "3.2V", "3.3V", "3.4V", "3.5V", "3.6V", "3.7V", "3.8V",
}

local restartTime = {
    [0] = "1 s",
    "1.5 s",
    "2 s",
    "2.5 s",
    "3 s",
}

local responseTime = {
    [0] = "1",
    "2",
    "3",
    "4",
    "5",
}

local rotation = {
    [0] = "CW",
    "CCW",
}

local brakeType = {
    [0] = "Disabled",
    "Normal",
    "Proportional",
    "Reverse"
}

local brakeTypeNoProportional = {
    [0] = "Disabled",
    "Normal",
    "Reverse"
}

local brakeTypeBasic = {
    [0] = "Disabled",
    "Normal",
}

local enabledDisabled = {
    [0] = "Enabled",
    "Disabled",
}

local startupPower = {
    [0] = "Level 1",
    "Level 2",
    "Level 3",
    "Level 4",
    "Level 5",
    "Level 6",
    "Level 7",
}

local becVoltage60To84 = {
    [0] = "6.0V",
    "7.4V",
    "8.4V",
}

local ITEM_COUNT = 16

local VALUE_FIELDS = {
    "flight_mode",
    "lipo_cell_count",
    "cutoff_type",
    "cutoff_voltage",
    "bec_voltage",
    "startup_time",
    "response_time",
    "gov_p_gain",
    "gov_i_gain",
    "auto_restart",
    "restart_time",
    "brake_type",
    "brake_force",
    "timing",
    "rotation",
    "active_freewheel",
    "startup_power",
}

local DEFAULT_LAYOUT = {
    flight_mode = 1,
    lipo_cell_count = 2,
    cutoff_type = 3,
    cutoff_voltage = 4,
    bec_voltage = 5,
    startup_time = 6,
    gov_p_gain = 7,
    gov_i_gain = 8,
    auto_restart = 9,
    restart_time = 10,
    brake_type = 11,
    brake_force = 12,
    timing = 13,
    rotation = 14,
    active_freewheel = 15,
    startup_power = 16,
}

local HW1132_LAYOUT = {
    lipo_cell_count = 1,
    cutoff_type = 2,
    cutoff_voltage = 3,
    bec_voltage = 4,
    response_time = 5,
    timing = 6,
    rotation = 7,
    active_freewheel = 8,
    startup_power = 9,
}

local HW1128_LAYOUT = {
    lipo_cell_count = 1,
    cutoff_type = 2,
    cutoff_voltage = 3,
    brake_type = 5,
    brake_force = 6,
    timing = 7,
    rotation = 8,
    active_freewheel = 9,
    startup_power = 10,
}

local OPTO_LAYOUT = {
    flight_mode = 1,
    lipo_cell_count = 2,
    cutoff_type = 3,
    cutoff_voltage = 4,
    startup_time = 5,
    gov_p_gain = 6,
    gov_i_gain = 7,
    auto_restart = 8,
    restart_time = 9,
    brake_type = 10,
    brake_force = 11,
    timing = 12,
    rotation = 13,
    active_freewheel = 14,
    startup_power = 15,
}

local DEFAULT_BEC = { min = 50, max = 84, scale = 10 }

local PROFILES = {
    default = {
        layout = DEFAULT_LAYOUT,
        bec = DEFAULT_BEC,
        brake = brakeType,
        lipo = lipoCellCount,
        cutoffVoltage = cutoffVoltage,
    },
    ["HW1104_V100456NB"] = { layout = DEFAULT_LAYOUT, bec = { min = 50, max = 120, scale = 10 }, brake = brakeTypeBasic, lipo = lipoCellCountEven6To14, cutoffVoltage = cutoffVoltage },
    ["HW1106_V100456NB"] = { layout = DEFAULT_LAYOUT, bec = { min = 54, max = 84, scale = 10 }, brake = brakeType, lipo = lipoCellCount3To8, cutoffVoltage = cutoffVoltage },
    ["HW1106_V200456NB"] = { layout = DEFAULT_LAYOUT, bec = { min = 50, max = 120, scale = 10 }, brake = brakeTypeNoProportional, lipo = lipoCellCount, cutoffVoltage = cutoffVoltage },
    ["HW1106_V300456NB"] = { layout = DEFAULT_LAYOUT, bec = { min = 50, max = 120, scale = 10 }, brake = brakeTypeNoProportional, lipo = lipoCellCount, cutoffVoltage = cutoffVoltage },
    ["HW1121_V100456NB"] = { layout = DEFAULT_LAYOUT, bec = { min = 50, max = 120, scale = 10 }, brake = brakeTypeNoProportional, lipo = lipoCellCount, cutoffVoltage = cutoffVoltage },
    ["HW1121_V00456NB"] = { layout = DEFAULT_LAYOUT, bec = { min = 50, max = 120, scale = 10 }, brake = brakeTypeNoProportional, lipo = lipoCellCount, cutoffVoltage = cutoffVoltage },
    ["HW1132_V100456NB"] = { layout = HW1132_LAYOUT, bec = { table = becVoltage60To84 }, brake = brakeTypeNoProportional, lipo = lipoCellCount, cutoffVoltage = cutoffVoltage, response = responseTime },
    ["HW198_V1.00456NB"] = { layout = DEFAULT_LAYOUT, bec = { min = 50, max = 120, scale = 10 }, brake = brakeTypeBasic, lipo = lipoCellCountEven6To14, cutoffVoltage = cutoffVoltage },
    HW1128 = { layout = HW1128_LAYOUT, bec = nil, brake = brakeTypeNoProportional, lipo = lipoCellCount2To4, cutoffVoltage = cutoffVoltage25To38 },
    OPTO = { layout = OPTO_LAYOUT, bec = nil, brake = brakeTypeBasic, lipo = lipoCellCountEven6To14, cutoffVoltage = cutoffVoltage },
}

local function trim(value)
    if not value then return "" end
    local text = string.gsub(tostring(value), "%z.*", "")
    return string.match(text, "^%s*(.-)%s*$")
end

local function startsWith(value, prefix)
    return string.sub(value or "", 1, #prefix) == prefix
end

local function selectProfile(hardwareVersion, escType, firmwareVersion)
    local hardware = trim(hardwareVersion)
    local esc = trim(escType)
    local firmware = trim(firmwareVersion)

    if string.find(esc, "OPTO", 1, true) or string.find(firmware, "OPTO", 1, true) then
        return PROFILES.OPTO
    end

    if PROFILES[hardware] then
        return PROFILES[hardware]
    end

    if startsWith(hardware, "HW1132_") then
        return PROFILES["HW1132_V100456NB"]
    elseif startsWith(hardware, "HW1128_") then
        return PROFILES.HW1128
    elseif startsWith(hardware, "HW1121_") then
        return PROFILES["HW1121_V100456NB"]
    end

    return PROFILES.default
end

local function applyTable(field, tableDef)
    field.table = tableDef
    field.min = 0
    field.max = #tableDef
end

local function applyProfile(data, profile)
    applyTable(data.flight_mode, flightMode)
    applyTable(data.lipo_cell_count, profile.lipo or lipoCellCount)
    applyTable(data.cutoff_type, cutoffType)
    applyTable(data.cutoff_voltage, profile.cutoffVoltage or cutoffVoltage)
    applyTable(data.restart_time, restartTime)
    applyTable(data.response_time, profile.response or responseTime)
    applyTable(data.brake_type, profile.brake or brakeType)
    applyTable(data.rotation, rotation)
    applyTable(data.active_freewheel, enabledDisabled)
    applyTable(data.startup_power, startupPower)

    if profile.bec and profile.bec.table then
        applyTable(data.bec_voltage, profile.bec.table)
        data.bec_voltage.scale = nil
        data.bec_voltage.unit = nil
    elseif profile.bec then
        data.bec_voltage.table = nil
        data.bec_voltage.min = profile.bec.min
        data.bec_voltage.max = profile.bec.max
        data.bec_voltage.scale = profile.bec.scale
        data.bec_voltage.unit = rf2.units.volt
    else
        data.bec_voltage.table = nil
        data.bec_voltage.value = nil
        data.bec_voltage.scale = nil
        data.bec_voltage.unit = nil
    end

    data._profile = profile
    data._layout = profile.layout
    data._supported = {}
    for _, fieldName in ipairs(VALUE_FIELDS) do
        data._supported[fieldName] = profile.layout[fieldName] ~= nil
    end
end

local function setFieldValue(data, profile, fieldName, rawValue)
    local field = data[fieldName]
    if rawValue == nil then
        field.value = nil
    elseif fieldName == "bec_voltage" and profile.bec and not profile.bec.table then
        field.value = rawValue + profile.bec.min
    elseif fieldName == "startup_time" then
        field.value = rawValue + 4
    else
        field.value = rawValue
    end
end

local function getFieldRawValue(data, profile, fieldName)
    local field = data[fieldName]
    local value = field and field.value
    if value == nil then return nil end
    if fieldName == "bec_voltage" and profile.bec and not profile.bec.table then
        return value - profile.bec.min
    elseif fieldName == "startup_time" then
        return value - 4
    end
    return value
end

local function getDefaults()
    return {
        esc_signature = {},
        command = {},
        firmware_version = {},
        hardware_version = {},
        esc_type2 = {},
        esc_type = {},
        flight_mode = { min = 0, max = #flightMode, table = flightMode },
        lipo_cell_count = { min = 0, max = #lipoCellCount, table = lipoCellCount },
        cutoff_type = { min = 0, max = #cutoffType, table = cutoffType },
        cutoff_voltage = { min = 0, max = #cutoffVoltage, table = cutoffVoltage },
        bec_voltage = { min = 50, max = 84, scale = 10, unit = rf2.units.volt },
        startup_time = { min = 4, max = 25, unit = rf2.units.seconds },
        response_time = { min = 0, max = #responseTime, table = responseTime },
        gov_p_gain = { min = 0, max = 9 },
        gov_i_gain = { min = 0, max = 9 },
        auto_restart = { min = 0, max = 90, unit = rf2.units.seconds },
        restart_time = { min = 0, max = #restartTime, table = restartTime },
        brake_type = { min = 0, max = #brakeType, table = brakeType },
        brake_force = { min = 0, max = 100, unit = rf2.units.percentage },
        timing = { min = 0, max = 30, unit = rf2.units.degrees },
        rotation = { min = 0, max = #rotation, table = rotation },
        active_freewheel = { min = 0, max = #enabledDisabled, table = enabledDisabled },
        startup_power = { min = 0, max = #startupPower, table = startupPower },
        _itemBytes = {},
        _layout = DEFAULT_LAYOUT,
        _supported = {},
    }
end

local function getEscParameters(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 217, -- MSP_ESC_PARAMETERS
        ignoreErrors = true,
        processReply = function(self, buf)
            data.esc_signature.value = rf2.mspHelper.readU8(buf)
            if data.esc_signature.value ~= 253 then
                return
            end
            data.command.value = rf2.mspHelper.readU8(buf)
            data.firmware_version.value = rf2.mspHelper.readText(buf, 16)
            data.hardware_version.value = rf2.mspHelper.readText(buf, 16)
            data.esc_type2.value = rf2.mspHelper.readText(buf, 16)
            data.esc_type.value = rf2.mspHelper.readText(buf, 15)

            local itemBytes = {}
            for i = 1, ITEM_COUNT do
                itemBytes[i] = rf2.mspHelper.readU8(buf)
            end

            local profile = selectProfile(data.hardware_version.value, (data.esc_type2.value or "") .. (data.esc_type.value or ""), data.firmware_version.value)
            applyProfile(data, profile)
            data._itemBytes = itemBytes

            for _, fieldName in ipairs(VALUE_FIELDS) do
                setFieldValue(data, profile, fieldName, itemBytes[profile.layout[fieldName]])
            end

            callback(callbackParam, data)
        end,
        simulatorResponse = { 253, 0, 32, 32, 32, 80, 76, 45, 48, 52, 46, 49, 46, 48, 50, 32, 32, 32, 72, 87, 49, 49, 48, 54, 95, 86, 49, 48, 48, 52, 53, 54, 78, 66, 80, 108, 97, 116, 105, 110, 117, 109, 95, 86, 53, 32, 32, 32, 32, 32, 80, 108, 97, 116, 105, 110, 117, 109, 32, 86, 53, 32, 32, 32, 32, 0, 0, 0, 3, 0, 11, 6, 5, 25, 1, 0, 0, 24, 0, 0, 2 },
    }
    rf2.mspQueue:add(message)
end

local function setEscParameters(data)
    local profile = data._profile or selectProfile(data.hardware_version.value, (data.esc_type2.value or "") .. (data.esc_type.value or ""), data.firmware_version.value)
    local itemBytes = {}

    for i = 1, ITEM_COUNT do
        itemBytes[i] = (data._itemBytes and data._itemBytes[i]) or 0
    end

    for _, fieldName in ipairs(VALUE_FIELDS) do
        local itemIndex = profile.layout[fieldName]
        local rawValue = getFieldRawValue(data, profile, fieldName)
        if itemIndex and rawValue ~= nil then
            itemBytes[itemIndex] = rawValue
        end
    end

    local message = {
        command = 218, -- MSP_SET_ESC_PARAMETERS
        payload = {}
    }
    rf2.mspHelper.writeU8(message.payload, data.esc_signature.value)
    rf2.mspHelper.writeU8(message.payload, data.command.value)
    rf2.mspHelper.writeText(message.payload, data.firmware_version.value or "", 16)
    rf2.mspHelper.writeText(message.payload, data.hardware_version.value or "", 16)
    rf2.mspHelper.writeText(message.payload, data.esc_type2.value or "", 16)
    rf2.mspHelper.writeText(message.payload, data.esc_type.value or "", 15)
    for i = 1, ITEM_COUNT do
        rf2.mspHelper.writeU8(message.payload, itemBytes[i] or 0)
    end
    rf2.mspQueue:add(message)
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}
