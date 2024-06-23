local function getApiVersion(callback, callbackParam)
    local message = {
        command = 1, -- MSP_API_VERSION
        processReply = function(self, buf)
            if #buf >= 3 then
                local version = buf[2] + buf[3] / 100
                callback(callbackParam, version)
            end
        end,
        simulatorResponse = { 0, 12, 6 }
    }
    rf2.mspQueue:add(message)
end

return {
    getApiVersion = getApiVersion
}