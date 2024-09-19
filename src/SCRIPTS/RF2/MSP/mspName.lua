local function getText(array, start, maxLength)
    local text = ""
    for i = start, start + maxLength - 1 do
        local v = array[i]
        if v == 0 then break end
        text = text..string.char(v)
    end
    return text
end

local function getModelName(callback, callbackParam)
    local message = {
        command = 10, -- MSP_NAME
        processReply = function(self, buf)
            local name = getText(buf, 1, #buf)
            callback(callbackParam, name)
        end,
        simulatorResponse = { 83, 49 }
    }
    rf2.mspQueue:add(message)
end

local function setText(text, array)
    for i = 1, #text do
        local char = string.sub(text, i, i)
        array[#array + 1] = string.byte(char)
    end
end

local function setModelName(name)
    local message = {
        command = 11, -- MSP_SET_NAME
        payload = {},
        simulatorResponse = {}
    }
    setText(name, message.payload)
    rf2.mspQueue:add(message)
end

return {
    getModelName = getModelName,
    setModelName = setModelName,
}