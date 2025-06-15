local ui = rf2.executeScript("ui_lvgl_framework")

local IsInitialized = false
local InitTask
local IgnoreNextKeyEvent = false

local function run(event, touchState)
    ui.update()

    if not IsInitialized then
        rf2.mspQueue.maxRetries = -1 -- retry indefinitely
        InitTask = InitTask or rf2.executeScript("ui_init")
        local gotApiVersion = InitTask.f()
        ui.setWaitMessage(InitTask.t)
        if not gotApiVersion then
            return 0
        end
        InitTask = nil
        ui.clearWaitMessage()
        ui.loadMainMenu()
        ui.showMainMenu()
        IsInitialized = true
    end

    if ui.state == ui.status.exit then
        return 2
    end

    -- if event and event ~= 0 then
    --     rf2.print(" Event: " .. string.format("0x%X", event))
    -- end

    if event then
        if event == EVT_EXIT_BREAK and ui.state == ui.status.pages then
            -- Always enable exiting a page with the return key.
            rf2.mspQueue:clear()
            ui.showMainMenu()
        end

        if event == 0x20D or event == EVT_VIRTUAL_PREV_PAGE or event == EVT_VIRTUAL_NEXT_PAGE then
            -- For some reason the tool gets all key events twice, so we need to ignore the second one.
            if not IgnoreNextKeyEvent then
                IgnoreNextKeyEvent = true
                if event == 0x20D then -- SYS break
                    ui.showPopupMenu()
                elseif event == EVT_VIRTUAL_PREV_PAGE then
                    ui.incPage(-1)
                elseif event == EVT_VIRTUAL_NEXT_PAGE then
                    ui.incPage(1)
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
rf2.reloadPage = ui.loadPage
rf2.reloadMainMenu = ui.loadMainMenu
rf2.setWaitMessage = ui.setWaitMessage
rf2.clearWaitMessage = ui.clearWaitMessage
rf2.settingsSaved = ui.saveSettingsToEeprom
rf2.onPageReady = ui.onPageReady

-- Return the run function to be called by the RF2 tool
return run
