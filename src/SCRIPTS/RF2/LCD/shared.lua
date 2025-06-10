local function getLineSpacing()
    if rf2.radio.highRes then
        return 25
    end
    return 10
end

local function drawTextMultiline(x, y, text, options)
    for str in string.gmatch(text, "([^\n]+)") do
        lcd.drawText(x, y, str, options)
        y = y + getLineSpacing()
    end
end

return {
    backgroundFill = TEXT_BGCOLOR or ERASE,
    getLineSpacing = getLineSpacing,
    drawTextMultiline = drawTextMultiline,
    forceReload = false
}