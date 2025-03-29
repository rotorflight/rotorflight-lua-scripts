local function calibrate(callback, callbackParam)
    local message =
    {
        command = 205, -- MSP_ACC_CALIBRATION
        processReply = function(self, buf)
            --rf2.print("Accelerometer calibrated.")
            if callback then callback(callbackParam) end
        end,
        simulatorResponse = {}
    }
    rf2.mspQueue:add(message)
end

return {
    calibrate = calibrate
}