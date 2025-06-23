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

local function clipValue(val, min, max)
    if val < min then
        val = min
    elseif val > max then
        val = max
    end
    return val
end

return {
    backgroundFill = TEXT_BGCOLOR or ERASE,
    getLineSpacing = getLineSpacing,
    drawTextMultiline = drawTextMultiline,
    clipValue = clipValue,
    forceReload = false,
    textOptions = TEXT_COLOR or 0,
    foregroundColor = LINE_COLOR or SOLID,
    killEnterBreak = false
}