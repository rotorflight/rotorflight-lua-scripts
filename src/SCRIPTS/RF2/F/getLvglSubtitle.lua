local subtitle = ...

local function canUseDynamicSubtitle()
    -- Dynamic subtitles work on EdgeTX 2.11.4 or higher
    return lcd.setColor and (select(3, getVersion()) >= 3 or (select(3, getVersion()) == 2 and select(4, getVersion()) >= 11 and select(5, getVersion()) >= 4))
end

if not (rf2.widget and rf2.widget.options and canUseDynamicSubtitle()) then
    return subtitle
end

return function()
    return subtitle .. " - " .. rf2.widget.options:getText()
end
