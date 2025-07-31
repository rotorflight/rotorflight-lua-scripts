local lcdShared = ...
local t = {}
local activeMenuItem = 1

t.show = function (menu)
    t.menu = menu
    activeMenuItem = 1
end

local function draw()
    local x = rf2.radio.MenuBox.x
    local y = rf2.radio.MenuBox.y
    local w = rf2.radio.MenuBox.w
    local h_line = rf2.radio.MenuBox.h_line
    local h_offset = rf2.radio.MenuBox.h_offset
    local h = #t.menu.items * h_line + h_offset*2

    lcd.drawFilledRectangle(x, y, w, h, lcdShared.backgroundFill)
    lcd.drawRectangle(x, y, w-1, h-1, lcdShared.foregroundColor)
    lcd.drawText(x + h_line/2, y + h_offset, t.menu.title, lcdShared.textOptions)

    for i, item in ipairs(t.menu.items) do
        local textOptions = lcdShared.textOptions
        if activeMenuItem == i then
            textOptions = textOptions + INVERS
        end
        lcd.drawText(x + rf2.radio.MenuBox.x_offset, y + (i-1)*h_line + h_offset, item.text, textOptions)
    end
end

local function incPopupMenu(inc)
    activeMenuItem = lcdShared.clipValue(activeMenuItem + inc, 1, #t.menu.items)
end

t.update = function(event)
    if not t.menu then return false end

    draw()

    if event == EVT_VIRTUAL_EXIT then
        t.menu = nil
    elseif event == EVT_VIRTUAL_PREV then
        incPopupMenu(-1)
    elseif event == EVT_VIRTUAL_NEXT then
        incPopupMenu(1)
    elseif event == EVT_VIRTUAL_ENTER then
        if lcdShared.killEnterBreak then
            lcdShared.killEnterBreak = false
        else
            t.menu.items[activeMenuItem].click()
            t.menu = nil
        end
    end

    return true
end

return t
