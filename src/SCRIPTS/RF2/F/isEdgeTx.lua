-- Usage: local isEdgeTx = rf2.executeScript("F/isEdgeTx")()
local function isEdgeTx()
    return select(6, getVersion()) == "EdgeTX"
end

return isEdgeTx