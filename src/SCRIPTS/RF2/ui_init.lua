local apiVersionReceived = false
local vtxTablesReceived = false
local mcuIdReceived = false
local boardInfoReceived = false
local getApiVersion, getVtxTables, getMCUId, getBoardInfo
local returnTable = { f = nil, t = "" }
local SUPPORTED_API_VERSION = "12.01"

local function init()
    if runningInSimulator then return true end

    if getRSSI() == 0 then
        returnTable.t = "Waiting for connection"
    elseif not apiVersionReceived then
        getApiVersion = getApiVersion or assert(loadScript("api_version.lua"))()
        returnTable.t = getApiVersion.t
        apiVersionReceived = getApiVersion.f()
        if apiVersionReceived then
            getApiVersion = nil
            collectgarbage()
        end
    elseif tostring(apiVersion) ~= SUPPORTED_API_VERSION then -- work-around for comparing floats
        returnTable.t = "This version of the Lua\nscripts ("..SUPPORTED_API_VERSION..") can't be\nused with the selected\nmodel ("..tostring(apiVersion)..")."
--[[
    elseif not mcuIdReceived and apiVersion >= 1.42 then
        getMCUId = getMCUId or assert(loadScript("mcu_id.lua"))()
        returnTable.t = getMCUId.t
        mcuIdReceived = getMCUId.f()
        if mcuIdReceived then
            getMCUId = nil

            f = loadScript("VTX_TABLES/"..mcuId..".lua")
            if f and f() then
                vtxTablesReceived = true
                f = nil
            end
            collectgarbage()
            f = loadScript("BOARD_INFO/"..mcuId..".lua")
            if f and f() then
                boardInfoReceived = true
                f = nil
            end
            collectgarbage()
        end
--]]
--[[
    elseif not vtxTablesReceived and apiVersion >= 1.042 then
        getVtxTables = getVtxTables or assert(loadScript("vtx_tables.lua"))()
        returnTable.t = getVtxTables.t
        vtxTablesReceived = getVtxTables.f()
        if vtxTablesReceived then
            getVtxTables = nil
            collectgarbage()
        end
--]]
--[[
    elseif not boardInfoReceived and apiVersion >= 1.044 then
        getBoardInfo = getBoardInfo or assert(loadScript("board_info.lua"))()
        returnTable.t = getBoardInfo.t
        boardInfoReceived = getBoardInfo.f()
        if boardInfoReceived then
            getBoardInfo = nil
            collectgarbage()
        end
--]]
    else
        -- received correct API version, proceed
        return true
    end

    return false
end

returnTable.f = init

return returnTable
