local function mspSend(payload)
    return ghostTelemetryPush(0, payload)
end

local function mspPoll ()
    local GHST_FRAMETYPE_MSP_RESP = 0x28
    while true do
        local type, data = ghostTelemetryPop()
        if type == GHST_FRAMETYPE_MSP_RESP then
            return data
        elseif type == nil then
            return nil
        end
    end
end

local maxTxBufferSize = 10
local maxRxBufferSize = 6
return mspSend, mspPoll, ghostTelemetryPush, maxTxBufferSize, maxRxBufferSize
