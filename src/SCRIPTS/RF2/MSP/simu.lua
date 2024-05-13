-- simulator Devices

protocol.mspSend = function(payload)
    local payloadOut = { CRSF_ADDRESS_BETAFLIGHT, CRSF_ADDRESS_RADIO_TRANSMITTER }
    for i=1, #(payload) do
        payloadOut[i+2] = payload[i]
    end
    return protocol.push(crsfMspCmd, payloadOut)
end

protocol.mspRead = function(cmd)
    crsfMspCmd = CRSF_FRAMETYPE_MSP_REQ
    return mspSendRequest(cmd, {})
end

protocol.mspWrite = function(cmd, payload)
    crsfMspCmd = CRSF_FRAMETYPE_MSP_WRITE
    return mspSendRequest(cmd, payload)
end

protocol.mspPoll = function()
    return nil
    -- while true do
    --     local cmd, data = crossfireTelemetryPop()
    --     if cmd == CRSF_FRAMETYPE_MSP_RESP and data[1] == CRSF_ADDRESS_RADIO_TRANSMITTER and data[2] == CRSF_ADDRESS_BETAFLIGHT then
    --         local mspData = {}
    --         for i = 3, #data do
    --             mspData[i - 2] = data[i]
    --         end
    --         return mspData
    --     elseif cmd == nil then
    --         return nil
    --     end
    -- end
end
