local apiVersionReceived = runningInSimulator
local timeIsSet = runningInSimulator
local getApiVersion, setRtc, adjTellerTask
local adjTellerEnabled = true

local function run_bg()
    if getRSSI() > 0 or runningInSimulator then
        -- Send data when the telemetry connection is available
        -- assuming when sensor value higher than 0 there is an telemetry connection
        if not apiVersionReceived then
            getApiVersion = getApiVersion or assert(loadScript(rfBaseDir.."api_version.lua"))()
            apiVersionReceived = getApiVersion.f()
            if apiVersionReceived then
                getApiVersion = nil
                collectgarbage()
            end
        elseif not timeIsSet then
            setRtc = setRtc or assert(loadScript(rfBaseDir.."rtc.lua"))()
            timeIsSet = setRtc.f()
            if timeIsSet then
                setRtc = nil
                collectgarbage()
            end
        elseif adjTellerEnabled and protocol.mspTransport == "MSP/sp.lua" then
            adjTellerTask = adjTellerTask or assert(loadScript(rfBaseDir.."adj_teller.lua"))()
            adjTellerEnabled = adjTellerTask.run()
            if adjTellerEnabled == 2 then
                adjTellerTask = nil
                collectgarbage()
                return 2
            end
        end
    else
        apiVersionReceived = false
        timeIsSet = false
        adjTellerEnabled = true
        if getApiVersion or setRtc or adjTellerTask then
            getApiVersion = nil
            setRtc = nil
            adjTellerTask = nil
            collectgarbage()
        end
    end

    return 0
end

return run_bg
