local waitMessage = rf2.executeScript("LVGL/waitMessage")

local ui = {
    status =
    {
        init = 1,
        mainMenu = 2,
        pages = 3,
        exit = 4
    },
    state = 1,  -- ui.status.init
    previousState = nil
}

local t = rf2.i18n.t

local PageFiles = nil
local Page = nil
local CurrentPageIndex = -1

ui.refresh = function()
    ui.previousState = nil
end

ui.setWaitMessage = function(message)
    local title = Page and Page.title or ""
    waitMessage.setWaitMessage(title, message)
end

ui.clearWaitMessage = function()
    waitMessage.clearWaitMessage()
    ui.refresh()
end

ui.loadMainMenu = function(setCurrentPageToLastPage)
    PageFiles = rf2.executeScript("pages")
    if setCurrentPageToLastPage then
        CurrentPageIndex = #PageFiles
    end
end

ui.loadPage = function()
    Page = rf2.executeScript("PAGES/" .. PageFiles[CurrentPageIndex].script)
    Page:read()
end



ui.showMainMenu = function()
    Page = nil

    local menu = {
        title = "Rotorflight " .. rf2.luaVersion,
        subtitle = t("TITLE_Menu_Menu", "Main Menu"),
        items = {},
        back = function() ui.state = ui.status.exit end
    }

    local onMenuItemClick = function(index)
        rf2.mspQueue:clear()
        CurrentPageIndex = index
        ui.loadPage()
    end

    for i = 1, #PageFiles do
        local page = PageFiles[i]
        local text = string.gsub(page.title, "^ESC %- ", "") -- remove leading 'ESC - ' from page title
        menu.items[#menu.items + 1] = {
            text = text,
            icon = page.icon,
            click = onMenuItemClick
        }
    end

    rf2.executeScript("LVGL/mainMenu").show(menu)

    ui.state = ui.status.mainMenu
    ui.previousState = ui.status.mainMenu
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
    ui.refresh()
end

ui.saveSettingsToEeprom = function(eepromWrite, reboot)
    if not eepromWrite then
        if ui.state == ui.status.pages then ui.refresh() end
        return
    end

    local mspEepromWrite =
    {
        command = 250, -- MSP_EEPROM_WRITE, fails when armed
        processReply = function(self, buf)
            if reboot then
                rebootFc()
            end
            if ui.state == ui.status.pages then ui.refresh() end
        end,
        errorHandler = function(self)
            if not ui.saveWarningShown then
                ui.saveWarningShown = true
                if rf2.apiVersion >= 12.08 then
                    rf2.executeScript("LVGL/messageBox").show(t("TITLE_WARNING_Save", "Save warning"), t("MSG_WARNING_Save_later", "Settings will be saved\nafter disarming."))
                else
                    rf2.executeScript("LVGL/messageBox").show(t("TITLE_Save_Error", "Save error"), t("MSG_Save_Error", "Make sure your heli\nis disarmed."))
                end
                ui.refresh()
            end
        end,
        simulatorResponse = {}
    }
    rf2.mspQueue:add(mspEepromWrite)
end

ui.showPopupMenu = function()
    local menu = { title = "Menu", items = {} }

    if Page then
        if not Page.readOnly then
            menu.items[#menu.items + 1] = {
                text = t("MENU_Save", "Save"),
                click = function() Page:write() end
            }
        end

        menu.items [#menu.items + 1] = {
            text = t("MENU_Reload", "Reload"),
            click = function() Page:read() end
        }
    end

    menu.items[#menu.items + 1] = {
        text = t("MENU_Reboot", "Reboot"),
        click = function() rebootFc() end
    }

    rf2.executeScript("LVGL/popupMenu").show(menu)
end

ui.showPage = function()
    if not Page then return end -- might happen if the user returned to the main menu right after saving.
    Page.back = function() ui.showMainMenu() end
    rf2.executeScript("LVGL/page").show(Page)
    ui.state = ui.status.pages
    ui.previousState = ui.status.pages
end

ui.update = function()
    if getRSSI() == 0 then
        if not ui.showingNoTelemetry then
            ui.setWaitMessage("No telemetry")
            ui.showingNoTelemetry = true
        end
    elseif ui.showingNoTelemetry then
        ui.clearWaitMessage()
        ui.showingNoTelemetry = false
    end

    waitMessage.updateWaitMessage()

    if Page and Page.timer and (not Page.lastTimeTimerFired or Page.lastTimeTimerFired + 0.5 < rf2.clock()) then
        Page.lastTimeTimerFired = rf2.clock()
        Page:timer()
    end

    if ui.previousState == ui.state then return end
    ui.previousState = ui.state

    --rf2.print("*** Loading UI for ui.state " .. tostring(ui.state))

    if ui.state == ui.status.mainMenu then
        ui.showMainMenu()
    elseif ui.state == ui.status.pages then
        ui.loadPage()
    end
end

ui.incPage = function(inc)
    if not PageFiles then return end
    CurrentPageIndex = rf2.executeScript("F/incMax")(CurrentPageIndex, inc, #PageFiles)
    rf2.mspQueue:clear()
    ui.loadPage()
end

ui.onPageReady = function(page)
    page.isReady = true
    ui.showPage()
end

return ui