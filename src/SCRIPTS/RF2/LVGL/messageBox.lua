local function show(title, text)
    --rf2.print("Showing message: " .. title .. " - " .. text)
    local dg = lvgl.dialog({ title = title, w = 300, h = 200 })
    local lyt = {
        { type = "label", align = VCENTER + CENTER, text = text, w = 290 },
    }

    dg:build(lyt)
end

return { show = show }
