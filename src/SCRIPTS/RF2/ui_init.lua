local mspApiVersion = assert(rf2.loadScript("MSP/mspApiVersion.lua"))()
local returnTable = { f = nil, t = "" }
local apiVersion
local lastRunTS

local function init()
    if getRSSI() == 0 and not rf2.runningInSimulator then
        returnTable.t = "Waiting for connection"
        return false
    end

    if not apiVersion and (not lastRunTS or lastRunTS + 2 < rf2.clock()) then
        returnTable.t = "Waiting for API version"
        mspApiVersion.getApiVersion(function(_, version) apiVersion = version end)
        lastRunTS = rf2.clock()
    end

    rf2.mspQueue:processQueue()

    if rf2.mspQueue:isProcessed() and apiVersion then
        local apiVersionAsString = string.format("%.2f", apiVersion)
        if apiVersion < 12.06 then
            returnTable.t = "This version of the Lua\nscripts can't be used\nwith the selected model\nwhich has version "..apiVersionAsString.."."
        else
            -- received correct API version, proceed
            rf2.apiVersion = apiVersion
            collectgarbage()
            return true
        end
    end

    return false
end

returnTable.f = init

return returnTable
