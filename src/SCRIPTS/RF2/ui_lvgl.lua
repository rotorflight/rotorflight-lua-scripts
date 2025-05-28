local lvglHelper = rf2.useScript("lvglHelper")

local LUA_VERSION = "2.2.0-RC5"

local uiStatus =
{
    init        = 1,
    mainMenu    = 2,
    pages       = 3,
    exit        = 5
}

local ui = {
    state = uiStatus.init,
    previousState = nil,
    wait = {}
}

local uiInit

local sysPressCounter = 0
local Page = nil

rf2.showMessage = function(title, text)
    rf2.print(tostring(title) .. " - " .. tostring(text))
end

rf2.hideMessage = function()
    rf2.print("Message hidden")
end

rf2.setWaitMessage = function(message)
    ui.wait.message = message
end

rf2.clearWaitMessage = function()
    if not ui.wait.message then return end
    ui.wait.message = nil
    ui.wait.shown = false
    ui.previousState = nil -- force redraw of previous ui
end

local function showWaitMessage()
    lvgl.clear();

    local lyt = {
        {
            type = "page",
            title = "Rotorflight",
            subtitle = Page and Page.title or "",
            --icon = "/SCRIPTS/TOOLS/LVGLIMG/smile.png",
            back = function() ui.show() end,
            children = {
                {
                    type = "label",
                    x = 70,
                    y = 16,
                    color = BLACK,
                    font = DBLSIZE,
                    text = ui.wait.message or ""
                },
            },
        },
    }

    lvgl.build(lyt)
end

rf2.setCurrentField = function(field)
    -- only for compatibility with ui_lcd at the moment
    --rf2.print("Current field set to: " .. tostring(field))
end

local function rebootFc()
    --rf2.setWaitMessage("Rebooting FC...") -- TODO?
    rf2.mspQueue:add({
        command = 68, -- MSP_REBOOT
        processReply = function(self, buf)
            --ui.previousState = nil
        end,
        simulatorResponse = {}
    })
    if Page then
        Page:read()
    else
        rf2.loadPageFiles()
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
                        rf2.showMessage("Save warning", "Settings will be saved\nafter disarming.")
                        rf2.saveWarningShown = true
                    else
                        Page:read()
                    end
                else
                    rf2.showMessage("Save error", "Make sure your heli\nis disarmed.")
                end
            end,
            simulatorResponse = {}
        }
        rf2.mspQueue:add(mspEepromWrite)
    end
end

local function buildPopupMenu()
    local dg = lvgl.dialog({ title = "Menu", close = function() print("Closed") end })
    local w = 200
    local x = LCD_W / 2 - w / 2 - 50

    local lyt = {}
    if Page and not Page.readOnly == true then
        lyt[#lyt + 1] = {
            type = "button",
            text = "Save",
            x = x,
            y = 25,
            w = w,
            press = function()
                dg:close()
                Page:write()
            end
        }
    end

    if Page then
        lyt[#lyt + 1] = {
            type = "button",
            text = "Reload",
            x = x,
            y = 75,
            w = w,
            press = function()
                Page:read()
                dg:close()
            end
        }
    end

    lyt[#lyt + 1] = {
        type = "button", text = "Reboot", x = x, y = 125, w = w,
        press = function(self)
            dg:close()
            rebootFc()
        end
    }

    dg:build(lyt)
end

local function buildPage()
    lvgl.clear()

    local function formatVal(val, field)
        if field.data.scale then
            val = val / field.data.scale
        end
        if (field.data.scale or 1) <= 1 then
            val = math.floor(val)
        end

        return tostring(val) .. ((field.data and field.data.unit) or "")
    end

    local function fieldIsButton(f)
        -- TODO: refactor
        return f.t and string.sub(f.t, 1, 1) == "[" and not f.data
    end

    local children = {}
    for i, label in ipairs(Page.labels) do
        --rf2.print("Label: " .. label.t)
        children[#children + 1] = {
            type = "label",
            x = label.x,
            y = label.y + 3,
            --text = label.t, -- no updates
            text = function() return label.t end, -- does update
            font = (not (label.bold == false)) and BOLD or 0
        }
    end

    for i, field in ipairs(Page.fields) do
        if field.t then
            children[#children + 1] = {
                type = "label",
                x = field.x,
                y = field.y,
                text = field.t,
            }
        end

        if fieldIsButton(field) then
            children[#children + 1] = {
                type = "button",
                x = field.x,
                y = field.y,
                w = field.w or 200,
                text = function()
                    local s = string.gsub(field.t, "[%[%]]", "")
                    return  s
                end,
                press = function()
                    if field.preEdit then field.preEdit(field, Page) end
                end,
            }
        elseif field.data and field.data.value and type(field.data.value) == "number" then
            local child
            if field.readOnly then
                child = {
                    type = "label",
                    x = field.sp or field.x,
                    y = field.y + 3,
                    text = function()
                        return formatVal(field.data.value, field)
                    end,
                }
            elseif field.data.table then
                local choiceTable = lvglHelper.toChoiceTable(field.data.table, field.data.max + 1)
                --rf2.print("Choice with value: " .. tostring(field.data.value))
                child = {
                    type = "choice",
                    --title = "todo",
                    values = choiceTable.values,
                    x = field.sp or field.x,
                    y = field.y,
                    w = field.w or 100,
                    get = function() return choiceTable:getChoiceKey(field.data.value) end,
                    set = function(val)
                        rf2.print(val)
                        field.data.value = choiceTable:getOriginalKey(val)
                        if field.postEdit then
                            field:postEdit(Page)
                        end
                    end,
                }
            else
                child = {
                    type = "numberEdit",
                    x = field.sp or field.x,
                    y = field.y,
                    w = field.w or 75,
                    get = function() return field.data.value end,
                    set = function(val)
                        if field.change then
                            field:change(val, Page)
                        end
                        rf2.print(val)
                        field.data.value = val
                    end,
                    display = function(val)
                        return formatVal(val, field)
                    end,
                }
                if field.data.min then child.min = field.data.min end
                if field.data.max then child.max = field.data.max end
            end

            children[#children + 1] = child
        end
    end

    for _, child in ipairs(children) do
        child.x = child.x * 1.75
        child.y = (child.y - rf2.radio.yMinLimit + 5) * 1.75
    end

    local lyt = {
        {
            type = "page",
            title = "Rotorflight",
            subtitle = Page.title,
            icon = "/SCRIPTS/TOOLS/LVGLIMG/smile.png",
            back = function() rf2.loadPageFiles() end,
            children = children
        },
    }

    lvgl.build(lyt)
    ui.state = uiStatus.pages
end

local function loadPage(pageScript)
    Page = assert(rf2.loadScript("PAGES/" .. pageScript, "cd"))()
    Page:read()
    ui.pageScript = pageScript
end

rf2.onPageReady = function(page)
    page.isReady = true
    Page = page
    buildPage()
end

rf2.reloadPage = function()
    rf2.print("Reloading page: " .. tostring(ui.pageScript))
    loadPage(ui.pageScript)
end

rf2.loadPageFiles = function()
    Page = nil
    local pageFiles = assert(rf2.loadScript("pages.lua"))()

    lvgl.clear();

    local children = {}
    local w = (LCD_W - 30) / 3
    local h = 50
    local x = LCD_W / 2 - w / 2 - 5

    for i, page in ipairs(pageFiles) do
        children[#children + 1] = {
            type = "button",
            x = 6 + #children % 3 * (w + 4),
            y = 6 + #children // 3 * (h + 4),
            w = w,
            h = h,
            text = page.title,
            press = function() loadPage(page.script) end,
        }
    end

    local lyt = {
        {
            type = "page",
            title = "Rotorflight " .. LUA_VERSION,
            subtitle = "Main menu",
            --icon = "/SCRIPTS/TOOLS/LVGLIMG/smile.png",
            back = function() ui.state = uiStatus.exit end,
            --flexFlow = lvgl.FLOW_ROW,
            --flexPad = 10,
            --w = LCD_W,
            children = children
        },
    }

    lvgl.build(lyt)
    ui.state = uiStatus.mainMenu
end

ui.show = function()
    if ui.wait.message and not ui.wait.shown then
        rf2.print("Showing wait message: " .. tostring(ui.wait.message))
        showWaitMessage()
        ui.wait.shown = true
    end

    if ui.previousState == ui.state then return end
    ui.previousState = ui.state

    rf2.print("Loading UI for ui.state" .. tostring(ui.state))

    if ui.state == uiStatus.mainMenu then
        rf2.loadPageFiles()
    elseif ui.state == uiStatus.pages and ui.pageScript then
        loadPage(ui.pageScript)
    end
end

local function run_ui(event, touchState)
    ui.show()

    if ui.state == uiStatus.init then
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

    if event and event ~= 0 then
        rf2.print(" Event: " .. string.format("0x%X", event))
    end

    local evttxt
    if (event == EVT_VIRTUAL_NEXT) or (event == EVT_VIRTUAL_NEXT_PAGE) then
        evttxt = "NEXT"
    elseif (event == EVT_VIRTUAL_PREV) or (event == EVT_VIRTUAL_PREV_PAGE) then
        evttxt = "PREV"
    elseif (event == EVT_TOUCH_BREAK) or (event == EVT_TOUCH_TAP) then
        evttxt = "TOUCH " .. touchState.x .. "," .. touchState.y
    else
        if event ~= 0 then evttxt = event end
    end
    if evttxt then
        rf2.print("Event: " .. evttxt)
    end

    if Page and Page.timer and (not Page.lastTimeTimerFired or Page.lastTimeTimerFired + 0.5 < rf2.clock()) then
        Page.lastTimeTimerFired = rf2.clock()
        Page.timer(Page)
    end

    if event and event == 0x60D then -- SYS
        sysPressCounter = sysPressCounter + 1
        -- for some reason the tool gets all events twice, so we need to ignore the first one
        if sysPressCounter == 2 then
            sysPressCounter = 0
            rf2.print("Creating popup menu")
            buildPopupMenu()
        end
    end

    if getRSSI() == 0 then
        rf2.setWaitMessage("No telemetry")
        ui.showingNoTelemetry = true
    elseif ui.wait.showingNoTelemetry then
        rf2.clearWaitMessage()
        ui.showingNoTelemetry = false
    end

    rf2.mspQueue:processQueue()

    return 0
end

return run_ui
