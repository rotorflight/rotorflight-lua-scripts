local lcdShared = rf2.executeScript("LCD/shared")
local messageBox = nil -- loaded on demand
local popupMenu = nil  -- loaded on demand
local Page = nil       -- loaded on demand
local mainMenu = rf2.executeScript("LCD/mainMenu", lcdShared)

local uiStatus =
{
    init     = 1,
    mainMenu = 2,
    pages    = 3,
    confirm  = 4,
}

local uiState = uiStatus.init
local prevUiState
local pageState = lcdShared.pageStatus.display
local saveTS = 0
local init
local waitMessage
local pageChanged = false

local function invalidatePages()
    Page = nil
    pageState = lcdShared.pageStatus.display
    collectgarbage()
end

rf2.reloadPage = invalidatePages

rf2.setWaitMessage = function(message)
    pageState = lcdShared.pageStatus.waiting
    waitMessage = message
end

rf2.clearWaitMessage = function()
    pageState = lcdShared.pageStatus.display
    waitMessage = nil
end

rf2.onPageReady = function(page)
    page.isReady = true
    rf2.lcdNeedsInvalidate = true
end

local function rebootFc()
    --rf2.print("Attempting to reboot the FC...")
    pageState = lcdShared.pageStatus.rebooting
    rf2.mspQueue:add({
        command = 68, -- MSP_REBOOT
        processReply = function(self, buf)
            invalidatePages()
        end,
        simulatorResponse = {}
    })
end

local function createMessageBox(title, text)
    messageBox = rf2.executeScript("LCD/messageBox", lcdShared)
    messageBox.show(title, text)
end

rf2.settingsSaved = function(eepromWrite, reboot)
    -- check if this page requires writing to eeprom to save (most do)
    if eepromWrite then
        -- don't write again if we're already responding to earlier page.write()s
        if pageState ~= lcdShared.pageStatus.eepromWrite then
            pageState = lcdShared.pageStatus.eepromWrite
            local mspEepromWrite =
            {
                command = 250, -- MSP_EEPROM_WRITE, fails when armed
                processReply = function(self, buf)
                    if reboot then
                        rebootFc()
                    else
                        invalidatePages()
                    end
                end,
                errorHandler = function(self)
                    if rf2.apiVersion >= 12.08 then
                        if not rf2.saveWarningShown then
                            createMessageBox("Save warning", "Settings will be saved\nafter disarming.")
                            rf2.saveWarningShown = true
                        else
                            invalidatePages()
                        end
                    else
                        createMessageBox("Save error", "Make sure your heli\nis disarmed.")
                    end
                end,
                simulatorResponse = {}
            }
            rf2.mspQueue:add(mspEepromWrite)
        end
    elseif pageState ~= lcdShared.pageStatus.eepromWrite then
        -- If we're not already trying to write to eeprom from a previous save, then we're done.
        invalidatePages()
    end
end

local function saveSettings()
    if pageState ~= lcdShared.pageStatus.saving then
        pageState = lcdShared.pageStatus.saving
        saveTS = rf2.clock()
        Page:write()
    end
end

local function confirm(page)
    prevUiState = uiState
    uiState = uiStatus.confirm
    invalidatePages()
    Page = rf2.executeScript(page)
    Page.lcdp = rf2.executeScript("LCD/page", lcdShared, Page)
    collectgarbage()
end

local function createPopupMenu()
    local menu = { title = "Menu:", items = {} }

    if uiState == uiStatus.pages then
        if not Page.readOnly then
            menu.items[#menu.items + 1] = { text = "Save", click = saveSettings }
        end
        menu.items [#menu.items + 1] = { text = "Reload", click = invalidatePages }
    end

    menu.items[#menu.items + 1] = { text = "Reboot", click = rebootFc }
    menu.items[#menu.items + 1] = { text = "Acc Cal", click = function() confirm("CONFIRM/acc_cal.lua") end }

    popupMenu = rf2.executeScript("LCD/popupMenu", lcdShared)
    popupMenu.show(menu)
end

local function incPage(inc)
    mainMenu.incCurrentPage(inc)
    pageChanged = true
    invalidatePages()
end

rf2.reloadMainMenu = mainMenu.reload

local function run_ui(event)
    -- if event and event ~= 0 then
    --     rf2.print("uiState: " .. uiState .. " pageState: " .. pageState .. " Event: " .. string.format("0x%X", event))
    -- end

    if messageBox and messageBox.update(event) then
        if lcdShared.forceReload then
            messageBox = nil
            invalidatePages()
        end
    elseif popupMenu and popupMenu.update(event) then
        if popupMenu.menu == nil then
            popupMenu = nil
        end
    elseif uiState == uiStatus.init then
        lcd.clear()
        lcdShared.drawScreenTitle("Rotorflight " .. rf2.luaVersion)
        init = init or rf2.executeScript("ui_init")
        lcdShared.drawTextMultiline(4, rf2.radio.yMinLimit, init.t)
        if not init.f() then
            return 0
        end
        init = nil
        rf2.reloadMainMenu()
        invalidatePages()
        uiState = prevUiState or uiStatus.mainMenu
        prevUiState = nil
    elseif uiState == uiStatus.mainMenu then
        if event == EVT_VIRTUAL_EXIT then
            return 2
        elseif event == EVT_VIRTUAL_ENTER then
            uiState = uiStatus.pages
        elseif event == EVT_VIRTUAL_ENTER_LONG then
            if rf2.useKillEnterBreak then lcdShared.killEnterBreak = true end
            createPopupMenu()
        else
            mainMenu.update(event)
        end
    elseif uiState == uiStatus.pages then
        if Page then
            pageState = Page.lcdp.update(pageState, event)
        end

        if pageState == lcdShared.pageStatus.saving then
            if saveTS + rf2.protocol.saveTimeout <= rf2.clock() then
                --rf2.print("Save timeout!")
                pageState = lcdShared.pageStatus.display
                invalidatePages()
            end
        elseif pageState == lcdShared.pageStatus.display then
            if event == EVT_VIRTUAL_PREV_PAGE then
                incPage(-1)
                killEvents(event) -- X10/T16 issue: pageUp is a long press
            elseif event == EVT_VIRTUAL_NEXT_PAGE then
                incPage(1)
            elseif event == EVT_VIRTUAL_ENTER_LONG then
                if rf2.useKillEnterBreak then lcdShared.killEnterBreak = true end
                createPopupMenu()
            elseif event == EVT_VIRTUAL_EXIT then
                invalidatePages()
                uiState = uiStatus.mainMenu
                if rf2.logfile then
                    io.close(rf2.logfile)
                    rf2.logfile = nil
                end
                return 0
            end
        end
        if not Page then
            if pageChanged then
                -- Only clear queue when the current page has changed, and not when saving a page.
                pageChanged = false
                rf2.mspQueue:clear()
            end
            collectgarbage()
            --rf2.showMemoryUsage("before loading page")
            Page = mainMenu.loadCurrentPage()
            Page.lcdp = rf2.executeScript("LCD/page", lcdShared, Page)
            --rf2.showMemoryUsage("after loading page")
            collectgarbage()
        end
        if pageState == lcdShared.pageStatus.saving or pageState == lcdShared.pageStatus.eepromWrite or
            pageState == lcdShared.pageStatus.rebooting or pageState == lcdShared.pageStatus.waiting then
            local saveMsg = ""
            if pageState == lcdShared.pageStatus.saving then
                saveMsg = "Saving..."
            elseif pageState == lcdShared.pageStatus.eepromWrite then
                saveMsg = "Updating..."
            elseif pageState == lcdShared.pageStatus.rebooting then
                saveMsg = "Rebooting..."
            elseif pageState == lcdShared.pageStatus.waiting then
                saveMsg = waitMessage
            end
            lcd.drawFilledRectangle(rf2.radio.SaveBox.x, rf2.radio.SaveBox.y, rf2.radio.SaveBox.w, rf2.radio.SaveBox.h, lcdShared.backgroundFill)
            lcd.drawRectangle(rf2.radio.SaveBox.x, rf2.radio.SaveBox.y, rf2.radio.SaveBox.w, rf2.radio.SaveBox.h, SOLID)
            lcd.drawText(rf2.radio.SaveBox.x + rf2.radio.SaveBox.x_offset, rf2.radio.SaveBox.y + rf2.radio.SaveBox.h_offset, saveMsg,DBLSIZE + lcdShared.textOptions)
        end
    elseif uiState == uiStatus.confirm then
        Page.lcdp.draw(pageState)
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
        lcd.drawText(rf2.radio.NoTelem[1], rf2.radio.NoTelem[2], rf2.radio.NoTelem[3], rf2.radio.NoTelem[4])
    end

    rf2.mspQueue:processQueue()

    return 0
end

return run_ui
