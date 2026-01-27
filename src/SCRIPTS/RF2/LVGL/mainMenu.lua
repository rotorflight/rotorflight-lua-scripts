local function show(menu)
    lvgl.clear()

    local children = {}
    local w = (LCD_W - 30) / 3
    local h = 50

    -- --- FINE TUNING ---
    local OFFSET_X = -6 -- Horizontal fits perfectly
    local OFFSET_Y = 8 -- Correction to move text down

    for i = 1, #menu.items do
        local item = menu.items[i]

        -- 1. Container Box
        local content_box = {
            type = "box",
            w = w,
            h = h,

            x = OFFSET_X,
            y = OFFSET_Y,

            -- Center content
            flexFlow = lvgl.FLOW_ROW,
            flexAlignMain = lvgl.FLEX_ALIGN_CENTER,
            flexAlignCross = lvgl.FLEX_ALIGN_CENTER,
            flexGap = 5,

            children = {}
        }

        -- 2. Fill content into the box
        if item.icon and item.icon ~= "" then
            if string.find(item.icon, ".png") then
                -- >>> IMAGE ICON (.png) <<<
                content_box.children[#content_box.children + 1] = {
                    type = "image",
                    file = item.icon,
                    w = 16,
                    h = 16
                }
                -- Text next to it
                content_box.children[#content_box.children + 1] = {
                    type = "label",
                    text = item.text,
                    color = lcd.RGB(255, 255, 255)
                }
            else
                -- >>> SYMBOL ICON (FontAwesome) <<<
                content_box.children[#content_box.children + 1] = {
                    type = "label",
                    text = item.icon .. " " .. item.text,
                    color = lcd.RGB(255, 255, 255) -- White
                }
            end
        else
            -- >>> NO ICON (Text Only) <<<
            content_box.children[#content_box.children + 1] = {
                type = "label",
                text = item.text,
                color = lcd.RGB(255, 255, 255) -- White
            }
        end

        -- 3. CREATE BUTTON
        children[#children + 1] = {
            type = "button",
            x = 6 + #children % 3 * (w + 4),
            y = 6 + math.floor(#children / 3) * (h + 4),
            w = w,
            h = h,
            color = lcd.RGB(48, 48, 48), -- Dark Gray
            press = function()
                if item.click then
                    item.click(i)
                end
            end,
            children = {content_box}
        }
    end

    local lyt = {{
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
    }}

    lvgl.build(lyt)
end

return {
    show = show
}
