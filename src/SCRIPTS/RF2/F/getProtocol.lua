-- Usage: local protocol = rf2.executeScript("F/getProtocol")()
local function getProtocol()
    if sportTelemetryPush() ~= nil then
        return "sp"
    elseif crossfireTelemetryPush() ~= nil then
        return "crsf"
    elseif ghostTelemetryPush() ~= nil then
        return "ghst"
    end
end

return getProtocol