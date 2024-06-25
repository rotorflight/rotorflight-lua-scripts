local timeIsSet = rf2.runningInSimulator
local setRtc, adjTellerTask
local adjTellerEnabled = true

local function run_bg()
    if getRSSI() > 0 or rf2.runningInSimulator then
        if not timeIsSet then
            setRtc = setRtc or assert(rf2.loadScript(rf2.baseDir.."rtc.lua"))()
            timeIsSet = setRtc.f()
            if timeIsSet then
                setRtc = nil
                collectgarbage()
            end
        elseif adjTellerEnabled then
            adjTellerTask = adjTellerTask or assert(rf2.loadScript(rf2.baseDir.."adj_teller.lua"))()
            adjTellerEnabled = adjTellerTask.run()
            if adjTellerEnabled == 2 then
                adjTellerTask = nil
                collectgarbage()
                return 2
            end
        end
    else
        timeIsSet = false
        adjTellerEnabled = true
        if setRtc or adjTellerTask then
            setRtc = nil
            adjTellerTask = nil
            collectgarbage()
        end
    end

    return 0
end

return run_bg
