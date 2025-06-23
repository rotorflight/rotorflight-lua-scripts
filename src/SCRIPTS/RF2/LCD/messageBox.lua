local lcdShared = ...

local displayMessage = nil

local function show(title, text)
    displayMessage = { title = title, text = text }
end

local function drawMessage(title, message)
    if rf2.radio.highRes then
        lcd.drawFilledRectangle(50, 40, LCD_W - 100, LCD_H - 80, TITLE_BGCOLOR)
        lcd.drawText(60, 45, title, MENU_TITLE_COLOR)
        lcd.drawFilledRectangle(50, 70, LCD_W - 100, LCD_H - 100, lcdShared.backgroundFill)
        lcd.drawRectangle(50, 40, LCD_W - 100, LCD_H - 80, SOLID)
        lcdShared.drawTextMultiline(70, 80, message)
    else
        lcd.drawFilledRectangle(0, 0, LCD_W, 10, FORCE)
        lcd.drawText(1, 1, title, INVERS)
        lcdShared.drawTextMultiline(5, 5 + lcdShared.getLineSpacing(), message)
    end
end

local function update(event)
    if not displayMessage then return false end

    lcd.clear()
    drawMessage(displayMessage.title, displayMessage.text)

    if event == EVT_VIRTUAL_EXIT or event == EVT_VIRTUAL_ENTER then
        displayMessage = nil
        lcdShared.forceReload = true
    end

    return true
end

return { show = show, update = update }
