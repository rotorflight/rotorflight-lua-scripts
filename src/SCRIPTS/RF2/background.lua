local timeIsSet = rf2.runningInSimulator
local mspApiVersion, mspSetRtc, mspPilotConfig, adjTellerTask
local adjTellerEnabled = true
local pilotConfigSetMagic = -765

local function onApiVersionReceived(_, version)
    playTone(1600, 300, 0, PLAY_BACKGROUND)
    rf2.apiVersion = version
    mspApiVersion = nil
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
    playTone(1800, 300, 0, PLAY_BACKGROUND)

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

local function onRtcSet()
    playTone(2000, 300, 0, PLAY_BACKGROUND)
    timeIsSet = true
    mspSetRtc = nil
    collectgarbage()
end

local function run_bg()
    if getRSSI() == 0 and not rf2.runningInSimulator then
        playTone(800, 20, 0, PLAY_BACKGROUND)
        rf2.apiVersion = nil
        timeIsSet = false
        pilotConfigReset()
        adjTellerEnabled = true
        if mspApiVersion or mspPilotConfig or mspSetRtc or adjTellerTask then
            mspApiVersion, mspPilotConfig, mspSetRtc, adjTellerTask = nil, nil, nil, nil
            collectgarbage()
        end
        return 0
    end

    rf2.mspQueue:processQueue()

    if not rf2.apiVersion then
        if rf2.mspQueue:isProcessed() then
            mspApiVersion = mspApiVersion or assert(rf2.loadScript(rf2.baseDir.."MSP/mspApiVersion.lua"))()
            mspApiVersion.getApiVersion(onApiVersionReceived)
        end
        return 0
    end

    if rf2.apiVersion >= 12.07 and not pilotConfigHasBeenSet() then
        if rf2.mspQueue:isProcessed() then
            mspPilotConfig = mspPilotConfig or assert(rf2.loadScript(rf2.baseDir.."MSP/mspPilotConfig.lua"))()
            mspPilotConfig.getPilotConfig(onPilotConfigReceived)
        end
        return 0
    end

    if not timeIsSet then
        if rf2.mspQueue:isProcessed() then
            mspSetRtc = mspSetRtc or assert(rf2.loadScript(rf2.baseDir.."MSP/mspSetRtc.lua"))()
            mspSetRtc.setRtc(onRtcSet)
        end
        return 0
    end

    if adjTellerEnabled then
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
