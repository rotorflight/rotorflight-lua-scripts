local lcdShared = rf2.executeScript("LCD/shared")
local waitMessage = rf2.executeScript("LCD/waitMessage", lcdShared)
local messageBox = nil -- loaded on demand
local popupMenu = nil  -- loaded on demand
local Page = nil       -- loaded on demand
local mainMenu = nil   -- loaded on demand

local PageFiles
local CurrentPageIndex = 1

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
local pageChanged = false

-- Color radios on EdgeTX >= 2.11 do not send EVT_VIRTUAL_ENTER anymore after EVT_VIRTUAL_ENTER_LONG
local useKillEnterBreak = not(lcd.setColor and (select(3, getVersion()) >= 3 or select(3, getVersion()) >= 2 and select(4, getVersion()) >= 11))

rf2.setWaitMessage = function(message)
    waitMessage.text = message
end

rf2.clearWaitMessage = function()
    waitMessage.text = nil
end

local function invalidatePages()
    Page = nil
    pageState = lcdShared.pageStatus.display
    rf2.clearWaitMessage()
end

rf2.onPageReady = function(page)
    page.isReady = true
    rf2.lcdNeedsInvalidate = true
end

local function rebootFc()
    --rf2.print("Attempting to reboot the FC...")
    rf2.setWaitMessage("Rebooting...")
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
        rf2.setWaitMessage("Updating...")
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
    CurrentPageIndex = rf2.executeScript("F/incMax")(CurrentPageIndex, inc, #PageFiles)
    pageChanged = true
    invalidatePages()
end

local function reloadPageFiles(setCurrentPageToLastPage)
    PageFiles = rf2.executeScript("pages")
    if setCurrentPageToLastPage then
        CurrentPageIndex = #PageFiles
    end
end

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
        reloadPageFiles()
        invalidatePages()
        uiState = prevUiState or uiStatus.mainMenu
        prevUiState = nil
    elseif uiState == uiStatus.mainMenu then
        if not mainMenu then
            mainMenu = rf2.executeScript("LCD/mainMenu", lcdShared, PageFiles, CurrentPageIndex)
        end
        if event == EVT_VIRTUAL_EXIT then
            return 2
        elseif event == EVT_VIRTUAL_ENTER then
            CurrentPageIndex = mainMenu.getSelectedPageIndex()
            uiState = uiStatus.pages
        elseif event == EVT_VIRTUAL_ENTER_LONG then
            if useKillEnterBreak then lcdShared.killEnterBreak = true end
            createPopupMenu()
        else
            mainMenu.update(event)
        end
    elseif uiState == uiStatus.pages then
        mainMenu = nil
        if Page then
            pageState = Page.lcdp.update(pageState, event)
        end

        if pageState == lcdShared.pageStatus.saving then
            if saveTS + 5.0 <= rf2.clock() then
                --rf2.print("Save timeout!")
                invalidatePages()
            end
        elseif pageState == lcdShared.pageStatus.display then
            if event == EVT_VIRTUAL_PREV_PAGE then
                incPage(-1)
                killEvents(event) -- X10/T16 issue: pageUp is a long press
            elseif event == EVT_VIRTUAL_NEXT_PAGE then
                incPage(1)
            elseif event == EVT_VIRTUAL_ENTER_LONG then
                if useKillEnterBreak then lcdShared.killEnterBreak = true end
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
            --rf2.showMemoryUsage("before loading page")
            Page = rf2.executeScript("PAGES/" .. PageFiles[CurrentPageIndex].script)
            Page.lcdp = rf2.executeScript("LCD/page", lcdShared, Page)
            --rf2.showMemoryUsage("after loading page")
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

    waitMessage.update()

    if getRSSI() == 0 then
        lcd.drawText(rf2.radio.NoTelem[1], rf2.radio.NoTelem[2], rf2.radio.NoTelem[3], rf2.radio.NoTelem[4])
    end

    rf2.mspQueue:processQueue()

    return 0
end

rf2.reloadPage = invalidatePages
rf2.reloadMainMenu = reloadPageFiles

return run_ui
