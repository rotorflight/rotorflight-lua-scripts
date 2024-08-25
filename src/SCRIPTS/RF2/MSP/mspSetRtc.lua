local function setRtc(callback, callbackParam)
    local message = {
        command = 246, -- MSP_SET_RTC
        payload = {},
        processReply = function(self, buf)
            callback(callbackParam)
        end,
        simulatorResponse = {}
    }

    local now = getRtcTime()
    -- format: seconds after the epoch (32) / milliseconds (16)
    for i = 1, 4 do
        rf2.mspHelper.writeU8(message.payload, bit32.band(now, 0xFF))
        now = bit32.rshift(now, 8)
    end
    -- we don't have milliseconds
    rf2.mspHelper.writeU16(message.payload, 0)

    rf2.mspQueue:add(message)
end

return {
    setRtc = setRtc
}