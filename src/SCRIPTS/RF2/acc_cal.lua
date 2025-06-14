local mspAccCalibration = rf2.useApi("mspAccCalibration")
local sentCalibrate = false

local function calibrate()
    if not sentCalibrate then
        mspAccCalibration.calibrate()
        sentCalibrate = true
    end

    rf2.mspQueue:processQueue()

    return rf2.mspQueue:isProcessed()
end

return { f = calibrate, t = "Calibrating Accelerometer" }
