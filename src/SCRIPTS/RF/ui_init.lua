local apiVersionReceived = false
local mcuIdReceived = false
local boardInfoReceived = false
local getApiVersion, getVtxTables, getMCUId, getBoardInfo, f
local returnTable = { f = nil, t = "" }

local function init()
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
    elseif not mcuIdReceived and apiVersion >= 1.042 then
        getMCUId = getMCUId or assert(loadScript("mcu_id.lua"))()
        returnTable.t = getMCUId.t
        mcuIdReceived = getMCUId.f()
        if mcuIdReceived then
            getMCUId = nil
--[[
            f = loadScript("VTX_TABLES/"..mcuId..".lua")
            if f and f() then
                vtxTablesReceived = true
                f = nil
            end
            collectgarbage()
--]]
            f = loadScript("BOARD_INFO/"..mcuId..".lua")
            if f and f() then
                boardInfoReceived = true
                f = nil
            end
            collectgarbage()
        end
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
    elseif not boardInfoReceived then
        getBoardInfo = getBoardInfo or assert(loadScript("board_info.lua"))()
        returnTable.t = getBoardInfo.t
        boardInfoReceived = getBoardInfo.f()
        if boardInfoReceived then
            getBoardInfo = nil
            collectgarbage()
        end
--]]
    else
        return true
    end
    --return apiVersionReceived and vtxTablesReceived and mcuId and boardInfoReceived
    --return apiVersionReceived and mcuId and boardInfoReceived
    return apiVersionReceived and mcuId
end

returnTable.f = init

return returnTable
