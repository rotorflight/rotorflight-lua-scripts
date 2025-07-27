local function incMax(val, incr, base)
    return ((val + incr + base - 1) % base) + 1
end

return incMax