local function getFeatureConfig(callback, callbackParam)
    local message = {
        command = 36, -- MSP_FEATURE_CONFIG
        processReply = function(self, buf)
            local config = {}
            --rf2.print("buf length: "..#buf)
            config.bitfield = rf2.mspHelper.readU32(buf)
            callback(callbackParam, config)
        end,
        simulatorResponse = { 8, 4, 0, 124 }
    }
    rf2.mspQueue:add(message)
end

return {
    getFeatureConfig = getFeatureConfig,
    telemetryIsEnabled = function(bitfield)
        return bit32.btest(bitfield, 10)
    end
}
