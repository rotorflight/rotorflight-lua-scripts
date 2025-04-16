local initTask = nil
local adjTellerTask = nil
local customTelemetryTask = nil
local isInitialized = false
local modelIsConnected = false

local function run()
    if rf2.runningInSimulator then
        modelIsConnected = true
    elseif getRSSI() > 0 and not modelIsConnected then
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
        adjTellerTask = assert(rf2.loadScript(rf2.baseDir.."adj_teller.lua"))()
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
