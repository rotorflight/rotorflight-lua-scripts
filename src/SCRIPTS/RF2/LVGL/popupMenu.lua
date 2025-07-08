local function show(menu)
    local dg = lvgl.dialog({ title = menu.title, h = 75 + #menu.items * 50 })
    local w = 200
    local x = LCD_W / 2 - w / 2 - 50
    local lyt = {}

    for i, item in ipairs(menu.items) do
        local y = 25 + (i - 1) * 50
        lyt[#lyt + 1] = {
            type = "button", text = item.text, x = x, y = y, w = w,
            press = function()
                dg:close()
                if item.click then
                    item.click(i)
                end
            end
        }
    end

    dg:build(lyt)
end

return { show = show }
