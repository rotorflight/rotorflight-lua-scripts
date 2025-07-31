local lcdShared = ...

local t = {
    text = nil
}

t.update = function()
    if not t.text then return end

    lcd.drawFilledRectangle(rf2.radio.SaveBox.x, rf2.radio.SaveBox.y, rf2.radio.SaveBox.w, rf2.radio.SaveBox.h, lcdShared.backgroundFill)
    lcd.drawRectangle(rf2.radio.SaveBox.x, rf2.radio.SaveBox.y, rf2.radio.SaveBox.w, rf2.radio.SaveBox.h, SOLID)
    lcd.drawText(rf2.radio.SaveBox.x + rf2.radio.SaveBox.x_offset, rf2.radio.SaveBox.y + rf2.radio.SaveBox.h_offset, t.text, DBLSIZE + lcdShared.textOptions)
end

return t