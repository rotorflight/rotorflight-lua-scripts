local template = rf2.executeScript(rf2.radio.template)
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
template = nil
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val)
    y = y + val
    return y
end
local labels = {}
local help = {}
local fields = {}
local specialFunction = nil
local mspAccTrim = "mspAccTrim"
local data = rf2.useApi(mspAccTrim).getDefaults()
local mspCalibrating = "mspAccCalibration"
local t = rf2.i18n.t

help = {
    title = t("ACC_Help_title"),
    msg = t("ACC_Help_text")
}

labels[#labels + 1] = {
    t = t("ACC_Label"),
    x = x,
    y = incY(lineSpacing)
}
fields[#fields + 1] = {
    t = t("ACC_Roll"),
    x = x + indent,
    y = incY(lineSpacing),
    sp = x + sp,
    data = data.roll_trim
}
fields[#fields + 1] = {
    t = t("ACC_Pitch"),
    x = x + indent,
    y = incY(lineSpacing),
    sp = x + sp,
    data = data.pitch_trim
}

local function onAccCalibratingDone(msg)
    rf2.log("Acc calibration done, msg: " .. tostring(msg))
    rf2.clearWaitMessage()
end

local showPopupMenu = function()
    local items = {}

    items[#items + 1] = {
        text = t("MENU_Yes"),
        click = function() 
            rf2.setWaitMessage(t("ACC_Calibrating"))
            rf2.useApi(mspCalibrating).calibrate(onAccCalibratingDone, "OK")
        end
    }

    items[#items + 1] = {
        text = t("MENU_No"),
        click = nil
    }
    rf2.executeScript("LVGL/questionBox").show(help.title, t("ACC_Calibration_Question"), items)
end

specialFunction = showPopupMenu

local function receivedData(page)
    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi(mspAccTrim).read(receivedData, self, data)
    end,
    write = function(self)
        rf2.useApi(mspAccTrim).write(data)
        rf2.settingsSaved(true, false)
    end,
    title = t("ACC_Title"),
    labels = labels,
    fields = fields,
    help = help,
    specialFunction = specialFunction,
    
}
