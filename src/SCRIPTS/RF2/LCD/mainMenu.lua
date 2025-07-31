local lcdShared, pageFiles, selectedPageIndex = ...
local t = {}
local mainMenuScrollY = 0

local function draw()
    lcd.clear()
    local yMinLim = rf2.radio.yMinLimit
    local yMaxLim = rf2.radio.yMaxLimit
    local lineSpacing = lcdShared.getLineSpacing()
    local currentFieldY = (selectedPageIndex-1) * lineSpacing + yMinLim

    if currentFieldY <= yMinLim then
        mainMenuScrollY = 0
    elseif currentFieldY - mainMenuScrollY <= yMinLim then
        mainMenuScrollY = currentFieldY - yMinLim
    elseif currentFieldY - mainMenuScrollY >= yMaxLim then
        mainMenuScrollY = currentFieldY - yMaxLim
    end

    for i = 1, #pageFiles do
        local attr = selectedPageIndex == i and INVERS or 0
        local y = (i - 1) * lineSpacing + yMinLim - mainMenuScrollY
        if y >= 0 and y <= LCD_H then
            lcd.drawText(6, y, pageFiles[i].title, attr)
        end
    end

    lcdShared.drawScreenTitle("Rotorflight " .. rf2.luaVersion)
end

local function incMainMenu(inc)
    selectedPageIndex = rf2.executeScript("F/incMax")(selectedPageIndex, inc, #pageFiles)
end

t.update = function(event)
    draw()

    if event == EVT_VIRTUAL_NEXT then
        incMainMenu(1)
    elseif event == EVT_VIRTUAL_PREV then
        incMainMenu(-1)
    end
end

t.getSelectedPageIndex = function()
    return selectedPageIndex
end

return t
