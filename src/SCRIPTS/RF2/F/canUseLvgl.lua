-- Usage: local canUseLvgl = rf2.executeScript("F/canUseLvgl")()
local function canUseLvgl()
    -- Use LVGL graphics on color radios with EdgeTX 2.11 or higher
    return lcd.setColor and (select(3, getVersion()) >= 3 or (select(3, getVersion()) == 2 and select(4, getVersion()) >= 11))
end

return canUseLvgl