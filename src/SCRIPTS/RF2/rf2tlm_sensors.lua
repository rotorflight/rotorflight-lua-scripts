local requestedSensorsById = ...

local function decNil(data, pos)
    return nil, pos
end

local function decU8(data, pos)
    return data[pos], pos+1
end

local function decS8(data, pos)
    local val,ptr = decU8(data,pos)
    return val < 0x80 and val or val - 0x100, ptr
end

local function decU16(data, pos)
    return bit32.lshift(data[pos],8) + data[pos+1], pos+2
end

local function decS16(data, pos)
    local val,ptr = decU16(data,pos)
    return val < 0x8000 and val or val - 0x10000, ptr
end

local function decU12U12(data, pos)
    local a = bit32.lshift(bit32.extract(data[pos],0,4),8) + data[pos+1]
    local b = bit32.lshift(bit32.extract(data[pos],4,4),8) + data[pos+2]
    return a,b,pos+3
end

local function decS12S12(data, pos)
    local a,b,ptr = decU12U12(data, pos)
    return a < 0x0800 and a or a - 0x1000, b < 0x0800 and b or b - 0x1000, ptr
end

local function decU24(data, pos)
    return bit32.lshift(data[pos],16) + bit32.lshift(data[pos+1],8) + data[pos+2], pos+3
end

local function decS24(data, pos)
    local val,ptr = decU24(data,pos)
    return val < 0x800000 and val or val - 0x1000000, ptr
end

local function decU32(data, pos)
    return bit32.lshift(data[pos],24) + bit32.lshift(data[pos+1],16) + bit32.lshift(data[pos+2],8) + data[pos+3], pos+4
end

local function decS32(data, pos)
    local val,ptr = decU32(data,pos)
    return val < 0x80000000 and val or val - 0x100000000, ptr
end

local function decCellV(data, pos)
    local val,ptr = decU8(data,pos)
    return val > 0 and val + 200 or 0, ptr
end

local function decCells(data, pos)
    local cnt,val,vol
    cnt,pos = decU8(data,pos)
    setTelemetryValue(0x1020, 0, 0, cnt, UNIT_RAW, 0, "Cel#")
    for i = 1, cnt
    do
        val,pos = decU8(data,pos)
        val = val > 0 and val + 200 or 0
        vol = bit32.lshift(cnt,24) + bit32.lshift(i-1, 16) + val
        setTelemetryValue(0x102F, 0, 0, vol, UNIT_CELLS, 2, "Cels")
    end
    return nil, pos
end

local function decControl(data, pos)
    local r,p,y,c
    p,r,pos = decS12S12(data,pos)
    y,c,pos = decS12S12(data,pos)
    setTelemetryValue(0x1031, 0, 0, p, UNIT_DEGREE, 2, "CPtc")
    setTelemetryValue(0x1032, 0, 0, r, UNIT_DEGREE, 2, "CRol")
    setTelemetryValue(0x1033, 0, 0, 3*y, UNIT_DEGREE, 2, "CYaw")
    setTelemetryValue(0x1034, 0, 0, c, UNIT_DEGREE, 2, "CCol")
    return nil, pos
end

local function decAttitude(data, pos)
    local p,r,y
    p,pos = decS16(data,pos)
    r,pos = decS16(data,pos)
    y,pos = decS16(data,pos)
    setTelemetryValue(0x1101, 0, 0, p, UNIT_DEGREE, 1, "Ptch")
    setTelemetryValue(0x1102, 0, 0, r, UNIT_DEGREE, 1, "Roll")
    setTelemetryValue(0x1103, 0, 0, y, UNIT_DEGREE, 1, "Yaw")
    return nil, pos
end

local function decAccel(data, pos)
    local x,y,z
    x,pos = decS16(data,pos)
    y,pos = decS16(data,pos)
    z,pos = decS16(data,pos)
    setTelemetryValue(0x1111, 0, 0, x, UNIT_G, 2, "AccX")
    setTelemetryValue(0x1112, 0, 0, y, UNIT_G, 2, "AccY")
    setTelemetryValue(0x1113, 0, 0, z, UNIT_G, 2, "AccZ")
    return nil, pos
end

local function decLatLong(data, pos)
    local UNIT_GPS_LONGITUDE = 43
    local UNIT_GPS_LATITUDE = 44
    local lat,lon
    lat,pos = decS32(data,pos)
    lon,pos = decS32(data,pos)
    setTelemetryValue(0x1125, 0, 0, 0, UNIT_GPS, 0, "GPS")
    setTelemetryValue(0x1125, 0, 0, lat/10, UNIT_GPS_LATITUDE)
    setTelemetryValue(0x1125, 0, 0, lon/10, UNIT_GPS_LONGITUDE)
    return nil, pos
end

local function decAdjFunc(data, pos)
    local fun,val
    fun,pos = decU16(data,pos)
    val,pos = decS32(data,pos)
    setTelemetryValue(0x1221, 0, 0, fun, UNIT_RAW, 0, "AdjF")
    setTelemetryValue(0x1222, 0, 0, val, UNIT_RAW, 0, "AdjV")
    return nil, pos
end

local sensorsById  =  {
    -- No data
    [0] = { sid = 0x1000, name = "NONE", unit = UNIT_RAW, prec = 0, dec = decNil },
    -- Heartbeat (millisecond uptime % 60000)
    [1] = { sid = 0x1001, name = "BEAT", unit = UNIT_RAW, prec = 0, dec = decU16 },

    -- Main battery voltage
    [3] = { sid = 0x1011, name = "Vbat", unit = UNIT_VOLTS, prec = 2, dec = decU16 },
    -- Main battery current
    [4] = { sid = 0x1012, name = "Curr", unit = UNIT_AMPS, prec = 2, dec = decU16 },
    -- Main battery used capacity
    [5] = { sid = 0x1013, name = "Capa", unit = UNIT_MAH, prec = 0, dec = decU16 },
    -- Main battery charge / fuel level
    [6] = { sid = 0x1014, name = "Bat%", unit = UNIT_PERCENT, prec = 0, dec = decU8 },

    -- Main battery cell count
    [7] = { sid = 0x1020, name = "Cel#", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- Main battery cell voltage (minimum/average)
    [8] = { sid = 0x1021, name = "Vcel", unit = UNIT_VOLTS, prec = 2, dec = decCellV },
    -- Main battery cell voltages
    [9] = { sid = 0x102F, name = "Cels", unit = UNIT_VOLTS, prec = 2, dec = decCells },

    -- Control Combined (hires)
    [10] = { sid = 0x1030, name = "Ctrl", unit = UNIT_RAW, prec = 0, dec = decControl },
    -- Pitch Control angle
    [11] = { sid = 0x1031, name = "CPtc", unit = UNIT_DEGREE, prec = 1, dec = decS16 },
    -- Roll Control angle
    [12] = { sid = 0x1032, name = "CRol", unit = UNIT_DEGREE, prec = 1, dec = decS16 },
    -- Yaw Control angle
    [13] = { sid = 0x1033, name = "CYaw", unit = UNIT_DEGREE, prec = 1, dec = decS16 },
    -- Collective Control angle
    [14] = { sid = 0x1034, name = "CCol", unit = UNIT_DEGREE, prec = 1, dec = decS16 },
    -- Throttle output %
    [15] = { sid = 0x1035, name = "Thr", unit = UNIT_PERCENT, prec = 0, dec = decS8 },

    -- ESC#1 voltage
    [17] = { sid = 0x1041, name = "EscV", unit = UNIT_VOLTS, prec = 2, dec = decU16 },
    -- ESC#1 current
    [18] = { sid = 0x1042, name = "EscI", unit = UNIT_AMPS, prec = 2, dec = decU16 },
    -- ESC#1 capacity/consumption
    [19] = { sid = 0x1043, name = "EscC", unit = UNIT_MAH, prec = 0, dec = decU16 },
    -- ESC#1 eRPM
    [20] = { sid = 0x1044, name = "EscR", unit = UNIT_RPMS, prec = 0, dec = decU24 },
    -- ESC#1 PWM/Power
    [21] = { sid = 0x1045, name = "EscP", unit = UNIT_PERCENT, prec = 1, dec = decU16 },
    -- ESC#1 throttle
    [22] = { sid = 0x1046, name = "Esc%", unit = UNIT_PERCENT, prec = 1, dec = decU16 },
    -- ESC#1 temperature
    [23] = { sid = 0x1047, name = "EscT", unit = UNIT_CELSIUS, prec = 0, dec = decU8 },
    -- ESC#1 / BEC temperature
    [24] = { sid = 0x1048, name = "BecT", unit = UNIT_CELSIUS, prec = 0, dec = decU8 },
    -- ESC#1 / BEC voltage
    [25] = { sid = 0x1049, name = "BecV", unit = UNIT_VOLTS, prec = 2, dec = decU16 },
    -- ESC#1 / BEC current
    [26] = { sid = 0x104A, name = "BecI", unit = UNIT_AMPS, prec = 2, dec = decU16 },
    -- ESC#1 Status Flags
    [27] = { sid = 0x104E, name = "EscF", unit = UNIT_RAW, prec = 0, dec = decU32 },
    -- ESC#1 Model Id
    [28] = { sid = 0x104F, name = "Esc#", unit = UNIT_RAW, prec = 0, dec = decU8 },

    -- ESC#2 voltage
    [30] = { sid = 0x1051, name = "Es2V", unit = UNIT_VOLTS, prec = 2, dec = decU16 },
    -- ESC#2 current
    [31] = { sid = 0x1052, name = "Es2I", unit = UNIT_AMPS, prec = 2, dec = decU16 },
    -- ESC#2 capacity/consumption
    [32] = { sid = 0x1053, name = "Es2C", unit = UNIT_MAH, prec = 0, dec = decU16 },
    -- ESC#2 eRPM
    [33] = { sid = 0x1054, name = "Es2R", unit = UNIT_RPMS, prec = 0, dec = decU24 },
    -- ESC#2 temperature
    [36] = { sid = 0x1057, name = "Es2T", unit = UNIT_CELSIUS, prec = 0, dec = nil },
    -- ESC#2 Model Id
    [41] = { sid = 0x105F, name = "Es2#", unit = UNIT_RAW, prec = 0, dec = decU8 },

    -- Combined ESC voltage
    [42] = { sid = 0x1080, name = "Vesc", unit = UNIT_VOLTS, prec = 2, dec = decU16 },
    -- BEC voltage
    [43] = { sid = 0x1081, name = "Vbec", unit = UNIT_VOLTS, prec = 2, dec = decU16 },
    -- BUS voltage
    [44] = { sid = 0x1082, name = "Vbus", unit = UNIT_VOLTS, prec = 2, dec = decU16 },
    -- MCU voltage
    [45] = { sid = 0x1083, name = "Vmcu", unit = UNIT_VOLTS, prec = 2, dec = decU16 },

    -- Combined ESC current
    [46] = { sid = 0x1090, name = "Iesc", unit = UNIT_AMPS, prec = 2, dec = decU16 },
    -- BEC current
    [47] = { sid = 0x1091, name = "Ibec", unit = UNIT_AMPS, prec = 2, dec = decU16 },
    -- BUS current
    [48] = { sid = 0x1092, name = "Ibus", unit = UNIT_AMPS, prec = 2, dec = decU16 },
    -- MCU current
    [49] = { sid = 0x1093, name = "Imcu", unit = UNIT_AMPS, prec = 2, dec = decU16 },

    -- Combined ESC temperature
    [50] = { sid = 0x10A0, name = "Tesc", unit = UNIT_CELSIUS, prec = 0, dec = decU8 },
    -- BEC temperature
    [51] = { sid = 0x10A1, name = "Tbec", unit = UNIT_CELSIUS, prec = 0, dec = decU8 },
    -- MCU temperature
    [52] = { sid = 0x10A3, name = "Tmcu", unit = UNIT_CELSIUS, prec = 0, dec = decU8 },

    -- Heading (combined gyro+mag+GPS)
    [57] = { sid = 0x10B1, name = "Hdg", unit = UNIT_DEGREE, prec = 1, dec = decS16 },
    -- Altitude (combined baro+GPS)
    [58] = { sid = 0x10B2, name = "Alt", unit = UNIT_METERS, prec = 2, dec = decS24 },
    -- Variometer (combined baro+GPS)
    [59] = { sid = 0x10B3, name = "Var", unit = UNIT_METERS_PER_SECOND, prec = 2, dec = decS16 },

    -- Headspeed
    [60] = { sid = 0x10C0, name = "Hspd", unit = UNIT_RPMS, prec = 0, dec = decU16 },
    -- Tailspeed
    [61] = { sid = 0x10C1, name = "Tspd", unit = UNIT_RPMS, prec = 0, dec = decU16 },

    -- Attitude (hires combined)
    [64] = { sid = 0x1100, name = "Attd", unit = UNIT_DEGREE, prec = 1, dec = decAttitude },
    -- Attitude pitch
    [65] = { sid = 0x1101, name = "Ptch", unit = UNIT_DEGREE, prec = 0, dec = decS16 },
    -- Attitude roll
    [66] = { sid = 0x1102, name = "Roll", unit = UNIT_DEGREE, prec = 0, dec = decS16 },
    -- Attitude yaw
    [67] = { sid = 0x1103, name = "Yaw", unit = UNIT_DEGREE, prec = 0, dec = decS16 },

    -- Acceleration (hires combined)
    [68] = { sid = 0x1110, name = "Accl", unit = UNIT_G, prec = 2, dec = decAccel },
    -- Acceleration X
    [69] = { sid = 0x1111, name = "AccX", unit = UNIT_G, prec = 1, dec = decS16 },
    -- Acceleration Y
    [70] = { sid = 0x1112, name = "AccY", unit = UNIT_G, prec = 1, dec = decS16 },
    -- Acceleration Z
    [71] = { sid = 0x1113, name = "AccZ", unit = UNIT_G, prec = 1, dec = decS16 },

    -- GPS Satellite count
    [73] = { sid = 0x1121, name = "Sats", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- GPS PDOP
    [74] = { sid = 0x1122, name = "PDOP", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- GPS HDOP
    [75] = { sid = 0x1123, name = "HDOP", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- GPS VDOP
    [76] = { sid = 0x1124, name = "VDOP", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- GPS Coordinates
    [77] = { sid = 0x1125, name = "GPS", unit = UNIT_RAW, prec = 0, dec = decLatLong },
    -- GPS altitude
    [78] = { sid = 0x1126, name = "GAlt", unit = UNIT_METERS, prec = 1, dec = decS16 },
    -- GPS heading
    [79] = { sid = 0x1127, name = "GHdg", unit = UNIT_DEGREE, prec = 1, dec = decS16 },
    -- GPS ground speed
    [80] = { sid = 0x1128, name = "GSpd", unit = UNIT_METERS_PER_SECOND, prec = 2, dec = decU16 },
    -- GPS home distance
    [81] = { sid = 0x1129, name = "GDis", unit = UNIT_METERS, prec = 1, dec = decU16 },
    -- GPS home direction
    [82] = { sid = 0x112A, name = "GDir", unit = UNIT_METERS, prec = 1, dec = decU16 },

    -- CPU load
    [85] = { sid = 0x1141, name = "CPU%", unit = UNIT_PERCENT, prec = 0, dec = decU8 },
    -- System load
    [86] = { sid = 0x1142, name = "SYS%", unit = UNIT_PERCENT, prec = 0, dec = decU8 },
    -- Realtime CPU load
    [87] = { sid = 0x1143, name = "RT%", unit = UNIT_PERCENT, prec = 0, dec = decU8 },

    -- Model ID
    [88] = { sid = 0x1200, name = "MDL#", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- Flight mode flags
    [89] = { sid = 0x1201, name = "Mode", unit = UNIT_RAW, prec = 0, dec = decU16 },
    -- Arming flags
    [90] = { sid = 0x1202, name = "ARM", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- Arming disable flags
    [91] = { sid = 0x1203, name = "ARMD", unit = UNIT_RAW, prec = 0, dec = decU32 },
    -- Rescue state
    [92] = { sid = 0x1204, name = "Resc", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- Governor state
    [93] = { sid = 0x1205, name = "Gov", unit = UNIT_RAW, prec = 0, dec = decU8 },

    -- Current PID profile
    [95] = { sid = 0x1211, name = "PID#", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- Current Rate profile
    [96] = { sid = 0x1212, name = "RTE#", unit = UNIT_RAW, prec = 0, dec = decU8 },
    -- Current LED profile
    [98] = { sid = 0x1213, name = "LED#", unit = UNIT_RAW, prec = 0, dec = decU8 },

    -- Adjustment function
    [99] = { sid = 0x1220, name = "ADJ", unit = UNIT_RAW, prec = 0, dec = decAdjFunc },

    -- Debug
    [100] = {sid = 0xDB00, name = "DBG0", unit = UNIT_RAW, prec = 0, dec = decS32 },
    [101] = {sid = 0xDB01, name = "DBG1", unit = UNIT_RAW, prec = 0, dec = decS32 },
    [102] = {sid = 0xDB02, name = "DBG2", unit = UNIT_RAW, prec = 0, dec = decS32 },
    [103] = {sid = 0xDB03, name = "DBG3", unit = UNIT_RAW, prec = 0, dec = decS32 },
    [104] = {sid = 0xDB04, name = "DBG4", unit = UNIT_RAW, prec = 0, dec = decS32 },
    [105] = {sid = 0xDB05, name = "DBG5", unit = UNIT_RAW, prec = 0, dec = decS32 },
    [106] = {sid = 0xDB06, name = "DBG6", unit = UNIT_RAW, prec = 0, dec = decS32 },
    [107] = {sid = 0xDB07, name = "DBG7", unit = UNIT_RAW, prec = 0, dec = decS32 },
}

local function initializeSensors(ids)
    local data = { 0, 0, 0, 0, 0, 0, 0, 0 }
    setTelemetryValue(0xEE01, 0, 0, 0, UNIT_RAW, 0, "*Cnt")
    setTelemetryValue(0xEE02, 0, 0, 0, UNIT_RAW, 0, "*Skp")

    for i = 1, #ids do
        local id = ids[i]
        if id ~= 0 and sensorsById[id] ~= nil then
            local sensor = sensorsById[id]
            local ptr = 1
            local val = sensor.dec(data, ptr)
            if val then
                setTelemetryValue(sensor.sid, 0, 0, 0, sensor.unit, sensor.prec, sensor.name)
            end
        end
    end
end

local function getSensorsBySid(ids)
    -- returns a table with sensors with an id in ids, indexed by sensor id (sid).
    -- Example: getSensorsBySid({3, 4}) would return:
    -- {
    --    [0x1011]  = { name = "Vbat",    unit = UNIT_VOLTS,               prec = 2,    dec = decU16  },
    --    [0x1012]  = { name = "Curr",    unit = UNIT_AMPS,                prec = 2,    dec = decU16  }
    -- }

    local result = {}
    for i = 1, #ids do
        local id = ids[i]
        if id ~= 0 and sensorsById[id] ~= nil then
            local sensor = sensorsById[id]
            result[sensor.sid] = { name = sensor.name, unit = sensor.unit, prec = sensor.prec, dec = sensor.dec }
        end
    end
    return result
end

initializeSensors(requestedSensorsById)
return getSensorsBySid(requestedSensorsById)
