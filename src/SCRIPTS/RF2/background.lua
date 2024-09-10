local timeIsSet = rf2.runningInSimulator
local mspSetRtc, mspPilotConfig, adjTellerTask
local adjTellerEnabled = true
local pilotConfigSetMagic = -765

local function onRtcSet()
    timeIsSet = true
    playTone(1600, 250, 0, PLAY_BACKGROUND)
    mspSetRtc = nil
    collectgarbage()
end

local function pilotConfigSet()
    model.setGlobalVariable(8, 8, pilotConfigSetMagic)
end

local function pilotConfigReset()
    model.setGlobalVariable(8, 8, 0)
end

local function pilotConfigHasBeenSet()
    return model.getGlobalVariable(8, 8) == pilotConfigSetMagic
end

local function setTimer(index, paramValue)
    local timer = model.getTimer(index)
    timer.value = paramValue
    model.setTimer(index, timer)
end

local function setParam(paramType, paramValue)
    --rf2.print(paramType .. ": " .. paramValue)
    if paramType == "NONE" then return end
    if paramType == "TIMER1" then
        setTimer(0, paramValue)
    elseif paramType == "TIMER2" then
        setTimer(1, paramValue)
    elseif paramType == "TIMER3" then
        setTimer(2, paramValue)
    elseif paramType == "GV1" then
        model.setGlobalVariable(0, 0, paramValue)
    elseif paramType == "GV2" then
        model.setGlobalVariable(1, 0, paramValue)
    elseif paramType == "GV3" then
        model.setGlobalVariable(2, 0, paramValue)
    elseif paramType == "GV4" then
        model.setGlobalVariable(3, 0, paramValue)
    elseif paramType == "GV5" then
        model.setGlobalVariable(4, 0, paramValue)
    elseif paramType == "GV6" then
        model.setGlobalVariable(5, 0, paramValue)
    elseif paramType == "GV7" then
        model.setGlobalVariable(6, 0, paramValue)
    elseif paramType == "GV8" then
        model.setGlobalVariable(7, 0, paramValue)
    end
end

local function onPilotConfigReceived(_, config)
    playTone(2400, 500, 0, PLAY_BACKGROUND)

    local paramValue = config.model_param1_value.value
    local paramType = config.model_param1_type.table[config.model_param1_type.value]
    setParam(paramType, paramValue)

    paramValue = config.model_param2_value.value
    paramType = config.model_param2_type.table[config.model_param2_type.value]
    setParam(paramType, paramValue)

    paramValue = config.model_param3_value.value
    paramType = config.model_param3_type.table[config.model_param3_type.value]
    setParam(paramType, paramValue)

    mspPilotConfig = nil
    collectgarbage()
    pilotConfigSet()
end

local function run_bg()
    if getRSSI() == 0 and not rf2.runningInSimulator then
        timeIsSet = false
        pilotConfigReset()
        adjTellerEnabled = true
        if mspSetRtc or adjTellerTask then
            mspSetRtc = nil
            adjTellerTask = nil
            collectgarbage()
        end
        return
    end

    rf2.mspQueue:processQueue()

    if not rf2.runningInSimulator and not timeIsSet and rf2.mspQueue:isProcessed() then
        mspSetRtc = mspSetRtc or assert(rf2.loadScript(rf2.baseDir.."MSP/mspSetRtc.lua"))()
        mspSetRtc.setRtc(onRtcSet)
    end

    if timeIsSet and not pilotConfigHasBeenSet() and rf2.mspQueue:isProcessed() then
        mspPilotConfig = mspPilotConfig or assert(rf2.loadScript(rf2.baseDir.."MSP/mspPilotConfig.lua"))()
        mspPilotConfig.getPilotConfig(onPilotConfigReceived)
    end

    if pilotConfigHasBeenSet() and adjTellerEnabled then
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
