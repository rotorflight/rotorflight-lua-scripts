--
-- Rotorflight Custom Telemetry Decoder for ELRS
--

local CRSF_FRAME_CUSTOM_TELEM   = 0x88


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
    local lat,lon
    lat,pos = decS32(data,pos)
    lon,pos = decS32(data,pos)
    setTelemetryValue(0x1125, 0, 0, 0, UNIT_GPS, 0, "GPS")
    setTelemetryValue(0x1125, 0, 0, lat, UNIT_GPS_LATITUDE)
    setTelemetryValue(0x1125, 0, 0, lon, UNIT_GPS_LONGITUDE)
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


local RFSensors = {
    -- No data
    [0x1000]  = { name="NULL",    unit=UNIT_RAW,                 prec=0,    dec=decNil  },
    -- Heartbeat (millisecond uptime % 60000)
    [0x1001]  = { name="BEAT",    unit=UNIT_RAW,                 prec=0,    dec=decU16  },

    -- Main battery voltage
    [0x1011]  = { name="Vbat",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- Main battery current
    [0x1012]  = { name="Curr",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- Main battery used capacity
    [0x1013]  = { name="Capa",    unit=UNIT_MAH,                 prec=0,    dec=decU16  },
    -- Main battery charge / fuel level
    [0x1014]  = { name="Bat%",    unit=UNIT_PERCENT,             prec=0,    dec=decU8   },

    -- Main battery cell count
    [0x1020]  = { name="Cel#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Main battery cell voltage (minimum/average)
    [0x1021]  = { name="Vcel",    unit=UNIT_VOLTS,               prec=2,    dec=decCellV },
    -- Main battery cell voltages
    [0x102F]  = { name="Cels",    unit=UNIT_VOLTS,               prec=2,    dec=decCells },

    -- Control Combined (hires)
    [0x1030]  = { name="Ctrl",    unit=UNIT_RAW,                 prec=0,    dec=decControl },
    -- Pitch Control angle
    [0x1031]  = { name="CPtc",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Roll Control angle
    [0x1032]  = { name="CRol",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Yaw Control angle
    [0x1033]  = { name="CYaw",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Collective Control angle
    [0x1034]  = { name="CCol",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Throttle output %
    [0x1035]  = { name="Thr",     unit=UNIT_PERCENT,             prec=0,    dec=decS8   },

    -- ESC#1 voltage
    [0x1041]  = { name="EscV",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- ESC#1 current
    [0x1042]  = { name="EscI",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- ESC#1 capacity/consumption
    [0x1043]  = { name="EscC",    unit=UNIT_MAH,                 prec=0,    dec=decU16  },
    -- ESC#1 eRPM
    [0x1044]  = { name="EscR",    unit=UNIT_RPMS,                prec=0,    dec=decU16  },
    -- ESC#1 PWM/Power
    [0x1045]  = { name="EscP",    unit=UNIT_PERCENT,             prec=1,    dec=decU16  },
    -- ESC#1 throttle
    [0x1046]  = { name="Esc%",    unit=UNIT_PERCENT,             prec=1,    dec=decU16  },
    -- ESC#1 temperature
    [0x1047]  = { name="EscT",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },
    -- ESC#1 / BEC temperature
    [0x1048]  = { name="BecT",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },
    -- ESC#1 / BEC voltage
    [0x1049]  = { name="BecV",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- ESC#1 / BEC current
    [0x104A]  = { name="BecI",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- ESC#1 Status Flags
    [0x104E]  = { name="EscF",    unit=UNIT_RAW,                 prec=0,    dec=decU32  },
    -- ESC#1 Model Id
    [0x104F]  = { name="Esc#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },

    -- ESC#2 voltage
    [0x1051]  = { name="Es2V",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- ESC#2 current
    [0x1052]  = { name="Es2I",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- ESC#2 capacity/consumption
    [0x1053]  = { name="Es2C",    unit=UNIT_MAH,                 prec=0,    dec=decU16  },
    -- ESC#2 eRPM
    [0x1054]  = { name="Es2R",    unit=UNIT_RPMS,                prec=0,    dec=decU16  },
    -- ESC#2 temperature
    [0x1057]  = { name="Es2T",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },
    -- ESC#2 Model Id
    [0x105F]  = { name="Es2#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },

    -- Combined ESC voltage
    [0x1080]  = { name="Vesc",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- BEC voltage
    [0x1081]  = { name="Vbec",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- BUS voltage
    [0x1082]  = { name="Vbus",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- MCU voltage
    [0x1083]  = { name="Vmcu",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },

    -- Combined ESC current
    [0x1090]  = { name="Iesc",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- BEC current
    [0x1091]  = { name="Ibec",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- BUS current
    [0x1092]  = { name="Ibus",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- MCU current
    [0x1093]  = { name="Imcu",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },

    -- Combined ESC temeperature
    [0x10A0]  = { name="Tesc",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },
    -- BEC temperature
    [0x10A1]  = { name="Tbec",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },
    --MCU temperature
    [0x10A3]  = { name="Tmcu",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },

    -- Heading (combined gyro+mag+GPS)
    [0x10B1]  = { name="Hdg",     unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Altitude (combined baro+GPS)
    [0x10B2]  = { name="Alt",     unit=UNIT_METERS,              prec=2,    dec=decS24  },
    -- Variometer (combined baro+GPS)
    [0x10B3]  = { name="Var",     unit=UNIT_METERS_PER_SECOND,   prec=2,    dec=decS16  },

    -- Headspeed
    [0x10C0]  = { name="Hspd",    unit=UNIT_RPMS,                prec=0,    dec=decU16  },
    -- Tailspeed
    [0x10C1]  = { name="Tspd",    unit=UNIT_RPMS,                prec=0,    dec=decU16  },

    -- Attitude (hires combined)
    [0x1100]  = { name="Attd",    unit=UNIT_DEGREE,              prec=1,    dec=decAttitude },
    -- Attitude pitch
    [0x1101]  = { name="Ptch",    unit=UNIT_DEGREE,              prec=0,    dec=decS16  },
    -- Attitude roll
    [0x1102]  = { name="Roll",    unit=UNIT_DEGREE,              prec=0,    dec=decS16  },
    -- Attitude yaw
    [0x1103]  = { name="Yaw",     unit=UNIT_DEGREE,              prec=0,    dec=decS16  },

    -- Acceleration (hires combined)
    [0x1110]  = { name="Accl",    unit=UNIT_G,                   prec=2,    dec=decAccel },
    -- Acceleration X
    [0x1111]  = { name="AccX",    unit=UNIT_G,                   prec=1,    dec=decS16  },
    -- Acceleration Y
    [0x1112]  = { name="AccY",    unit=UNIT_G,                   prec=1,    dec=decS16  },
    -- Acceleration Z
    [0x1113]  = { name="AccZ",    unit=UNIT_G,                   prec=1,    dec=decS16  },

    -- GPS Satellite count
    [0x1121]  = { name="Sats",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- GPS PDOP
    [0x1122]  = { name="PDOP",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- GPS HDOP
    [0x1123]  = { name="HDOP",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- GPS VDOP
    [0x1124]  = { name="VDOP",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- GPS Coordinates
    [0x1125]  = { name="GPS",     unit=UNIT_RAW,                 prec=0,    dec=decLatLong },
    -- GPS altitude
    [0x1126]  = { name="GAlt",    unit=UNIT_METERS,              prec=1,    dec=decS16  },
    -- GPS heading
    [0x1127]  = { name="GHdg",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- GPS ground speed
    [0x1128]  = { name="GSpd",    unit=UNIT_METERS_PER_SECOND,   prec=2,    dec=decU16  },
    -- GPS home distance
    [0x1129]  = { name="GDis",    unit=UNIT_METERS,              prec=1,    dec=decU16  },
    -- GPS home direction
    [0x112A]  = { name="GDir",    unit=UNIT_METERS,              prec=1,    dec=decU16  },

    -- CPU load
    [0x1141]  = { name="CPU%",    unit=UNIT_PERCENT,             prec=0,    dec=decU8   },
    -- System load
    [0x1142]  = { name="SYS%",    unit=UNIT_PERCENT,             prec=0,    dec=decU8   },
    -- Realtime CPU load
    [0x1143]  = { name="RT%",     unit=UNIT_PERCENT,             prec=0,    dec=decU8   },

    -- Model ID
    [0x1200]  = { name="MDL#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Flight mode flags
    [0x1201]  = { name="Mode",    unit=UNIT_RAW,                 prec=0,    dec=decU16  },
    -- Arming flags
    [0x1202]  = { name="ARM",     unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Arming disable flags
    [0x1203]  = { name="ARMD",    unit=UNIT_RAW,                 prec=0,    dec=decU32  },
    -- Rescue state
    [0x1204]  = { name="Resc",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Governor state
    [0x1205]  = { name="Gov",     unit=UNIT_RAW,                 prec=0,    dec=decU8   },

    -- Current PID profile
    [0x1211]  = { name="PID#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Current Rate profile
    [0x1212]  = { name="RTE#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Current LED profile
    [0x1213]  = { name="LED#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },

    -- Adjustment function
    [0x1220]  = { name="ADJ",     unit=UNIT_RAW,                 prec=0,    dec=decAdjFunc },

    -- Debug
    [0xDB00]  = { name="DBG0",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xDB01]  = { name="DBG1",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xDB02]  = { name="DBG2",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xDB03]  = { name="DBG3",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xDB04]  = { name="DBG4",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xDB05]  = { name="DBG5",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xDB06]  = { name="DBG6",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xDB07]  = { name="DBG7",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
}

local telemetryFrameId = 0
local telemetryFrameSkip = 0
local telemetryFrameCount = 0

local function crossfirePop()
    local command, data = crossfireTelemetryPop()
    if command and data then
        if command == CRSF_FRAME_CUSTOM_TELEM then
            local fid, sid, val
            local ptr = 3
            fid,ptr = decU8(data, ptr)
            local delta = bit32.band(fid - telemetryFrameId, 0xFF)
            if delta > 1 then
                telemetryFrameSkip = telemetryFrameSkip + 1
            end
            telemetryFrameId = fid
            telemetryFrameCount = telemetryFrameCount + 1
            while ptr < #data do
                sid,ptr = decU16(data, ptr)
                local sensor = RFSensors[sid]
                if sensor then
                    val,ptr = sensor.dec(data, ptr)
                    if val then
                        setTelemetryValue(sid, 0, 0, val, sensor.unit, sensor.prec, sensor.name)
                    end
                else
                    break
                end
            end
            setTelemetryValue(0xEE01, 0, 0, telemetryFrameCount, UNIT_RAW, 0, "*Cnt")
            setTelemetryValue(0xEE02, 0, 0, telemetryFrameSkip, UNIT_RAW, 0, "*Skp")
            --setTelemetryValue(0xEE03, 0, 0, telemetryFrameId, UNIT_RAW, 0, "*Frm")
        end
        return true
    end
    return false
end

local function crossfirePopAll()
    while crossfirePop() do end
end

local function background()
    local ret = pcall(crossfirePopAll)
end

return { run=background }
