local waitMessage = rf2.useScript("LVGL/waitMessage")

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
local Page = nil
local PageFiles = nil
local CurrentPage = 0

rf2.setWaitMessage = function(message)
    local title = Page and Page.title or ""
    waitMessage.setWaitMessage(title, message)
end

rf2.clearWaitMessage = function()
    waitMessage.clearWaitMessage()
    ui.previousState = nil -- force redraw of previous ui
end

local function loadPage()
    local pageScript = PageFiles[CurrentPage].script
    Page = assert(rf2.loadScript("PAGES/" .. pageScript, "cd"))() -- TODO: consider "cd"
    Page:read()
end

rf2.reloadPage = function()
    loadPage()
end

rf2.loadPageFiles = function(setCurrentPageToLastPage)
    PageFiles = assert(rf2.loadScript("pages.lua"))()
    if setCurrentPageToLastPage then
        CurrentPage = #PageFiles
    end
    collectgarbage()
end

local function showMainMenu()
    if not PageFiles then
        rf2.loadPageFiles()
    end
    Page = nil

    local menu = {
        title = "Rotorflight " .. rf2.luaVersion,
        subtitle = "Main Menu",
        items = {},
        back = function() ui.state = uiStatus.exit end
    }

    local onMenuItemClick = function(index)
        rf2.mspQueue:clear()
        CurrentPage = index
        loadPage()
    end

    for i, page in ipairs(PageFiles) do
        local text = string.gsub(page.title, "^ESC %- ", "") -- remove leading 'ESC - ' from page title
        menu.items[#menu.items + 1] = {
            text = text,
            click = onMenuItemClick
        }
    end

    rf2.useScript("LVGL/mainMenu").show(menu)

    ui.state = uiStatus.mainMenu
    ui.previousState = uiStatus.mainMenu
end

rf2.setCurrentField = function(field)
    -- Setting the focus is not (yet) supported with LVGL.
    -- So this is only for compatibility with ui_lcd at the moment
end

rf2.storeCurrentField = function()
    -- Not supported with LVGL
end

local function rebootFc()
    --rf2.setWaitMessage("Rebooting FC...") -- Won't disappear since we don't get a response
    rf2.mspQueue:add({
        command = 68, -- MSP_REBOOT
        processReply = function(self, buf)
            -- Won't get here
        end,
        simulatorResponse = {}
    })
    if Page then
        Page:read()
    else
        showMainMenu()
    end
end

rf2.settingsSaved = function()
    if Page and Page.eepromWrite then
        local mspEepromWrite =
        {
            command = 250, -- MSP_EEPROM_WRITE, fails when armed
            processReply = function(self, buf)
                if Page.reboot then
                    rebootFc()
                else
                    Page:read()
                end
            end,
            errorHandler = function(self)
                if rf2.apiVersion >= 12.08 then
                    if not rf2.saveWarningShown then
                        rf2.useScript("LVGL/messageBox").showMessage("Save warning", "Settings will be saved\nafter disarming.")
                        rf2.saveWarningShown = true
                    else
                        Page:read()
                    end
                else
                    rf2.useScript("LVGL/messageBox").showMessage("Save error", "Make sure your heli\nis disarmed.")
                end
            end,
            simulatorResponse = {}
        }
        rf2.mspQueue:add(mspEepromWrite)
    end
end

local function showPopupMenu()
    local menu = { title = "Menu", items = {} }

    if Page and not Page.readOnly == true then
        menu.items[#menu.items + 1] = {
            text = "Save",
            click = function() Page:write() end
        }
    end

    if Page then
        menu.items [#menu.items + 1] = {
            text = "Reload",
            click = function() Page:read() end
        }
    end

    menu.items[#menu.items + 1] = {
        text = "Reboot",
        click = function() rebootFc() end
    }

    rf2.useScript("LVGL/popupMenu").show(menu)
end

local function showPage()
    assert(Page, "Page is not loaded")
    Page.back = function() showMainMenu() end
    rf2.useScript("LVGL/page").show(Page)
    ui.state = uiStatus.pages
    ui.previousState = uiStatus.pages
end

rf2.onPageReady = function(page)
    page.isReady = true
    Page = page
    showPage()
end

ui.show = function()
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
    ui.show()

    if ui.state == uiStatus.init then
        rf2.mspQueue.maxRetries = -1 -- retry indefinitely
        uiInit = uiInit or assert(rf2.loadScript("ui_init.lua"))()
        local gotApiVersion = uiInit.f()
        rf2.setWaitMessage(uiInit.t)
        if not gotApiVersion then return 0 end
        rf2.clearWaitMessage()
        uiInit = nil
        ui.state = uiStatus.mainMenu
    end

    if ui.state == uiStatus.exit then
        return 2
    end

    -- if event and event ~= 0 then
    --     rf2.print(" Event: " .. string.format("0x%X", event))
    -- end

    if Page and Page.timer and (not Page.lastTimeTimerFired or Page.lastTimeTimerFired + 0.5 < rf2.clock()) then
        Page.lastTimeTimerFired = rf2.clock()
        Page.timer(Page)
    end

    if event then
        if event == EVT_EXIT_BREAK and Page then
            rf2.mspQueue:clear()
            showMainMenu()
        end

        if event == 0x60D or event == EVT_VIRTUAL_PREV_PAGE or event == EVT_VIRTUAL_NEXT_PAGE then
            -- For some reason the tool gets all key events twice, so we need to ignore the second one.
            if not IgnoreNextKeyEvent then
                if event == 0x60D then -- SYS
                    showPopupMenu()
                elseif event == EVT_VIRTUAL_PREV_PAGE then
                    CurrentPage = CurrentPage - 1
                    if CurrentPage < 1 then
                        CurrentPage = #PageFiles
                    end
                    rf2.mspQueue:clear()
                    loadPage()
                elseif event == EVT_VIRTUAL_NEXT_PAGE then
                    CurrentPage = CurrentPage + 1
                    if CurrentPage > #PageFiles then
                        CurrentPage = 1
                    end
                    rf2.mspQueue:clear()
                    loadPage()
                end
                IgnoreNextKeyEvent = true
            else
                IgnoreNextKeyEvent = false
            end
        end
    end

    if getRSSI() == 0 then
        if not ui.showingNoTelemetry then
            rf2.setWaitMessage("No telemetry")
            ui.showingNoTelemetry = true
        end
    elseif ui.showingNoTelemetry then
        rf2.clearWaitMessage()
        ui.showingNoTelemetry = false
    end

    rf2.mspQueue:processQueue() -- Note: if a Lua error occurs here, an error message will be shown by EdgeTX and run_ui will not be called anymore.

    return 0
end

return run_ui
