local timeIsSet = rf2.runningInSimulator
local nameIsSet = false
local mspApiVersion, mspSetRtc, mspName, mspPilotConfig, adjTellerTask
local adjTellerEnabled = true
local pilotConfigSetMagic = -765
local sensorsDiscoveredTimeout = 0

local settingsHelper = assert(rf2.loadScript(rf2.baseDir.."PAGES/helpers/settingsHelper.lua"))()
local autoSetName = settingsHelper.loadSettings().autoSetName == 1 or false
settingsHelper = nil

local function onApiVersionReceived(_, version)
    playTone(1600, 300, 0, PLAY_BACKGROUND)
    rf2.apiVersion = version
    mspApiVersion = nil
    collectgarbage()
end

local function onModelNameReceived(_, name)
    --playTone(1800, 100, 0, PLAY_BACKGROUND)
    local info = model.getInfo()
    info.name = name
    model.setInfo(info)
    nameIsSet = true
    mspName = nil
    collectgarbage()
end

local function onRtcSet()
    --playTone(2000, 100, 0, PLAY_BACKGROUND)
    timeIsSet = true
    mspSetRtc = nil
    collectgarbage()
end

local function pilotConfigSet()
    model.setGlobalVariable(7, 8, pilotConfigSetMagic)
end

local function pilotConfigReset()
    model.setGlobalVariable(7, 8, 0)
end

local function pilotConfigHasBeenSet()
    return model.getGlobalVariable(7, 8) == pilotConfigSetMagic
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
    elseif paramType == "GV9" then
        model.setGlobalVariable(8, 0, paramValue)
    end
end

local function onPilotConfigReceived(_, config)
    --playTone(2133, 200, 0, PLAY_BACKGROUND)

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

local function waitForCustomSensorsDiscovery()
    -- OpenTX and EdgeTX reference sensors by their ID. In order to always have the
    -- same ID when using custom CRSF/ELRS telemetry, follow this procedure:
    -- 1. Power off the model
    -- 2. "Delete all" sensors from the model
    -- 3. Select "Discover new"
    -- 4. Power on the model
    -- 5. Wait for the sensors to be discovered.
    -- MSP calls during this procedure can interfere with discovering custom sensors.
    -- waitForCustomSensorsDiscovery facilitates waiting for the sensors to be discovered
    -- before continuing with MSP calls.

    if not crossfireTelemetryPush() or rf2.runningInSimulator then
        -- Model does not use CRSF/ELRS
        return 0
    end

    local sensorsDiscovered
    if getFieldInfo ~= nil then
        -- EdgeTX
        sensorsDiscovered = getFieldInfo("TPWR") ~= nil
    else
        -- OpenTX
        sensorsDiscovered = getValue("TPWR") ~= nil
    end

    if not sensorsDiscovered then
        -- Wait 10 secs for telemetry script to discover sensors before continuing with MSP calls,
        -- since MSP can interfere with discovering custom sensors
        sensorsDiscoveredTimeout = rf2.clock() + 10
    end

    if sensorsDiscoveredTimeout ~= 0 then
        if rf2.clock() < sensorsDiscoveredTimeout then
            --rf2.print("Waiting for sensors to be discovered...")
            return 1 -- wait for sensors to be discovered
        end
        sensorsDiscoveredTimeout = 0
        return 2 -- sensors might just have been discovered
    end

    return 0
end

local function run_bg()
    local sensorsDiscoveryWaitState = waitForCustomSensorsDiscovery()
    if sensorsDiscoveryWaitState == 1 then
        return 0
    end

    if (sensorsDiscoveryWaitState == 2 or getRSSI() == 0) and not rf2.runningInSimulator then
        --playTone(800, 20, 0, PLAY_BACKGROUND)
        rf2.mspQueue:clear()
        rf2.apiVersion = nil
        timeIsSet, nameIsSet = false, false
        pilotConfigReset()
        adjTellerEnabled = true
        if mspApiVersion or mspName or mspPilotConfig or mspSetRtc or adjTellerTask then
            mspApiVersion, mspName, mspPilotConfig, mspSetRtc, adjTellerTask = nil, nil, nil, nil, nil
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

    if autoSetName and not nameIsSet then
        if rf2.mspQueue:isProcessed() then
            mspName = mspName or assert(rf2.loadScript(rf2.baseDir.."MSP/mspName.lua"))()
            mspName.getModelName(onModelNameReceived)
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

    if rf2.apiVersion >= 12.07 and not pilotConfigHasBeenSet() then
        if rf2.mspQueue:isProcessed() then
            mspPilotConfig = mspPilotConfig or assert(rf2.loadScript(rf2.baseDir.."MSP/mspPilotConfig.lua"))()
            mspPilotConfig.getPilotConfig(onPilotConfigReceived)
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

local function run_protected()
    local status, err = pcall(run_bg)
    if not status then rf2.print(err) end
end

return run_protected
