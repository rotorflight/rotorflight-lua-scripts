-- Usage: local setBit = rf2.executeScript("F/setBit")
local function setBit(value, number, state)
    local mask = bit32.lshift(1, number)
    if state == 1 then
        return bit32.bor(value, mask)
    else
        return bit32.band(value, bit32.bnot(mask))
    end
end

return setBit
