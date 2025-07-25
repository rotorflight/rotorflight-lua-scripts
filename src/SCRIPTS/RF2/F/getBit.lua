-- Usage: local getBit = rf2.executeScript("F/getBit")
local function getBit(value, number)
    local mask = bit32.lshift(1, number)
    return bit32.band(value, mask) ~= 0 and 1 or 0
end

return getBit