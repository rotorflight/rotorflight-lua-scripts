local adjTellerTask
local adjTellerEnabled = true
local customTelemetryTask
local crsfCustomTelemetryEnabled = false
local initTask, initResult

local function pilotConfigReset()
    model.setGlobalVariable(7, 8, 0)
end

local function run()
    if not initResult or not initResult.isInitialized then
        initTask = initTask or assert(rf2.loadScript(rf2.baseDir.."background_init.lua"))()
        initResult = initTask.run()
        if not initResult.isInitialized then
            return 0
        end
        adjTellerEnabled = true
        crsfCustomTelemetryEnabled = initResult.crsfCustomTelemetryEnabled
        initTask = nil
        collectgarbage()
    end

    if getRSSI() == 0 and not rf2.runningInSimulator then
        rf2.mspQueue:clear()
        rf2.apiVersion = nil
        adjTellerTask = nil
        customTelemetryTask = nil
        initResult = nil
        pilotConfigReset()
        collectgarbage()
        return 0
    end

    if adjTellerEnabled then
        adjTellerTask = adjTellerTask or assert(rf2.loadScript(rf2.baseDir.."adj_teller.lua"))()
        adjTellerEnabled = adjTellerTask.run() ~= 2
        if not adjTellerEnabled then
            adjTellerTask = nil
            collectgarbage()
        end
    end

    if crsfCustomTelemetryEnabled then
        customTelemetryTask = customTelemetryTask or assert(rf2.loadScript(rf2.baseDir.."rf2tlm.lua"))()
        customTelemetryTask.run()
    end

    --rf2.log("adjTellerEnabled:" .. tostring(adjTellerEnabled))
    --rf2.log("crsfCustomTelemetryEnabled:" .. tostring(crsfCustomTelemetryEnabled))

    return 0
end

local function runProtected()
    local status, err = pcall(run)
    if not status then rf2.print(err) end
end

return runProtected
