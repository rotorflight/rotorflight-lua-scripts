local lvglHelper = rf2.executeScript("LVGL/helper")

local function show(page)
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
    for i, label in ipairs(page.labels) do
        children[#children + 1] = {
            type = "label",
            x = label.x,
            y = label.y + 3,
            --text = label.t, -- no updates
            text = function() return label.t end, -- does update
            font = (not (label.bold == false)) and BOLD or 0
        }
    end

    for i, field in ipairs(page.fields) do
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
                    local s = string.gsub(field.t, "[%[%]]", "") -- remove brackets around [button]
                    return  s
                end,
                press = function()
                    if field.preEdit then field.preEdit(field, page) end
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
                        field.data.value = choiceTable:getOriginalKey(val)
                        if field.postEdit then
                            field:postEdit(page)
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
                            field:change(val, page)
                        end
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