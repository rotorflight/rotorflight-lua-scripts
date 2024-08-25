local timeIsSet = rf2.runningInSimulator
local mspSetRtc, adjTellerTask
local adjTellerEnabled = true

local function onRtcSet()
    timeIsSet = true
    playTone(1600, 500, 0, PLAY_BACKGROUND)
    mspSetRtc = nil
    collectgarbage()
end

local function run_bg()
    if getRSSI() == 0 and not rf2.runningInSimulator then
        timeIsSet = false
        adjTellerEnabled = true
        if mspSetRtc or adjTellerTask then
            mspSetRtc = nil
            adjTellerTask = nil
            collectgarbage()
        end
        return
    end

    if not rf2.runningInSimulator and not timeIsSet and rf2.mspQueue:isProcessed() then
        mspSetRtc = mspSetRtc or assert(rf2.loadScript(rf2.baseDir.."MSP/mspSetRtc.lua"))()
        mspSetRtc.setRtc(onRtcSet)
    end

    rf2.mspQueue:processQueue()

    if timeIsSet and adjTellerEnabled then
        adjTellerTask = adjTellerTask or assert(rf2.loadScript(rf2.baseDir.."adj_teller.lua"))()
        adjTellerEnabled = adjTellerTask.run()
        if adjTellerEnabled == 2 then
            adjTellerTask = nil
            collectgarbage()
            return 2
        end
    end

    return 0
end

return run_bg
