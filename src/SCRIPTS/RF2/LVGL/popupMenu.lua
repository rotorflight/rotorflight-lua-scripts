local function show(menu)
    local screenMult = rf2.radio.screenMult or 1
    local buttonW = 200 * screenMult
    local buttonH = 50 * screenMult
    local dialogW = math.min(LCD_W - 50, buttonW * 1.5)
    local dialogH = (#menu.items + 1.5) * buttonH
    local dg = lvgl.dialog({ title = menu.title, w = dialogW,  h =dialogH })
    local buttonX = (dialogW - buttonW) / 2
    local lyt = {}

    for i = 1, #menu.items do
        local item = menu.items[i]
        local buttonY = (25 * screenMult) + (i - 1) * (50 * screenMult)
        lyt[#lyt + 1] = {
            type = "button", text = item.text, x = buttonX, y = buttonY, w = buttonW, h = buttonH - 10,
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
