local function show(menu)
    lvgl.clear()

    local children = {}
    local w = (LCD_W - 30) / 3
    local h = 50

    for i = 1, #menu.items do
        local item = menu.items[i]
        children[#children + 1] = {
            type = "button",
            x = 6 + #children % 3 * (w + 4),
            y = 6 + math.floor(#children / 3) * (h + 4),
            w = w,
            h = h,
            text = item.text,
            press = function()
                if item.click then
                    item.click(i)
                end
            end
        }
    end

    local lyt = {
        {
            type = "page",
            title = menu.title,
            subtitle = menu.subtitle,
            icon = rf2.baseDir .. "rf2.png",
            back = function()
                if menu.back then
                    menu.back()
                end
            end,
            children = children
        },
    }

    lvgl.build(lyt)
end

return { show = show }