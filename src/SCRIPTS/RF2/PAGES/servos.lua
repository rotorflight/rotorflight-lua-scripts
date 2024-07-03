local template = assert(rf2.loadScript(rf2.radio.template))()
local mspServos = assert(rf2.loadScript("MSP/mspServos.lua"))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}
local servoConfigs = {}
local selectedServoIndex = 0
local updateSelectedServoConfiguration = false

local  function setValues(servoIndex)
    fields[1].value = servoIndex
    fields[2].data = servoConfigs[servoIndex].mid
    fields[3].data = servoConfigs[servoIndex].min
    fields[4].data = servoConfigs[servoIndex].max
    fields[5].data = servoConfigs[servoIndex].scaleNeg
    fields[6].data = servoConfigs[servoIndex].scalePos
    fields[7].data = servoConfigs[servoIndex].rate
    fields[8].data = servoConfigs[servoIndex].speed
end

-- Field event functions

local function onChangeServo(field, page)
    selectedServoIndex = field.value
    rf2.lastChangedServo = selectedServoIndex
    setValues(selectedServoIndex)
end

local function onPreEditCenter(field, page)
    mspServos.enableServoOverride(selectedServoIndex)
end

local function onChangeCenter(field, page)
    updateSelectedServoConfiguration = true
end

local function onPostEditCenter(field, page)
    mspServos.disableServoOverride(selectedServoIndex)
end

fields[1] = { t = "Servo",      x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 7,     table = { [0] = "ELEVATOR", "CYCL L", "CYCL R", "TAIL" }, postEdit = onChangeServo }
fields[2] = { t = "Center",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, id = "servoMid", preEdit = onPreEditCenter, change = onChangeCenter, postEdit = onPostEditCenter }
fields[3] = { t = "Min",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, id = "servoMin" }
fields[4] = { t = "Max",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, id = "servoMax" }
fields[5] = { t = "Scale neg",  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, id = "servoScaleNeg" }
fields[6] = { t = "Scale pos",  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, id = "servoScalePos" }
fields[7] = { t = "Rate",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, id = "servoRate" }
fields[8] = { t = "Speed",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, id = "servoSpeed" }

local function receivedServoConfigurations(page, configs)
    servoConfigs = configs
    selectedServoIndex = rf2.lastChangedServo or 0
    setValues(selectedServoIndex)
    page.fields[1].max = #configs
    --rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        mspServos.getServoConfigurations(receivedServoConfigurations, self)
    end,
    write = function(self)
        for servoIndex = 0, #servoConfigs do
            mspServos.setServoConfiguration(servoIndex, servoConfigs[servoIndex])
        end
        rf2.settingsSaved()
    end,
    timer = function(self)
        if updateSelectedServoConfiguration then
            mspServos.setServoConfiguration(selectedServoIndex, servoConfigs[selectedServoIndex])
            updateSelectedServoConfiguration = false
        end
    end,
    title       = "Servos",
    reboot      = false,
    eepromWrite = true,
    labels      = labels,
    fields      = fields
}
