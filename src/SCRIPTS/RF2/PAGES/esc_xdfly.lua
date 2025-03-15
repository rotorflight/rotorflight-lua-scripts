local template = assert(rf2.loadScript(rf2.radio.template))()
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
local mspEsc = rf2.useApi("mspEscXdfly")
local escParameters = mspEsc.getDefaults()

labels[1] = { t = "ESC not ready, waiting...",     x = x,          y = inc.y(lineSpacing) }
labels[2] = { t = "---",                           x = x + indent, y = inc.y(lineSpacing), bold = false }
fields[1] = { t = nil, x = 0, y = 0, data = nil, readOnly = true } -- dummy field since ui.lua expects at least one field

local function addField(text, data)
    if not data.hidden then
        fields[#fields + 1] = { t = text, x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = data }
    end
end

local function receivedEscParameters(page)
    page.labels[1].t = escParameters.modelName
    page.labels[2].t = escParameters.firmwareVersion

    labels[#labels + 1] = { t = "Basic", x = x, y = inc.y(lineSpacing * 2) }
    addField("Motor direction", escParameters.motor_direction)
    addField("LV BEC voltage", escParameters.lv_bec_voltage)
    addField("HV BEC voltage", escParameters.hv_bec_voltage)
    addField("Cell cutoff", escParameters.cell_cutoff)

    labels[#labels + 1] = { t = "Governor", x = x, y = inc.y(lineSpacing * 2) }
    addField("Mode", escParameters.governor)
    addField("P-gain", escParameters.gov_p)
    addField("I-gain", escParameters.gov_i)
    addField("Pole pairs", escParameters.pole_pairs)

    labels[#labels + 1] = { t = "Advanced", x = x, y = inc.y(lineSpacing * 2) }
    addField("Timing", escParameters.timing)
    addField("Startup power", escParameters.startup_power)
    addField("Acceleration", escParameters.acceleration)
    addField("Auto restart time", escParameters.auto_restart_time)
    addField("Active freewheel.", escParameters.sr_function)
    addField("Brake type", escParameters.brake_type)
    addField("Brake force", escParameters.brake_force)
    addField("Capacity correct.", escParameters.capacity_correction)
    addField("LED color", escParameters.led_color)
    addField("Smart fan", escParameters.smart_fan)

    rf2.setCurrentField()

    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        mspEsc.read(escParameters, receivedEscParameters, self)
    end,
    write = function(self)
        mspEsc.write(escParameters)
        rf2.storeCurrentField()
        rf2.settingsSaved()
    end,
    title       = "XDFly Setup",
    reboot      = false,
    eepromWrite = false,
    labels      = labels,
    fields      = fields,
}
