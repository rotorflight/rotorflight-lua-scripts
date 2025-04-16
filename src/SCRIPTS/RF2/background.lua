local initTask = nil
local adjTellerTask = nil
local customTelemetryTask = nil
local isInitialized = false
local modelIsConnected = false

local function run()
    if getRSSI() > 0 and not modelIsConnected then
        modelIsConnected = true
    elseif getRSSI() == 0 and modelIsConnected then
        if initTask then
            initTask.reset()
            initTask = nil
        end
        adjTellerTask = nil
        customTelemetryTask = nil
        modelIsConnected = false
        isInitialized = false
        collectgarbage()
    elseif getRSSI() == 0 and not modelIsConnected then
        rf2.log("bg waiting for rssi")
        return 0
    end

    -- rf2.log("bg rssi: %s, crossfireTelemetryPush: %s", getRSSI(), crossfireTelemetryPush())

    if not isInitialized then
        rf2.log("bg not initialized, running background_init.lua")
        initTask = initTask or assert(rf2.loadScript("background_init.lua"))()
        local initTaskResult = initTask.run(modelIsConnected)
        if not initTaskResult.isInitialized then
            --rf2.print("Not initialized yet")
            return 0
        end
        rf2.log("bg initTaskResult.crsfCustomTelemetryEnabled: %s", initTaskResult.crsfCustomTelemetryEnabled)
        if initTaskResult.crsfCustomTelemetryEnabled then
            customTelemetryTask = assert(rf2.loadScript("rf2tlm.lua"))(initTaskResult.crsf_telemetry_sensors)
        end
        adjTellerTask = assert(rf2.loadScript("adj_teller.lua"))()
        initTask = nil
        collectgarbage()
        isInitialized = true
        rf2.log("bg initialized")
    end

    if getRSSI() == 0 then
        return 0
    end

    if adjTellerTask and adjTellerTask.run() == 2  then
        -- no adjustment sensors found
        adjTellerTask = nil
        collectgarbage()
    end

    if customTelemetryTask then
        customTelemetryTask.run()
    end

    return 0
end

local function runProtected()
    local status, err = pcall(run)
    --if not status then rf2.print(err) end
    return isInitialized
end

return runProtected
