local initTask = nil
local adjTellerTask = nil
local customTelemetryTask = nil
local isInitialized = false
local modelIsConnected = false
local lastTimeRssi = nil

local settingsHelper = assert(rf2.loadScript(rf2.baseDir.."PAGES/helpers/settingsHelper.lua"))()
local useAdjustmentTeller = settingsHelper.loadSettings().useAdjustmentTeller == 1 or false
settingsHelper = nil

local function pilotConfigReset()
    model.setGlobalVariable(7, 8, 0)
end

local function run()
    if rf2.runningInSimulator then
        modelIsConnected = true
    elseif getRSSI() > 0 then
        lastTimeRssi = rf2.clock()
        modelIsConnected = true
    elseif getRSSI() == 0 and modelIsConnected then
        if lastTimeRssi and rf2.clock() - lastTimeRssi < 10 then
            -- Do not re-initialise if the RSSI is 0 for less than 10 seconds.
            -- This is also a work-around for https://github.com/ExpressLRS/ExpressLRS/issues/3207 (AUX channel bug in ELRS TX < 3.5.5)
            return
        end
        if initTask then
            initTask.reset()
            initTask = nil
        end
        adjTellerTask = nil
        customTelemetryTask = nil
        modelIsConnected = false
        pilotConfigReset()
        isInitialized = false
        collectgarbage()
    end

    if not isInitialized then
        initTask = initTask or assert(rf2.loadScript(rf2.baseDir.."background_init.lua"))()
        local initTaskResult = initTask.run(modelIsConnected)
        if not initTaskResult.isInitialized then
            --rf2.print("Not initialized yet")
            return
        end
        if initTaskResult.crsfCustomTelemetryEnabled then
            customTelemetryTask = assert(rf2.loadScript(rf2.baseDir.."rf2tlm.lua"))()
        end
        if useAdjustmentTeller then
            adjTellerTask = assert(rf2.loadScript(rf2.baseDir.."adj_teller.lua"))()
        end
        initTask = nil
        collectgarbage()
        isInitialized = true
    end

    if getRSSI() == 0 and not rf2.runningInSimulator then
        return
    end

    if adjTellerTask and adjTellerTask.run() == 2  then
        -- no adjustment sensors found
        adjTellerTask = nil
        collectgarbage()
    end

    if customTelemetryTask then
        customTelemetryTask.run()
    end
end

local function runProtected()
    local status, err = pcall(run)
    --if not status then rf2.print(err) end
    return 0
end

return runProtected
