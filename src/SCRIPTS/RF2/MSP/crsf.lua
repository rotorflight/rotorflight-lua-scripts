-- Usage: local mspSend, mspPoll, maxTxBufferSize, maxRxBufferSize = rf2.executeScript("MSP/csrf")

-- CRSF Devices
local CRSF_ADDRESS_BETAFLIGHT          = 0xC8
local CRSF_ADDRESS_RADIO_TRANSMITTER   = 0xEA

local function mspSend(payload)
    local payloadOut = { CRSF_ADDRESS_BETAFLIGHT, CRSF_ADDRESS_RADIO_TRANSMITTER }
    for i = 1, #(payload) do
        payloadOut[i+2] = payload[i]
    end
    local CRSF_FRAMETYPE_MSP_WRITE = 0x7C      -- write with 60 byte chunked binary
    return crossfireTelemetryPush(CRSF_FRAMETYPE_MSP_WRITE, payloadOut)
end

local function mspPoll()
    while true do
        local cmd, data = crossfireTelemetryPop()
        local CRSF_FRAMETYPE_MSP_RESP = 0x7B      -- reply with 60 byte chunked binary
        if cmd == CRSF_FRAMETYPE_MSP_RESP and data[1] == CRSF_ADDRESS_RADIO_TRANSMITTER and data[2] == CRSF_ADDRESS_BETAFLIGHT then
--[[
            rf2.print("cmd:0x"..string.format("%X", cmd))
            rf2.print("  data length: "..string.format("%u", #data))
            for i = 1,#data do
                rf2.print("  ["..string.format("%u", i).."]:  0x"..string.format("%X", data[i]))
            end
--]]
            local mspData = {}
            for i = 3, #data do
                mspData[i - 2] = data[i]
            end
            return mspData
        elseif cmd == nil then
            return nil
        end
    end
end

local maxTxBufferSize = 8
local maxRxBufferSize = 58
return mspSend, mspPoll, crossfireTelemetryPush, maxTxBufferSize, maxRxBufferSize
