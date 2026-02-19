local initTask = nil
local adjTellerTask = nil
local customTelemetryTask = nil
local isInitialized = false
local modelIsConnected = false
local lastTimeRssi = nil

local function pilotConfigHasBeenReset()
    return model.getGlobalVariable(7, 8) == 0
end

local hasSensor = rf2.executeScript("F/hasSensor")

local function setState(widget, state)
    if widget == nil then return end
    widget:setState(state)
end

--local lastHelloTime = nil
local function run(widget)
    -- if lastHelloTime == nil or rf2.clock() - lastHelloTime > 1 then
    --     rf2.print("Background says hello!")
    --     lastHelloTime = rf2.clock()
    -- end

    if isInitialized and customTelemetryTask and not hasSensor("*Cnt") then
        isInitialized = false -- user probably deleted all sensors on TX
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
            setState(widget, "sensor lost")
            return
        end
        if modelIsConnected then
            rf2.executeScript("F/pilotConfigReset")()
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
        adjTellerTask = nil
        customTelemetryTask = nil
        collectgarbage()
        initTask = initTask or rf2.executeScript("background_init")
        local initTaskResult = initTask.run(modelIsConnected)
        if not initTaskResult.isInitialized then
            --rf2.print("Not initialized yet")
            if getRSSI() == 0 then
                setState(widget, "disconnected")
            else
                setState(widget, "initializing")
            end
            return
        end
        if initTaskResult.crsfCustomTelemetryEnabled then
            local requestedSensorsBySid = rf2.executeScript("rf2tlm_sensors", initTaskResult.crsfCustomTelemetrySensors)
            customTelemetryTask = rf2.executeScript("rf2tlm", requestedSensorsBySid)
        end
        if initTask.useAdjustmentTeller then
            adjTellerTask = rf2.executeScript("adj_teller")
        end
        initTask = nil
        isInitialized = true
        setState(widget, "connected")
    end

    if getRSSI() == 0 and not rf2.runningInSimulator then
        return
    end

    if adjTellerTask and adjTellerTask.run() == 2  then
        -- no adjustment sensors found
        adjTellerTask = nil
    end

    if customTelemetryTask then
        customTelemetryTask.run()
    end
end

-- widget is optional and will be provided by the RfTool widget. 
-- If the background script runs as a special function, widget will be nil.
local function runProtected(widget)
    local status, err = pcall(run, widget)
    --[NIR
    if not status then rf2.print(err) end
    --]]
    --collectgarbage()
    --rf2.print("Mem: %d", collectgarbage("count")*1024)
    return 0
end

return runProtected
