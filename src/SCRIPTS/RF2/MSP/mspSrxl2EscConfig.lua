-- MSP2_GET_SRXL2_ESC_CONFIG (0x5F16 read / 0x5F17 write): the SRXL2 ESC bus
-- settings (firmware pg/srxl2_esc.h). The read reply starts with a payload
-- version byte; the write takes the same fields without it. The firmware
-- reads them at boot, so a change needs the usual save and reboot.
local function getDefaults()
    local defaults = {}
    -- 0 = single motor; 1..31 = the SRXL2 channel carrying motor 2 (channel 0
    -- is always motor 1), for dual-motor Smart ESCs such as the SPMXAE1020.
    local channelTable = { [0] = "Off" }
    for ch = 1, 31 do
        channelTable[ch] = tostring(ch)
    end

    -- Read back and written unchanged: the firmware derives the throttle rate
    -- from the motor PWM rate, so the page does not show it.
    defaults.throttle_rate_hz = { min = 1, max = 2000, unit = rf2.units.herz }
    defaults.telem_interval_frames = { min = 0, max = 255 }
    defaults.motor2_channel = { min = 0, max = 31, table = channelTable }
    return defaults
end

-- errorCallback runs on the FC's MSP error reply: firmware without the message.
local function getSrxl2EscConfig(callback, callbackParam, data, errorCallback)
    data = data or getDefaults()
    local message = {
        command = 0x5F16, -- MSP2_GET_SRXL2_ESC_CONFIG
        processReply = function(self, buf)
            rf2.mspHelper.readU8(buf) -- payload version 1
            data.throttle_rate_hz.value = rf2.mspHelper.readU16(buf)
            data.telem_interval_frames.value = rf2.mspHelper.readU8(buf)
            data.motor2_channel.value = rf2.mspHelper.readU8(buf)
            callback(callbackParam, data)
        end,
        errorHandler = function(self)
            if errorCallback then errorCallback(callbackParam) end
        end,
        simulatorResponse = { 1, 250, 0, 7, 0 }
    }
    rf2.mspQueue:add(message)
end

local function setSrxl2EscConfig(config)
    local message = {
        command = 0x5F17, -- MSP2_SET_SRXL2_ESC_CONFIG
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU16(message.payload, config.throttle_rate_hz.value)
    rf2.mspHelper.writeU8(message.payload, config.telem_interval_frames.value)
    rf2.mspHelper.writeU8(message.payload, config.motor2_channel.value)
    rf2.mspQueue:add(message)
end

return {
    read = getSrxl2EscConfig,
    write = setSrxl2EscConfig,
    getDefaults = getDefaults
}
