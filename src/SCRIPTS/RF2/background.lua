local initTask = nil
local adjTellerTask = nil
local customTelemetryTask = nil
local isInitialized = false
local modelIsConnected = false
local lastTimeRssi = nil

local function pilotConfigReset()
    model.setGlobalVariable(7, 8, 0)
end

local function pilotConfigHasBeenReset()
    return model.getGlobalVariable(7, 8) == 0
end

local function run()
    if rf2.runningInSimulator then
        modelIsConnected = true
    elseif getRSSI() > 0 then
        lastTimeRssi = rf2.clock()
        modelIsConnected = true
        if isInitialized and pilotConfigHasBeenReset() then
            -- Since EdgeTX 2.11 the background script will resume execution instead of starting it again after running a tool.
            isInitialized = false
        end
    elseif getRSSI() == 0 then
        if lastTimeRssi and rf2.clock() - lastTimeRssi < 5 then
            -- Do not re-initialise if the RSSI is 0 for less than 5 seconds.
            -- This is also a work-around for https://github.com/ExpressLRS/ExpressLRS/issues/3207 (AUX channel bug in ELRS TX < 3.5.5)
            return
        end
        pilotConfigReset()
        if modelIsConnected then
            if initTask then
                initTask.reset()
                initTask = nil
            end
            adjTellerTask = nil
            customTelemetryTask = nil
            modelIsConnected = false
            isInitialized = false
            collectgarbage()
        end
    end

    if not isInitialized then
        initTask = initTask or rf2.executeScript("background_init")
        local initTaskResult = initTask.run(modelIsConnected)
        if not initTaskResult.isInitialized then
            --rf2.print("Not initialized yet")
            return
        end
        if initTaskResult.crsfCustomTelemetryEnabled then
            customTelemetryTask = rf2.executeScript("rf2tlm")
        end
        if initTask.useAdjustmentTeller then
            adjTellerTask = rf2.executeScript("adj_teller")
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
