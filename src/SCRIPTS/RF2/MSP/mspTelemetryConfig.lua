local function getTelemetryConfig(callback, callbackParam)
    local message = {
        command = 73, -- MSP_TELEMETRY_CONFIG
        processReply = function(self, buf)
            local config = {}
            --rf2.print("buf length: "..#buf)
            local offOnTable = { [0] = "OFF", "ON" }
            config.telemetry_inverted = { value = rf2.mspHelper.readU8(buf), min = 0, max = 1, table = offOnTable }
            config.telemetry_halfduplex = { value = rf2.mspHelper.readU8(buf), min = 0, max = 1, table = offOnTable }
            config.telemetry_sensors = { value = rf2.mspHelper.readU32(buf), min }
            if rf2.apiVersion >= 12.07 then
                config.telemetry_pinswap = { value = rf2.mspHelper.readU8(buf), min = 0, max = 1, table = offOnTable }
                config.crsf_telemetry_mode = { value = rf2.mspHelper.readU8(buf), min = 0, max = 1, table = { [0] = "NATIVE", "CUSTOM" } }
                config.crsf_telemetry_rate = { value = rf2.mspHelper.readU16(buf), min = 0, max = 50000 }
                config.crsf_telemetry_ratio = { value = rf2.mspHelper.readU16(buf), min = 0, max = 50000 }
                config.crsf_telemetry_sensors = {}
                for i = 1, 40 do
                    config.crsf_telemetry_sensors[i] = rf2.mspHelper.readU8(buf)
                end
            end

            callback(callbackParam, config)
        end,
        simulatorResponse = {
            0, -- telemetry_inverted
            1, -- telemetry_halfduplex
            15, 0, 22, 0, -- telemetry_sensors
            0, -- telemetry_pinswap
            1, -- crsf_telemetry_mode
            500, 0, -- crsf_telemetry_rate
            8, 0, -- crsf_telemetry_ratio

            -- crsf_telemetry_sensors
            60, -- Hspd
            3,  -- Vbat
            4,  -- Curr
            5,
            0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    }
    rf2.mspQueue:add(message)
end

return {
    getTelemetryConfig = getTelemetryConfig
}
