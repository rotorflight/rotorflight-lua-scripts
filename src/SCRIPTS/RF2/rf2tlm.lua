--
-- Rotorflight Custom Telemetry Decoder for ELRS
--

local RFSensors = ...

local function decU8(data, pos)
    return data[pos], pos+1
end

local function decU16(data, pos)
    return bit32.lshift(data[pos],8) + data[pos+1], pos+2
end

local telemetryFrameId = 0
local telemetryFrameSkip = 0
local telemetryFrameCount = 0

local function crossfirePop()
    local CRSF_FRAME_CUSTOM_TELEM   = 0x88
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

return {
    run = crossfirePopAll
}
