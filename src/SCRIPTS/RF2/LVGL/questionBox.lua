local function show(title, text, items)
    rf2.print("Showing message: " .. title .. " - " .. text .. " with " .. #items .. " items"   )
    local dg = lvgl.dialog({ title = title, w = 300, h = 200 })
    local lyt = {
        { type = "label",
        --align = VCENTER + CENTER,
        text = text, w = 280 },
    }
    local margin = 10
    local gap = 10
    local button_w = (300 - 2 * margin - (#items - 1) * gap) / #items
    local y = 120
    for i = 1, #items do
        local item = items[i]
        rf2.log("Adding item " .. i .. ": " .. item.text)
        local x = margin + (i - 1) * (button_w + gap)
        lyt[#lyt + 1] = {
            type = "button", text = item.text, x = x, y = y, w = button_w,
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
