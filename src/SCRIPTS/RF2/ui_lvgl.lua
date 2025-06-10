local waitMessage = rf2.executeScript("LVGL/waitMessage")

local uiStatus =
{
    init = 1,
    mainMenu = 2,
    pages = 3,
    exit = 4
}

local ui = {
    state = uiStatus.init,
    previousState = nil
}

local uiInit
local IgnoreNextKeyEvent = false

local PageFiles = nil
local Page = nil
local CurrentPageIndex = -1

local function setWaitMessage(message)
    local title = Page and Page.title or ""
    waitMessage.setWaitMessage(title, message)
end

local function clearWaitMessage()
    waitMessage.clearWaitMessage()
    ui.previousState = nil -- force redraw of previous ui
end

local function loadMainMenu(setCurrentPageToLastPage)
    PageFiles = rf2.executeScript("pages")
    if setCurrentPageToLastPage then
        CurrentPageIndex = #PageFiles
    end
end

local function loadPage()
    Page = rf2.executeScript("PAGES/" .. PageFiles[CurrentPageIndex].script)
    Page:read()
end

local function showMainMenu()
    Page = nil

    local menu = {
        title = "Rotorflight " .. rf2.luaVersion,
        subtitle = "Main Menu",
        items = {},
        back = function() ui.state = uiStatus.exit end
    }

    local onMenuItemClick = function(index)
        rf2.mspQueue:clear()
        CurrentPageIndex = index
        loadPage()
    end

    for i, page in ipairs(PageFiles) do
        local text = string.gsub(page.title, "^ESC %- ", "") -- remove leading 'ESC - ' from page title
        menu.items[#menu.items + 1] = {
            text = text,
            click = onMenuItemClick
        }
    end

    rf2.executeScript("LVGL/mainMenu").show(menu)

    ui.state = uiStatus.mainMenu
    ui.previousState = uiStatus.mainMenu
end

local function rebootFc()
    --setWaitMessage("Rebooting FC...") -- Won't disappear since we don't get a response
    rf2.mspQueue:add({
        command = 68, -- MSP_REBOOT
        processReply = function(self, buf)
            -- Won't ever get here
        end,
        simulatorResponse = {}
    })
    ui.previousState = nil
end

local function saveSettingsToEeprom()
    if not Page or not Page.eepromWrite then return end

    local mspEepromWrite =
    {
        command = 250, -- MSP_EEPROM_WRITE, fails when armed
        processReply = function(self, buf)
            if Page.reboot then
                rebootFc()
            end
            ui.previousState = nil
        end,
        errorHandler = function(self)
            if not rf2.saveWarningShown then
                rf2.saveWarningShown = true
                if rf2.apiVersion >= 12.08 then
                    rf2.executeScript("LVGL/messageBox").showMessage("Save warning", "Settings will be saved\nafter disarming.")
                else
                    rf2.executeScript("LVGL/messageBox").showMessage("Save error", "Make sure your heli\nis disarmed.")
                end
                ui.previousState = nil
            end
        end,
        simulatorResponse = {}
    }
    rf2.mspQueue:add(mspEepromWrite)
end

local function showPopupMenu()
    local menu = { title = "Menu", items = {} }

    if Page then
        if not Page.readOnly then
            menu.items[#menu.items + 1] = {
                text = "Save",
                click = function() Page:write() end
            }
        end

        menu.items [#menu.items + 1] = {
            text = "Reload",
            click = function() Page:read() end
        }
    end

    menu.items[#menu.items + 1] = {
        text = "Reboot",
        click = function() rebootFc() end
    }

    rf2.executeScript("LVGL/popupMenu").show(menu)
end

local function showPage()
    assert(Page, "Page is not loaded")
    Page.back = function() showMainMenu() end
    rf2.executeScript("LVGL/page").show(Page)
    ui.state = uiStatus.pages
    ui.previousState = uiStatus.pages
end

ui.update = function()
    if getRSSI() == 0 then
        if not ui.showingNoTelemetry then
            setWaitMessage("No telemetry")
            ui.showingNoTelemetry = true
        end
    elseif ui.showingNoTelemetry then
        clearWaitMessage()
        ui.showingNoTelemetry = false
    end

    waitMessage.updateWaitMessage()

    if ui.previousState == ui.state then return end
    ui.previousState = ui.state

    --rf2.print("*** Loading UI for ui.state " .. tostring(ui.state))

    if ui.state == uiStatus.mainMenu then
        showMainMenu()
    elseif ui.state == uiStatus.pages then
        loadPage()
    end
end

local function run_ui(event, touchState)
    ui.update()

    if ui.state == uiStatus.init then
        rf2.mspQueue.maxRetries = -1 -- retry indefinitely
        uiInit = uiInit or assert(rf2.loadScript("ui_init.lua"))()
        local gotApiVersion = uiInit.f()
        setWaitMessage(uiInit.t)
        if not gotApiVersion then return 0 end
        clearWaitMessage()
        uiInit = nil
        loadMainMenu()
        showMainMenu()
    end

    if ui.state == uiStatus.exit then
        return 2
    end

    -- if event and event ~= 0 then
    --     rf2.print(" Event: " .. string.format("0x%X", event))
    -- end

    if Page and Page.timer and (not Page.lastTimeTimerFired or Page.lastTimeTimerFired + 0.5 < rf2.clock()) then
        Page.lastTimeTimerFired = rf2.clock()
        Page:timer()
    end

    if event then
        if event == EVT_EXIT_BREAK and Page then
            rf2.mspQueue:clear()
            showMainMenu()
        end

        if event == 0x60D or event == EVT_VIRTUAL_PREV_PAGE or event == EVT_VIRTUAL_NEXT_PAGE then
            -- For some reason the tool gets all key events twice, so we need to ignore the second one.
            if not IgnoreNextKeyEvent then
                IgnoreNextKeyEvent = true
                if event == 0x60D then -- SYS
                    showPopupMenu()
                elseif event == EVT_VIRTUAL_PREV_PAGE then
                    CurrentPageIndex = CurrentPageIndex - 1
                    if CurrentPageIndex < 1 then
                        CurrentPageIndex = #PageFiles
                    end
                    rf2.mspQueue:clear()
                    loadPage()
                elseif event == EVT_VIRTUAL_NEXT_PAGE then
                    CurrentPageIndex = CurrentPageIndex + 1
                    if CurrentPageIndex > #PageFiles then
                        CurrentPageIndex = 1
                    end
                    rf2.mspQueue:clear()
                    loadPage()
                end
            else
                IgnoreNextKeyEvent = false
            end
        end
    end

    rf2.mspQueue:processQueue() -- Note: if a Lua error occurs here, an error message will be shown by EdgeTX and run_ui will not be called anymore.

    return 0
end

-- Implement required functions for the RF2 interface
rf2.reloadPage = loadPage

rf2.reloadMainMenu = loadMainMenu

rf2.setWaitMessage = setWaitMessage

rf2.clearWaitMessage = clearWaitMessage

rf2.settingsSaved = saveSettingsToEeprom

rf2.onPageReady = function(page)
    page.isReady = true
    Page = page
    showPage()
end

-- Return the run_ui function to be called by the RF2 tool
return run_ui
