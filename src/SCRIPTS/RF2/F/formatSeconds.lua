-- Usage: local formattedSeconds = rf2.executeScript("F/formatSeconds")(seconds)
local function formatSeconds(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    local s = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    if days > 0 then
        -- e.g. 12d04:30:58
        return string.format("%dd%s", days, s)
    else
        -- only 04:30:58
        return s
    end
end

return formatSeconds