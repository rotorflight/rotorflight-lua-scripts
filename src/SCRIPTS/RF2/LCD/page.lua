local lcdShared, Page = ...

local t = { }
local currentField = 1
local pageScrollY = 0
local scrollSpeedTS = 0

local function fieldIsButton(f)
    return f.t and string.sub(f.t, 1, 1) == "[" and not f.data
end

t.draw = function(pageState)
    if not Page or not Page.fields or #Page.fields == 0 then return end

    lcd.clear()

    if currentField > #Page.fields then currentField = #Page.fields end
    local yMinLim = rf2.radio.yMinLimit
    local yMaxLim = rf2.radio.yMaxLimit
    local currentFieldY = Page.fields[currentField].y
    local textOptions = rf2.radio.textSize + lcdShared.textOptions
    local boldTextOptions = (rf2.isEdgeTx and (TEXT_COLOR or COLOR_THEME_SECONDARY1) and BOLD + (TEXT_COLOR or COLOR_THEME_SECONDARY1)) or textOptions
    if currentFieldY <= Page.fields[1].y then
        pageScrollY = 0
    elseif currentFieldY - pageScrollY <= yMinLim then
        pageScrollY = currentFieldY - yMinLim
    elseif currentFieldY - pageScrollY >= yMaxLim then
        pageScrollY = currentFieldY - yMaxLim
    end
    for i = 1, #Page.labels do
        local f = Page.labels[i]
        local y = f.y - pageScrollY
        if y >= 0 and y <= LCD_H then
            lcd.drawText(f.x, y, f.t, (not (f.bold == false)) and boldTextOptions or textOptions)
        end
    end
    for i = 1, #Page.fields do
        local val = "---"
        local f = Page.fields[i]
        local valueOptions = textOptions
        if i == currentField then
            valueOptions = valueOptions + INVERS
            if pageState == lcdShared.pageStatus.editing then
                valueOptions = valueOptions + BLINK
            end
        end
        if f.data and f.data.value then
            val = f.data.value
            if type(val) == "number" then
                if f.data.scale then
                    val = val / f.data.scale
                end
                if (f.data.scale or 1) <= 1 then
                    val = math.floor(val)
                end
            end
            if f.data.table and f.data.table[val] then
                val = f.data.table[val]
            end
        end
        local y = f.y - pageScrollY
        if y >= 0 and y <= LCD_H then
            if fieldIsButton(f) then
                val = f.t
            elseif f.t then
                lcd.drawText(f.x, y, f.t, textOptions)
            end
            val = val .. ((f.data and f.data.unit) or "")
            lcd.drawText(f.sp or f.x, y, val, valueOptions)
        end
    end
    lcdShared.drawScreenTitle(Page.title)
end

local function clipValue(val, min, max)
    if val < min then
        val = min
    elseif val > max then
        val = max
    end
    return val
end

local function incField(inc)
    currentField = clipValue(currentField + inc, 1, #Page.fields)
end

local function incValue(inc)
    local f = Page.fields[currentField]
    if f.data then
        local mult = f.data.mult or 1
        f.data.value = clipValue(f.data.value + inc*mult, (f.data.min or 0), (f.data.max or 255))
        f.data.value = math.floor(f.data.value/mult + 0.5)*mult
    end
    if f.change then
        f:change(Page)
    end
end

local function requestPage()
    if not Page.reqTS or Page.reqTS + 5 <= rf2.clock() then
        --rf2.print("Requesting page...")
        Page.reqTS = rf2.clock()
        if Page.read then
            Page:read()
        end
    end
end

t.update = function(pageState, event)
    t.draw(pageState)

    if pageState == lcdShared.pageStatus.display then
        if Page and (event == EVT_VIRTUAL_PREV or event == EVT_VIRTUAL_PREV_REPT) then
            incField(-1)
        elseif Page and (event == EVT_VIRTUAL_NEXT or event == EVT_VIRTUAL_NEXT_REPT) then
            incField(1)
        elseif Page and event == EVT_VIRTUAL_ENTER then
            local f = Page.fields[currentField]
            if Page.isReady and not f.readOnly then
                if not fieldIsButton(Page.fields[currentField]) then
                    pageState = lcdShared.pageStatus.editing
                end
                if Page.fields[currentField].preEdit then
                    Page.fields[currentField]:preEdit(Page)
                end
            end
        end
    elseif pageState == lcdShared.pageStatus.editing then
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
            pageState = lcdShared.pageStatus.display
        elseif event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
            incValue(1 * scrollSpeedMultiplier)
        elseif event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
            incValue(-1 * scrollSpeedMultiplier)
        end
    end

    if Page and Page.timer and (not Page.lastTimeTimerFired or Page.lastTimeTimerFired + 0.5 < rf2.clock()) then
        Page.lastTimeTimerFired = rf2.clock()
        Page:timer()
    end

    if not Page.isReady and pageState == lcdShared.pageStatus.display then
        requestPage()
    end

    return pageState
end

return t
