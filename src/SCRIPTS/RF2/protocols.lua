local function getProtocol()
    if sportTelemetryPush() ~= nil then
        return "sp"
    elseif crossfireTelemetryPush() ~= nil then
        return "crsf"
    elseif ghostTelemetryPush() ~= nil then
        return "ghst"
    end
end

local protocol = assert(getProtocol(), "Unsupported protocol!")

return protocol
