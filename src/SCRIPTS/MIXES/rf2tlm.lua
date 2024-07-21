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
    setTelemetryValue(0x0020, 0, 0, cnt, UNIT_RAW, 0, "Cel#")
    for i = 1, cnt
    do
        val,pos = decU8(data,pos)
        val = val > 0 and val + 200 or 0
        vol = bit32.lshift(cnt,24) + bit32.lshift(i-1, 16) + val
        setTelemetryValue(0x002F, 0, 0, vol, UNIT_CELLS, 2, "Cels")
    end
    return nil, pos
end

local function decControl(data, pos)
    local r,p,y,c
    p,r,pos = decS12S12(data,pos)
    y,c,pos = decS12S12(data,pos)
    setTelemetryValue(0x0031, 0, 0, p, UNIT_DEGREE, 2, "CPtc")
    setTelemetryValue(0x0032, 0, 0, r, UNIT_DEGREE, 2, "CRol")
    setTelemetryValue(0x0033, 0, 0, y, UNIT_DEGREE, 2, "CYaw")
    setTelemetryValue(0x0034, 0, 0, c, UNIT_DEGREE, 2, "CCol")
    return nil, pos
end

local function decAttitude(data, pos)
    local p,r,y
    p,pos = decS16(data,pos)
    r,pos = decS16(data,pos)
    y,pos = decS16(data,pos)
    setTelemetryValue(0x0101, 0, 0, p, UNIT_DEGREE, 1, "Ptch")
    setTelemetryValue(0x0102, 0, 0, r, UNIT_DEGREE, 1, "Roll")
    setTelemetryValue(0x0103, 0, 0, y, UNIT_DEGREE, 1, "Yaw")
    return nil, pos
end

local function decAccel(data, pos)
    local x,y,z
    x,pos = decS16(data,pos)
    y,pos = decS16(data,pos)
    z,pos = decS16(data,pos)
    setTelemetryValue(0x0111, 0, 0, x, UNIT_G, 2, "AccX")
    setTelemetryValue(0x0112, 0, 0, y, UNIT_G, 2, "AccY")
    setTelemetryValue(0x0113, 0, 0, z, UNIT_G, 2, "AccZ")
    return nil, pos
end

local function decLatLong(data, pos)
    local lat,lon
    lat,pos = decS32(data,pos)
    lon,pos = decS32(data,pos)
    setTelemetryValue(0x0070, 0, 0, 0, UNIT_GPS, 0, "GPS")
    setTelemetryValue(0x0070, 0, 0, lat, UNIT_GPS_LATITUDE)
    setTelemetryValue(0x0070, 0, 0, lon, UNIT_GPS_LONGITUDE)
    return nil, pos
end

local function decAdjFunc(data, pos)
    local fun,val
    fun,pos = decU16(data,pos)
    val,pos = decS32(data,pos)
    setTelemetryValue(0x0221, 0, 0, fun, UNIT_RAW, 0, "AdjF")
    setTelemetryValue(0x0222, 0, 0, val, UNIT_RAW, 0, "AdjV")
    return nil, pos
end


local RFSensors = {
    -- No data
    [0x0000]  = { name="NULL",    unit=UNIT_RAW,                 prec=0,    dec=decNil  },
    -- Heartbeat (millisecond uptime % 60000)
    [0x0001]  = { name="BEAT",    unit=UNIT_RAW,                 prec=0,    dec=decU16  },

    -- Main battery voltage
    [0x0011]  = { name="Vbat",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- Main battery current
    [0x0012]  = { name="Curr",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- Main battery used capacity
    [0x0013]  = { name="Capa",    unit=UNIT_MAH,                 prec=0,    dec=decU16  },
    -- Main battery State-of-Charge / fuel level
    [0x0014]  = { name="Fuel",    unit=UNIT_PERCENT,             prec=0,    dec=decU8   },

    -- Main battery cell count
    [0x0020]  = { name="Cel#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Main battery cell voltage (minimum/average)
    [0x0021]  = { name="Vcel",    unit=UNIT_VOLTS,               prec=2,    dec=decCellV },
    -- Main battery cell voltages
    [0x002F]  = { name="Cels",    unit=UNIT_VOLTS,               prec=2,    dec=decCells },

    -- Control Combined (hires)
    [0x0030]  = { name="Ctrl",    unit=UNIT_RAW,                 prec=0,    dec=decControl },
    -- Pitch Control angle
    [0x0031]  = { name="CPtc",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Roll Control angle
    [0x0032]  = { name="CRol",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Yaw Control angle
    [0x0033]  = { name="CYaw",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Collective Control angle
    [0x0034]  = { name="CCol",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Throttle output %
    [0x0035]  = { name="Thr",     unit=UNIT_PERCENT,             prec=0,    dec=decS8   },

    -- ESC voltage
    [0x0041]  = { name="EscV",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- ESC current
    [0x0042]  = { name="EscI",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- ESC capacity/consumption
    [0x0043]  = { name="EscC",    unit=UNIT_MAH,                 prec=0,    dec=decU16  },
    -- ESC eRPM
    [0x0044]  = { name="EscR",    unit=UNIT_RPMS,                prec=0,    dec=decU16  },
    -- ESC PWM/Power
    [0x0045]  = { name="EscP",    unit=UNIT_PERCENT,             prec=1,    dec=decU16  },
    -- ESC throttle
    [0x0046]  = { name="Esc%",    unit=UNIT_PERCENT,             prec=1,    dec=decU16  },
    -- ESC temperature
    [0x0047]  = { name="EscT",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },
    -- ESC / BEC temperature
    [0x0048]  = { name="BecT",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },
    -- ESC / BEC voltage
    [0x0049]  = { name="BecV",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- ESC / BEC current
    [0x004A]  = { name="BecI",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- ESC Status Flags
    [0x004E]  = { name="EscF",    unit=UNIT_RAW,                 prec=0,    dec=decU32  },
    -- ESC Model Id
    [0x004F]  = { name="Esc#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },

    -- Combined ESC voltage
    [0x0080]  = { name="Vesc",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- BEC voltage
    [0x0081]  = { name="Vbec",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- BUS voltage
    [0x0082]  = { name="Vbus",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },
    -- MCU voltage
    [0x0083]  = { name="Vmcu",    unit=UNIT_VOLTS,               prec=2,    dec=decU16  },

    -- Combined ESC current
    [0x0090]  = { name="Iesc",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- BEC current
    [0x0091]  = { name="Ibec",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- BUS current
    [0x0092]  = { name="Ibus",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },
    -- MCU current
    [0x0093]  = { name="Imcu",    unit=UNIT_AMPS,                prec=2,    dec=decU16  },

    -- Combined ESC temeperature
    [0x00A0]  = { name="Tesc",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },
    -- BEC temperature
    [0x00A1]  = { name="Tbec",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },
    --MCU temperature
    [0x00A3]  = { name="Tmcu",    unit=UNIT_CELSIUS,             prec=0,    dec=decU8   },

    -- Heading (combined gyro+mag+GPS)
    [0x00B1]  = { name="Hdg",     unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- Altitude (combined baro+GPS)
    [0x00B2]  = { name="Alt",     unit=UNIT_METERS,              prec=2,    dec=decS24  },
    -- Variometer (combined baro+GPS)
    [0x00B3]  = { name="Var",     unit=UNIT_METERS_PER_SECOND,   prec=2,    dec=decS16  },

    -- Headspeed
    [0x00C0]  = { name="Hspd",    unit=UNIT_RPMS,                prec=0,    dec=decU16  },
    -- Tailspeed
    [0x00C1]  = { name="Tspd",    unit=UNIT_RPMS,                prec=0,    dec=decU16  },

    -- Attitude (hires combined)
    [0x0100]  = { name="Attd",    unit=UNIT_DEGREE,              prec=1,    dec=decAttitude },
    -- Attitude pitch
    [0x0101]  = { name="Ptch",    unit=UNIT_DEGREE,              prec=0,    dec=decS16  },
    -- Attitude roll
    [0x0102]  = { name="Roll",    unit=UNIT_DEGREE,              prec=0,    dec=decS16  },
    -- Attitude yaw
    [0x0103]  = { name="Yaw",     unit=UNIT_DEGREE,              prec=0,    dec=decS16  },

    -- Acceleration (hires combined)
    [0x0110]  = { name="Accl",    unit=UNIT_G,                   prec=2,    dec=decAccel },
    -- Acceleration X
    [0x0111]  = { name="AccX",    unit=UNIT_G,                   prec=1,    dec=decS16  },
    -- Acceleration Y
    [0x0112]  = { name="AccY",    unit=UNIT_G,                   prec=1,    dec=decS16  },
    -- Acceleration Z
    [0x0113]  = { name="AccZ",    unit=UNIT_G,                   prec=1,    dec=decS16  },

    -- GPS Satellite count
    [0x0121]  = { name="Sats",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- GPS PDOP
    [0x0122]  = { name="PDOP",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- GPS HDOP
    [0x0123]  = { name="HDOP",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- GPS VDOP
    [0x0124]  = { name="VDOP",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- GPS Coordinates
    [0x0125]  = { name="GPS",     unit=UNIT_RAW,                 prec=0,    dec=decLatLong },
    -- GPS altitude
    [0x0126]  = { name="GAlt",    unit=UNIT_METERS,              prec=1,    dec=decS16  },
    -- GPS heading
    [0x0127]  = { name="GHdg",    unit=UNIT_DEGREE,              prec=1,    dec=decS16  },
    -- GPS ground speed
    [0x0128]  = { name="GSpd",    unit=UNIT_METERS_PER_SECOND,   prec=2,    dec=decU16  },
    -- GPS home distance
    [0x0129]  = { name="GDis",    unit=UNIT_METERS,              prec=1,    dec=decU16  },
    -- GPS home direction
    [0x012A]  = { name="GDir",    unit=UNIT_METERS,              prec=1,    dec=decU16  },

    -- CPU load
    [0x0141]  = { name="CPU%",    unit=UNIT_PERCENT,             prec=0,    dec=decU8   },
    -- System load
    [0x0142]  = { name="SYS%",    unit=UNIT_PERCENT,             prec=0,    dec=decU8   },
    -- Realtime CPU load
    [0x0143]  = { name="RT%",     unit=UNIT_PERCENT,             prec=0,    dec=decU8   },

    -- Model ID
    [0x0200]  = { name="MDL#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Flight mode flags
    [0x0201]  = { name="Mode",    unit=UNIT_RAW,                 prec=0,    dec=decU16  },
    -- Arming flags
    [0x0202]  = { name="ARM",     unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Arming disable flags
    [0x0203]  = { name="ARMD",    unit=UNIT_RAW,                 prec=0,    dec=decU32  },
    -- Rescue state
    [0x0204]  = { name="Resc",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Governor state
    [0x0205]  = { name="Gov",     unit=UNIT_RAW,                 prec=0,    dec=decU8   },

    -- Current PID profile
    [0x0211]  = { name="PID#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Current Rate profile
    [0x0212]  = { name="RTE#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },
    -- Current LED profile
    [0x0213]  = { name="LED#",    unit=UNIT_RAW,                 prec=0,    dec=decU8   },

    -- Adjustment function
    [0x0220]  = { name="ADJ",     unit=UNIT_RAW,                 prec=0,    dec=decAdjFunc },

    -- Debug
    [0xFE00]  = { name="DBG0",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xFE01]  = { name="DBG1",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xFE02]  = { name="DBG2",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xFE03]  = { name="DBG3",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xFE04]  = { name="DBG4",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xFE05]  = { name="DBG5",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xFE06]  = { name="DBG6",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
    [0xFE07]  = { name="DBG7",    unit=UNIT_RAW,                 prec=0,    dec=decS32  },
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
            setTelemetryValue(0xFF01, 0, 0, telemetryFrameCount, UNIT_RAW, 0, "*Cnt")
            setTelemetryValue(0xFF02, 0, 0, telemetryFrameSkip, UNIT_RAW, 0, "*Skp")
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
