local lcdShared = ...
local t = {}
local PageFiles
local CurrentPageIndex = 1
local mainMenuScrollY = 0

-- t.show = function (menu)
--     t.menu = menu
-- end

t.incCurrentPage = function(inc)
    local function incMax(val, incr, base)
        return ((val + incr + base - 1) % base) + 1
    end

    CurrentPageIndex = incMax(CurrentPageIndex, inc, #PageFiles)
end

t.loadCurrentPage = function()
    return rf2.executeScript("PAGES/" .. PageFiles[CurrentPageIndex].script)
end

local function draw()
    lcd.clear()
    local yMinLim = rf2.radio.yMinLimit
    local yMaxLim = rf2.radio.yMaxLimit
    local lineSpacing = lcdShared.getLineSpacing()
    local currentFieldY = (CurrentPageIndex-1) * lineSpacing + yMinLim

    if currentFieldY <= yMinLim then
        mainMenuScrollY = 0
    elseif currentFieldY - mainMenuScrollY <= yMinLim then
        mainMenuScrollY = currentFieldY - yMinLim
    elseif currentFieldY - mainMenuScrollY >= yMaxLim then
        mainMenuScrollY = currentFieldY - yMaxLim
    end

    for i = 1, #PageFiles do
        local attr = CurrentPageIndex == i and INVERS or 0
        local y = (i - 1) * lineSpacing + yMinLim - mainMenuScrollY
        if y >= 0 and y <= LCD_H then
            lcd.drawText(6, y, PageFiles[i].title, attr)
        end
    end

    lcdShared.drawScreenTitle("Rotorflight " .. rf2.luaVersion)
end

local function incMainMenu(inc)
    CurrentPageIndex = lcdShared.clipValue(CurrentPageIndex + inc, 1, #PageFiles)
end

t.update = function(event)
    draw()

    if event == EVT_VIRTUAL_NEXT then
        incMainMenu(1)
    elseif event == EVT_VIRTUAL_PREV then
        incMainMenu(-1)
    end

    --return true
end

t.reload = function(setCurrentPageToLastPage)
    PageFiles = rf2.executeScript("pages")
    if setCurrentPageToLastPage then
        CurrentPageIndex = #PageFiles
    end
end

return t
