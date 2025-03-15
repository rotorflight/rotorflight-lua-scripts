local function getAccTrim(data, callback, callbackParam)
    local message = {
        command = 240, -- MSP_ACC_TRIM
        processReply = function(self, buf)
            data.pitch_trim.value = rf2.mspHelper.readS16(buf)
            data.roll_trim.value = rf2.mspHelper.readS16(buf)
            callback(callbackParam)
        end,
        simulatorResponse = { 0, 0, 0, 0 }
    }
    rf2.mspQueue:add(message)
end

local function setAccTrim(data)
    local message = {
        command = 239, -- MSP_SET_ACC_TRIM
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU16(message.payload, data.pitch_trim.value)
    rf2.mspHelper.writeU16(message.payload, data.roll_trim.value)
    rf2.mspQueue:add(message)
end

local function getDefaults()
    local defaults = {}
    -- Note: @ is ° on OpenTX
    defaults.pitch_trim = { min = -300, max = 300, scale = 10, unit = "@" }
    defaults.roll_trim = { min = -300, max = 300, scale = 10, unit = "@" }
    return defaults
end

return {
    read = getAccTrim,
    write = setAccTrim,
    getDefaults = getDefaults
}