local function getDefaults()
    local defaults = {}
    defaults.length = 0
    for i = 1, 16 do
        defaults[i] = { min = 0, max = 255 }
    end
    return defaults
end

local function getExperimental(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 158, -- MSP_EXPERIMENTAL
        processReply = function(self, buf)
            data.length = #buf
            for i = 1, data.length do
                data[i].value = rf2.mspHelper.readU8(buf)
            end
            callback(callbackParam)
        end,
        simulatorResponse = { 21, 10, 70 }
    }
    rf2.mspQueue:add(message)
end

local function setExperimental(data)
    local message = {
        command = 159, -- MSP_SET_EXPERIMENTAL
        payload = {}
    }
    for i = 1, data.length do
        rf2.mspHelper.writeU8(message.payload, data[i].value)
    end
    rf2.mspQueue:add(message)
end

return {
    read = getExperimental,
    write = setExperimental,
    getDefaults = getDefaults
}