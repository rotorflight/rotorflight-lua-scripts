local LUA_VERSION = "2.1.0"

local uiStatus =
{
    init     = 1,
    mainMenu = 2,
    pages    = 3,
    confirm  = 4,
}

local pageStatus =
{
    display = 1,
    editing = 2,
    saving  = 3,
    eepromWrite = 4,
    rebooting = 5,
    waiting = 6
}

local uiState = uiStatus.init
local prevUiState
local pageState = pageStatus.display
local currentPage = 1
local currentField = 1
local saveTS = 0
local popupMenuActive = 1
local killEnterBreak = 0
local pageScrollY = 0
local mainMenuScrollY = 0
local PageFiles, Page, init, popupMenu
local scrollSpeedTS = 0
local displayMessage
local waitMessage

local backgroundFill = TEXT_BGCOLOR or ERASE
local foregroundColor = LINE_COLOR or SOLID

local globalTextOptions = TEXT_COLOR or 0

local function invalidatePages()
    Page = nil
    pageState = pageStatus.display
    collectgarbage()
end

rf2.reloadPage = invalidatePages

rf2.setWaitMessage = function(message)
    pageState = pageStatus.waiting
    waitMessage = message
end

rf2.clearWaitMessage = function()
    pageState = pageStatus.display
    waitMessage = nil
end

rf2.displayMessage = function(title, text)
    displayMessage = { title = title, text = text }
end

local function rebootFc()
    --rf2.print("Attempting to reboot the FC...")
    pageState = pageStatus.rebooting
    rf2.mspQueue:add({
        command = 68, -- MSP_REBOOT
        processReply = function(self, buf)
            invalidatePages()
        end,
        simulatorResponse = {}
    })
end

local mspEepromWrite =
{
    command = 250, -- MSP_EEPROM_WRITE, fails when armed
    processReply = function(self, buf)
        if Page.reboot then
            rebootFc()
        else
            invalidatePages()
        end
    end,
    errorHandler = function(self)
        rf2.displayMessage("Save error", "Make sure your heli\nis disarmed.")
    end,
    simulatorResponse = {}
}

rf2.settingsSaved = function()
    -- check if this page requires writing to eeprom to save (most do)
    if Page and Page.eepromWrite then
        -- don't write again if we're already responding to earlier page.write()s
        if pageState ~= pageStatus.eepromWrite then
            pageState = pageStatus.eepromWrite
            rf2.mspQueue:add(mspEepromWrite)
        end
    elseif pageState ~= pageStatus.eepromWrite then
        -- If we're not already trying to write to eeprom from a previous save, then we're done.
        invalidatePages()
    end
end

local mspSaveSettings =
{
    processReply = function(self, buf)
        rf2.settingsSaved()
    end
}

rf2.saveSettings = function()
    if pageState ~= pageStatus.saving then
        pageState = pageStatus.saving
        saveTS = rf2.clock()

        if Page.values then
            local payload = Page.values
            if Page.preSave then
                payload = Page.preSave(Page)
            end
            mspSaveSettings.command = Page.write
            mspSaveSettings.payload = payload
            mspSaveSettings.simulatorResponse = {}
            rf2.mspQueue:add(mspSaveSettings)
        elseif type(Page.write) == "function" then
            Page.write(Page)
        end
    end
end

local mspLoadSettings =
{
    processReply = function(self, buf)
        if not Page then return end -- could happen if one returns to the main menu before processReply
        rf2.print("Page is processing reply for cmd "..tostring(self.command).." len buf: "..#buf.." expected: "..Page.minBytes)
        Page.values = buf
        if Page.postRead then
            if Page.postRead(Page) == -1 then
                Page.values = nil
                return
             end
        end
        rf2.dataBindFields()
        if Page.postLoad then
            Page.postLoad(Page)
        end
    end
}

rf2.readPage = function()
    collectgarbage()

    if type(Page.read) == "function" then
        Page.read(Page)
    else
        mspLoadSettings.command = Page.read
        mspLoadSettings.simulatorResponse = Page.simulatorResponse
        rf2.mspQueue:add(mspLoadSettings)
    end
end

local function requestPage()
    if not Page.reqTS or Page.reqTS + 2 <= rf2.clock() then
        --rf2.print("Requesting page...")
        Page.reqTS = rf2.clock()
        if Page.read then
            rf2.readPage()
        end
    end
end

local function confirm(page)
    prevUiState = uiState
    uiState = uiStatus.confirm
    invalidatePages()
    currentField = 1
    Page = assert(rf2.loadScript(page))()
    collectgarbage()
end

local function createPopupMenu()
    popupMenuActive = 1
    popupMenu = {}
    if uiState == uiStatus.pages then
        if not Page.readOnly then
            popupMenu[#popupMenu + 1] = { t = "Save Page", f = rf2.saveSettings }
        end
        popupMenu[#popupMenu + 1] = { t = "Reload", f = invalidatePages }
    end
    popupMenu[#popupMenu + 1] = { t = "Reboot", f = rebootFc }
    popupMenu[#popupMenu + 1] = { t = "Acc Cal", f = function() confirm("CONFIRM/acc_cal.lua") end }
end

rf2.dataBindFields = function()
    for i=1,#Page.fields do
        if #Page.values >= Page.minBytes then
            local f = Page.fields[i]
            if f.vals then
                f.value = 0
                for idx=1, #f.vals do
                    local raw_val = Page.values[f.vals[idx]] or 0
                    raw_val = bit32.lshift(raw_val, (idx-1)*8)
                    f.value = bit32.bor(f.value, raw_val)
                end
                local bits = #f.vals * 8
                if f.min and f.min < 0 and bit32.btest(f.value, bit32.lshift(1, bits - 1)) then
                    f.value = f.value - (2 ^ bits)
                end
                f.value = f.value/(f.scale or 1)
            end
        end
    end
end

local function incMax(val, inc, base)
    return ((val + inc + base - 1) % base) + 1
end

local function clipValue(val,min,max)
    if val < min then
        val = min
    elseif val > max then
        val = max
    end
    return val
end

local function incPage(inc)
    currentPage = incMax(currentPage, inc, #PageFiles)
    currentField = 1
    invalidatePages()
end

local function incField(inc)
    currentField = clipValue(currentField + inc, 1, #Page.fields)
end

local function incMainMenu(inc)
    currentPage = clipValue(currentPage + inc, 1, #PageFiles)
end

local function incPopupMenu(inc)
    popupMenuActive = clipValue(popupMenuActive + inc, 1, #popupMenu)
end

local function drawScreenTitle(screenTitle)
    if rf2.radio.highRes then
        lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
        lcd.drawText(5,5,screenTitle, MENU_TITLE_COLOR)
    else
        lcd.drawFilledRectangle(0, 0, LCD_W, 10, FORCE)
        lcd.drawText(1,1,screenTitle,INVERS)
    end
end

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

local function drawMessage(title, message)
    if rf2.radio.highRes then
        lcd.drawFilledRectangle(50, 40, LCD_W - 100, LCD_H - 80, TITLE_BGCOLOR)
        lcd.drawText(60, 45, title, MENU_TITLE_COLOR)
        lcd.drawFilledRectangle(50, 70, LCD_W - 100, LCD_H - 100, backgroundFill)
        lcd.drawRectangle(50, 40, LCD_W - 100, LCD_H - 80, SOLID)
        drawTextMultiline(70, 80, message)
    else
        lcd.drawFilledRectangle(0, 0, LCD_W, 10, FORCE)
        lcd.drawText(1, 1, title, INVERS)
        drawTextMultiline(5, 5 + getLineSpacing(), message)
    end
end

local function fieldIsButton(f)
    return f.t and string.sub(f.t, 1, 1) == "[" and not (f.data or f.value)
end

local function drawScreen()
    local yMinLim = rf2.radio.yMinLimit
    local yMaxLim = rf2.radio.yMaxLimit
    local currentFieldY = Page.fields[currentField].y
    local textOptions = rf2.radio.textSize + globalTextOptions
    if currentFieldY <= Page.fields[1].y then
        pageScrollY = 0
    elseif currentFieldY - pageScrollY <= yMinLim then
        pageScrollY = currentFieldY - yMinLim
    elseif currentFieldY - pageScrollY >= yMaxLim then
        pageScrollY = currentFieldY - yMaxLim
    end
    for i=1,#Page.labels do
        local f = Page.labels[i]
        local y = f.y - pageScrollY
        if y >= 0 and y <= LCD_H then
            lcd.drawText(f.x, y, f.t, textOptions)
        end
    end
    for i=1,#Page.fields do
        local val = "---"
        local f = Page.fields[i]
        local valueOptions = textOptions
        if i == currentField then
            valueOptions = valueOptions + INVERS
            if pageState == pageStatus.editing then
                valueOptions = valueOptions + BLINK
            end
        end
        if f.data and f.data.value then
            val = f.data.value
            if type(val) == "number" then
                if f.data.scale then
                    val = val / f.data.scale
                else
                    val = math.floor(val)
                end
            end
            if f.data.table and f.data.table[val] then
                val = f.data.table[val]
            end
        elseif f.value then
            val = f.value
            if type(val) == "number" and not f.scale then
                val = math.floor(val)
            end
            if f.table and f.table[f.value] then
                val = f.table[f.value]
            end
        end
        local y = f.y - pageScrollY
        if y >= 0 and y <= LCD_H then
            if fieldIsButton(f) then
                val = f.t
            elseif f.t then
                lcd.drawText(f.x, y, f.t, textOptions)
            end
            lcd.drawText(f.sp or f.x, y, val, valueOptions)
        end
    end
    drawScreenTitle("Rotorflight / "..Page.title)
end

local function incValue(inc)
    local f = Page.fields[currentField]
    if f.data then
        local scale = f.data.scale or 1
        local mult = f.data.mult or 1
        f.data.value = clipValue(f.data.value + inc*mult, (f.data.min or 0), (f.data.max or 255))
        f.data.value = math.floor(f.data.value/mult + 0.5)*mult
    else
        local scale = f.scale or 1
        local mult = f.mult or 1
        f.value = clipValue(f.value + inc*mult/scale, (f.min or 0)/scale, (f.max or 255)/scale)
        f.value = math.floor(f.value*scale/mult + 0.5)*mult/scale
        if Page.values then
            for idx=1, #f.vals do
                Page.values[f.vals[idx]] = bit32.rshift(math.floor(f.value*scale + 0.5), (idx-1)*8)
            end
        end
    end
    if f.change then
        f:change(Page)
    end
end

local function drawPopupMenu()
    local x = rf2.radio.MenuBox.x
    local y = rf2.radio.MenuBox.y
    local w = rf2.radio.MenuBox.w
    local h_line = rf2.radio.MenuBox.h_line
    local h_offset = rf2.radio.MenuBox.h_offset
    local h = #popupMenu * h_line + h_offset*2

    lcd.drawFilledRectangle(x,y,w,h,backgroundFill)
    lcd.drawRectangle(x,y,w-1,h-1,foregroundColor)
    lcd.drawText(x+h_line/2,y+h_offset,"Menu:",globalTextOptions)

    for i,e in ipairs(popupMenu) do
        local textOptions = globalTextOptions
        if popupMenuActive == i then
            textOptions = textOptions + INVERS
        end
        lcd.drawText(x+rf2.radio.MenuBox.x_offset,y+(i-1)*h_line+h_offset,e.t,textOptions)
    end
end

rf2.loadPageFiles = function(setCurrentPageToLastPage)
    PageFiles = assert(rf2.loadScript("pages.lua"))()
    if setCurrentPageToLastPage then
        currentPage = #PageFiles
    end
    collectgarbage()
end

local function run_ui(event)
    --rf2.print("uiState: "..uiState.." pageState: "..pageState)
    if displayMessage then
        lcd.clear()
        drawMessage(displayMessage.title, displayMessage.text)
        if event == EVT_VIRTUAL_EXIT or event == EVT_VIRTUAL_ENTER then
            displayMessage = nil
            invalidatePages()
        end
    elseif popupMenu then
        drawPopupMenu()
        if event == EVT_VIRTUAL_EXIT then
            popupMenu = nil
        elseif event == EVT_VIRTUAL_PREV then
            incPopupMenu(-1)
        elseif event == EVT_VIRTUAL_NEXT then
            incPopupMenu(1)
        elseif event == EVT_VIRTUAL_ENTER then
            if killEnterBreak == 1 then
                killEnterBreak = 0
            else
                popupMenu[popupMenuActive].f()
                popupMenu = nil
            end
        end
    elseif uiState == uiStatus.init then
        lcd.clear()
        drawScreenTitle("Rotorflight "..LUA_VERSION)
        init = init or assert(rf2.loadScript("ui_init.lua"))()
        drawTextMultiline(4, rf2.radio.yMinLimit, init.t)
        if not init.f() then
            return 0
        end
        init = nil
        rf2.loadPageFiles()
        invalidatePages()
        uiState = prevUiState or uiStatus.mainMenu
        prevUiState = nil
    elseif uiState == uiStatus.mainMenu then
        if event == EVT_VIRTUAL_EXIT then
            collectgarbage()
            return 2
        elseif event == EVT_VIRTUAL_NEXT then
            incMainMenu(1)
        elseif event == EVT_VIRTUAL_PREV then
            incMainMenu(-1)
        elseif event == EVT_VIRTUAL_ENTER then
            uiState = uiStatus.pages
        elseif event == EVT_VIRTUAL_ENTER_LONG then
            killEnterBreak = 1
            createPopupMenu()
        end
        lcd.clear()
        local yMinLim = rf2.radio.yMinLimit
        local yMaxLim = rf2.radio.yMaxLimit
        local lineSpacing = getLineSpacing()
        local currentFieldY = (currentPage-1)*lineSpacing + yMinLim
        if currentFieldY <= yMinLim then
            mainMenuScrollY = 0
        elseif currentFieldY - mainMenuScrollY <= yMinLim then
            mainMenuScrollY = currentFieldY - yMinLim
        elseif currentFieldY - mainMenuScrollY >= yMaxLim then
            mainMenuScrollY = currentFieldY - yMaxLim
        end
        for i=1, #PageFiles do
            local attr = currentPage == i and INVERS or 0
            local y = (i-1)*lineSpacing + yMinLim - mainMenuScrollY
            if y >= 0 and y <= LCD_H then
                lcd.drawText(6, y, PageFiles[i].title, attr)
            end
        end
        drawScreenTitle("Rotorflight "..LUA_VERSION)
    elseif uiState == uiStatus.pages then
        if pageState == pageStatus.saving then
            if saveTS + rf2.protocol.saveTimeout <= rf2.clock() then
                --rf2.print("Save timeout!")
                pageState = pageStatus.display
                invalidatePages()
            end
        elseif pageState == pageStatus.display then
            if event == EVT_VIRTUAL_PREV_PAGE then
                incPage(-1)
                killEvents(event) -- X10/T16 issue: pageUp is a long press
            elseif event == EVT_VIRTUAL_NEXT_PAGE then
                incPage(1)
            elseif Page and (event == EVT_VIRTUAL_PREV or event == EVT_VIRTUAL_PREV_REPT) then
                incField(-1)
            elseif Page and (event == EVT_VIRTUAL_NEXT or event == EVT_VIRTUAL_NEXT_REPT) then
                incField(1)
            elseif Page and event == EVT_VIRTUAL_ENTER then
                local f = Page.fields[currentField]
                if (Page.isReady or (Page.values and f.vals and Page.values[f.vals[#f.vals]])) and not f.readOnly then
                    if not fieldIsButton(Page.fields[currentField]) then
                        pageState = pageStatus.editing
                    end
                    if Page.fields[currentField].preEdit then
                        Page.fields[currentField]:preEdit(Page)
                    end
                end
            elseif event == EVT_VIRTUAL_ENTER_LONG then
                killEnterBreak = 1
                createPopupMenu()
            elseif event == EVT_VIRTUAL_EXIT then
                invalidatePages()
                currentField = 1
                uiState = uiStatus.mainMenu
                if rf2.logfile then
                    io.close(rf2.logfile)
                    rf2.logfile = nil
                end
                return 0
            end
        elseif pageState == pageStatus.editing then
            local scrollSpeedMultiplier = 1
            if event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT or event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
                local scrollSpeed = rf2.clock() - scrollSpeedTS
                --rf2.print(scrollSpeed)
                if scrollSpeed < 0.075 then
                    scrollSpeedMultiplier = 5
                end
                scrollSpeedTS = rf2.clock()
            end
            if event == EVT_VIRTUAL_EXIT or event == EVT_VIRTUAL_ENTER then
                if Page.fields[currentField].postEdit then
                    Page.fields[currentField]:postEdit(Page)
                end
                pageState = pageStatus.display
            elseif event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
                incValue(1 * scrollSpeedMultiplier)
            elseif event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
                incValue(-1 * scrollSpeedMultiplier)
            end
        end
        if Page and Page.timer and (not Page.lastTimeTimerFired or Page.lastTimeTimerFired + 0.5 < rf2.clock()) then
            Page.lastTimeTimerFired = rf2.clock()
            Page.timer(Page)
        end
        if not Page then
            collectgarbage()
            Page = assert(rf2.loadScript("PAGES/"..PageFiles[currentPage].script))()
            collectgarbage()
        end
        if not(Page.values or Page.isReady) and pageState == pageStatus.display then
            requestPage()
        end
        lcd.clear()
        drawScreen()
        if pageState == pageStatus.saving or pageState == pageStatus.eepromWrite or pageState == pageStatus.rebooting or pageState == pageStatus.waiting then
            local saveMsg = ""
            if pageState == pageStatus.saving then
                saveMsg = "Saving..."
            elseif pageState == pageStatus.eepromWrite then
                saveMsg = "Updating..."
            elseif pageState == pageStatus.rebooting then
                saveMsg = "Rebooting..."
            elseif pageState == pageStatus.waiting then
                saveMsg = waitMessage
            end
            lcd.drawFilledRectangle(rf2.radio.SaveBox.x,rf2.radio.SaveBox.y,rf2.radio.SaveBox.w,rf2.radio.SaveBox.h,backgroundFill)
            lcd.drawRectangle(rf2.radio.SaveBox.x,rf2.radio.SaveBox.y,rf2.radio.SaveBox.w,rf2.radio.SaveBox.h,SOLID)
            lcd.drawText(rf2.radio.SaveBox.x+rf2.radio.SaveBox.x_offset,rf2.radio.SaveBox.y+rf2.radio.SaveBox.h_offset,saveMsg,DBLSIZE + globalTextOptions)
        end
    elseif uiState == uiStatus.confirm then
        lcd.clear()
        drawScreen()
        if event == EVT_VIRTUAL_ENTER then
            uiState = uiStatus.init
            init = Page.init
            invalidatePages()
        elseif event == EVT_VIRTUAL_EXIT then
            invalidatePages()
            uiState = prevUiState
            prevUiState = nil
        end
    end
    if getRSSI() == 0 and not rf2.runningInSimulator then
        lcd.drawText(rf2.radio.NoTelem[1],rf2.radio.NoTelem[2],rf2.radio.NoTelem[3],rf2.radio.NoTelem[4])
    end

    rf2.mspQueue:processQueue()

    return 0
end

return run_ui
