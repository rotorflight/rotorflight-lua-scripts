local SUPPORTED_API_VERSION = "12.06" -- see main/msp/msp_protocol.h

local mspApiVersion = assert(rf2.loadScript("/scripts/RF2/MSP/mspApiVersion.lua"))()
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
        if tostring(apiVersion) ~= SUPPORTED_API_VERSION then -- work-around for comparing floats
            returnTable.t = "This version of the Lua scripts ("..SUPPORTED_API_VERSION..")\ncan't be used with the selected model ("..tostring(apiVersion)..")."
        else
            -- received correct API version, proceed
            collectgarbage()
            return true
        end
    end

    return false
end

returnTable.f = init

return returnTable
