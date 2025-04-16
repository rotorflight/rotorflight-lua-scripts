local function getStatus(callback, callbackParam)
    local message = {
        command = 101, -- MSP_STATUS
        processReply = function(self, buf)
            local status = {}
            --status.pidCycleTime       = rf2.mspHelper.readU16(buf, 1)   -- PID task delta time
            --status.gyroCycleTime      = rf2.mspHelper.readU16(buf, 3)   -- Gyro task delta time
            --status.sensorStatus       = rf2.mspHelper.readU16(buf, 5)   -- Sensor status
            status.flightModeFlags      = rf2.mspHelper.readU32(buf, 7)   -- Flight mode flags
            --status.profileNumber      = rf2.mspHelper.readU8 (buf, 11)  -- Profile number (compatibility)
            status.realTimeLoad         = rf2.mspHelper.readU16(buf, 12)  -- Maximum real-time load
            status.cpuLoad              = rf2.mspHelper.readU16(buf, 14)  -- Average CPU load
            --status.fModeFlagsCount    = rf2.mspHelper.readU8 (buf, 16)  -- Extra flight mode flags count (compatibility)
            --status.armDisableFCount   = rf2.mspHelper.readU8 (buf, 17)  -- Arming disable flags count
            status.armingDisableFlags   = rf2.mspHelper.readU32(buf, 18)  -- Arming disable flags
            --status.rebootRequired     = rf2.mspHelper.readU8 (buf, 22)  -- Reboot required
            --status.configurationState = rf2.mspHelper.readU8 (buf, 23)  -- Configuration state
            status.profile              = rf2.mspHelper.readU8 (buf, 24)  -- current PID profile index
            status.numProfiles          = rf2.mspHelper.readU8 (buf, 25)  -- PID profile count
            status.rateProfile          = rf2.mspHelper.readU8 (buf, 26)  -- rate profile current index
            --status.numRateProfiles    = rf2.mspHelper.readU8 (buf, 27)  -- rate profile count
            --status.motorCount         = rf2.mspHelper.readU8 (buf, 28)  -- Motor count
            --status.servoCount         = rf2.mspHelper.readU8 (buf, 29)  -- Gyro detection flags

            --rf2.print("msp flightModeFlags: "..tostring(status.flightModeFlags))
            --rf2.print("Real-time load: "..tostring(status.realTimeLoad))
            --rf2.print("CPU load: "..tostring(status.cpuLoad))
            --rf2.print("Arming disable flags: "..tostring(status.armingDisableFlags))
            --rf2.print("Profile: "..tostring(status.profile+1))
            --rf2.print("rateProfile: "..tostring(status.rateProfile+1))
            callback(callbackParam, status)
        end,
        simulatorResponse = {
            240, 1, 124, 0, -- Header
            0,0,            -- Sensor status
            35, 0, 0, 0,    -- flightModeFlags
            0,              -- old
            224, 1,         -- realTimeLoad (0x01E0)
            10, 1,          -- cpuLoad (0x010A)
            0,              -- Extra flight mode flags count (compatibility)
            0,              -- Arming disable flags count
            0x00, 0, 0, 0,  -- armingDisableFlags (0x84 thr & no receiver)
            0,              -- reboot required  22
            6,              -- Configuration state
            1,              -- current PID profile index(bank) 24
            6,              -- PID profile count
            2,              -- rate profile current index
            4,              -- rate profile count
            0,              -- Motor count
            1,              -- Gyro detection flags
        }
    }

    rf2.mspQueue:add(message)
end

return {
    getStatus = getStatus
}