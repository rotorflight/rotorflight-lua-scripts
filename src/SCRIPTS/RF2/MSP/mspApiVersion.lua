local function getApiVersion(callback, callbackParam)
    local message = {
        command = 1, -- MSP_API_VERSION
        processReply = function(self, buf)
            if #buf >= 3 then
                local version = buf[2] + buf[3] / 100 + 0.00001
                callback(callbackParam, version)
            end
        end,
        simulatorResponse = { 0, 12, 8 }
    }
    rf2.mspQueue:add(message)
end

return {
    getApiVersion = getApiVersion
}