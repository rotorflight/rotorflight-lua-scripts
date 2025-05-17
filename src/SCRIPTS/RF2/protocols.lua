local supportedProtocols =
{
    smartPort =
    {
        mspTransport    = "MSP/sp.lua",
        push            = sportTelemetryPush,
        maxTxBufferSize = 6,
        maxRxBufferSize = 6,
        maxRetries      = 3,
        saveTimeout     = 5.0,
    },
    crsf =
    {
        mspTransport    = "MSP/crsf.lua",
        push            = crossfireTelemetryPush,
        maxTxBufferSize = 8,
        maxRxBufferSize = 58,
        maxRetries      = 3,
        saveTimeout     = 4.0,
    },
    ghst =
    {
        mspTransport    = "MSP/ghst.lua",
        push            = ghostTelemetryPush,
        maxTxBufferSize = 10, -- Tx -> Rx (Push)
        maxRxBufferSize = 6,  -- Rx -> Tx (Pop)
        maxRetries      = 3,
        saveTimeout     = 4.0,
    }
}

local function getProtocol()
    if supportedProtocols.smartPort.push() ~= nil then
        return supportedProtocols.smartPort
    elseif supportedProtocols.crsf.push() ~= nil then
        return supportedProtocols.crsf
    elseif supportedProtocols.ghst.push() ~= nil then
        return supportedProtocols.ghst
    end
end

local protocol = assert(getProtocol(), "Telemetry protocol\n     not supported!")

return protocol
