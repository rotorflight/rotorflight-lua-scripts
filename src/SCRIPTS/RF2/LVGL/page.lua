local lvglHelper = rf2.executeScript("LVGL/helper")

local function show(page)
    lvgl.clear()

    local function formatVal(val, field)
        if field.data.scale then
            val = val / field.data.scale
            val = math.floor(val*100 + 0.5) / 100
        end
        if (field.data.scale or 1) <= 1 then
            val = math.floor(val)
        end

        return tostring(val) .. ((field.data and field.data.unit) or "")
    end

    local function fieldIsButton(f)
        return f.t and string.sub(f.t, 1, 1) == "[" and not f.data
    end

    local children = {}

    -- OFFSET: Schiebt den Inhalt unter die Toolbar (35px Höhe + Abstand)
    local CONTENT_OFFSET = 25 

    local specialFunction = nil

    -- 1. LABELS ERSTELLEN
    for i = 1, #page.labels do
        local label = page.labels[i]
        children[#children + 1] = {
            type = "label",
            x = label.x,
            y = label.y + 3 + CONTENT_OFFSET, 
            text = function() return label.t end,
            font = (not (label.bold == false)) and BOLD or 0
        }
    end

    -- 2. FELDER ERSTELLEN
    for i = 1, #page.fields do
        local field = page.fields[i]
        local fieldY = field.y + CONTENT_OFFSET

        if field.t then
            children[#children + 1] = {
                type = "label",
                x = field.x,
                y = fieldY,
                text = field.t,
            }
        end

        if field.special then
            rf2.log("Found special field at index " .. i)
            specialFunction = function()
                    if field.preEdit then field.preEdit(field, page) end
            end
        elseif fieldIsButton(field) then
            children[#children + 1] = {
                type = "button",
                x = field.x,
                y = fieldY,
                w = field.w or 200,
                text = function()
                    local s = string.gsub(field.t, "[%[%]]", "") 
                    return  s
                end,
                press = function()
                    if field.preEdit then field.preEdit(field, page) end
                end,
            }
        elseif field.data and field.data.value and type(field.data.value) == "string" then
            local child
            if field.readOnly then
                child = {
                    type = "label",
                    x = field.sp or field.x,
                    y = fieldY + 3,
                    text = field.data.value,
                }
            else
                child = {
                    type = "textEdit",
                    x = field.sp or field.x,
                    y = fieldY,
                    w = field.w or 125,
                    value = field.data.value,
                    length = field.data.max or 10,
                }
            end
            children[#children + 1] = child
            
        elseif field.data and field.data.value and type(field.data.value) == "number" then
            local child
            if field.readOnly then
                child = {
                    type = "label",
                    x = field.sp or field.x,
                    y = fieldY + 3,
                    text = function()
                        return formatVal(field.data.value, field)
                    end,
                }
            elseif field.data.table then
                local choiceTable = lvglHelper.toChoiceTable(field.data.table, field.data.max + 1)
                child = {
                    type = "choice",
                    values = choiceTable.values,
                    x = field.sp or field.x,
                    y = fieldY,
                    w = field.w or 100,
                    get = function() return choiceTable:getChoiceKey(field.data.value) end,
                    set = function(val)
                        field.data.value = choiceTable:getOriginalKey(val)
                        if field.postEdit then field:postEdit(page) end
                    end,
                }
            else
                child = {
                    type = "numberEdit",
                    x = field.sp or field.x,
                    y = fieldY,
                    w = field.w or 75,
                    get = function() return field.data.value / (field.data.mult or 1) end,
                    set = function(val)
                        local newVal = math.ceil(val * (field.data.mult or 1))
                        if field.change then field:change(newVal, page) end
                        field.data.value = newVal
                    end,
                    display = function(val) return formatVal(val * (field.data.mult or 1), field) end,
                }
                if field.data.min then child.min = field.data.min / (field.data.mult or 1) end
                if field.data.max then child.max = field.data.max / (field.data.mult or 1) end
            end
            children[#children + 1] = child
        end
    end

    -- 3. SKALIERUNG ANWENDEN (Nur auf den alten Inhalt!)
    for i = 1, #children do
        local child = children[i]
        child.x = child.x * 1.75
        child.y = (child.y - rf2.radio.yMinLimit + 5) * 1.75
    end

    -- 4. TOOLBAR ERSTELLEN (Manuelle Positionierung)
    
    local toolbar = {
        type = "button", 
        clickable = false, -- Nur als Hintergrund
        
        x = 0,
        y = 0,          
        w = LCD_W,      
        h = 42,         
        
        color = lcd.RGB(48, 48, 48), -- Dunkelgrau
        padAll = 0,     -- Kein Padding, wir positionieren selbst

        children = {}
    }

    -- 4.1 BUTTONS VON RECHTS NACH LINKS AUFBAUEN
    -- Wir starten am rechten Bildschirmrand und gehen schrittweise nach links.
    
    local currentX = LCD_W - 5 -- Startpunkt: 5px Abstand vom rechten Rand
    local btnHeight = 30       -- Höhe der Buttons
    local btnY = 2             -- Y-Position in der Toolbar (zentriert bei h=35)

    -- A) HELP BUTTON (?) (Ganz rechts)
    if page.help then
        local btnW = 40
        currentX = currentX - btnW - 10 -- X-Position berechnen
        
        toolbar.children[#toolbar.children + 1] = {
            type = "button",
            text = "?",
            x = currentX, 
            y = btnY,
            w = btnW, 
            h = btnHeight,
            press = function()
                rf2.executeScript("LVGL/messageBox").show(page.help.title, page.help.msg)
            end,
        }
        currentX = currentX - 5 -- Lücke zum nächsten Button
    end

    -- B) TOOLS BUTTON (*) (Links daneben)
    if page.specialFunction then
        local btnW = 40
        
        currentX = currentX - btnW
        if page.help == nil then
            currentX = currentX - 10 -- Abstand, wenn kein Help-Button
        end

        toolbar.children[#toolbar.children + 1] = {
            type = "button",
            text = "*", 
            x = currentX, 
            y = btnY,
            w = btnW, 
            h = btnHeight,
            press = function()
                page.specialFunction()
            end,
        }
        currentX = currentX - 5 -- Lücke
    end

    -- TOOLS Reload (*) (Links daneben)
    -- if page.read then
    --     local btnW = 40
        
    --     currentX = currentX - btnW
    --     if page.help == nil then
    --         currentX = currentX - 10 -- Abstand, wenn kein Help-Button
    --     end

    --     toolbar.children[#toolbar.children + 1] = {
    --         type = "button",
    --         text = "\xEF\x80\xA1", 
    --         x = currentX, 
    --         y = btnY,
    --         w = btnW, 
    --         h = btnHeight,
    --         press = function()
    --             page.read()
    --         end,
    --     }
    --     currentX = currentX - 5 -- Lücke
    -- end

    -- C) SAVE BUTTON (Links daneben)
    if page.isReady and not page.readOnly then
        local btnW = 100
        currentX = currentX - btnW
        if page.help == nil and page.tools == nil then
            currentX = currentX - 10 -- Abstand, wenn kein Help und Tools-Button
        end
        
        toolbar.children[#toolbar.children + 1] = {
            type = "button",
            text = rf2.i18n.t("MENU_Save"),
            x = currentX, 
            y = btnY,
            w = btnW, 
            h = btnHeight,
            
            press = function()
                page:write()
            end,
        }
    end

    -- 5. Toolbar ganz am Ende hinzufügen
    children[#children + 1] = toolbar

    local lyt = {
        {
            type = "page",
            title = "Rotorflight " .. rf2.luaVersion,
            subtitle = page.title,
            icon = rf2.baseDir .. "rf2.png",
            back = function()
                if page.back then
                    page.back()
                end
            end,
            children = children
        },
    }

    lvgl.build(lyt)
end

return { show = show }