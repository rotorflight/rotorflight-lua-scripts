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

local function drawScreenTitle(screenTitle)
    if rf2.radio.highRes then
        lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
        lcd.drawText(5, 5, screenTitle, MENU_TITLE_COLOR)
    else
        lcd.drawFilledRectangle(0, 0, LCD_W, 10, FORCE)
        lcd.drawText(1, 1, screenTitle, INVERS)
    end
end

return {
    backgroundFill = TEXT_BGCOLOR or ERASE,
    getLineSpacing = getLineSpacing,
    drawTextMultiline = drawTextMultiline,
    clipValue = clipValue,
    forceReload = false,
    textOptions = TEXT_COLOR or 0,
    foregroundColor = LINE_COLOR or SOLID,
    killEnterBreak = false,
    drawScreenTitle = drawScreenTitle,
    pageStatus =
    {
        display = 1,
        editing = 2,
        saving  = 3,
        eepromWrite = 4,
        rebooting = 5
    }
}