local template = rf2.executeScript(rf2.radio.template)
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local escParameters = nil

labels[1] = { t = "ESC not ready, waiting...",     x = x,          y = incY(lineSpacing) }
labels[2] = { t = "---",                           x = x + indent, y = incY(lineSpacing), bold = false }
fields[1] = { t = nil, x = 0, y = 0, data = nil, readOnly = true } -- dummy field since ui.lua expects at least one field

local function addField(text, data, w)
    if not data.hidden then
        fields[#fields + 1] = { t = text, x = x + indent, y = incY(lineSpacing), sp = x + sp, w = w, data = data }
    end
end

local function receivedEscParameters(page, data)
    escParameters = data
    page.labels[1].t = escParameters.modelName
    page.labels[2].t = escParameters.firmwareVersion

    labels[#labels + 1] = { t = "Basic", x = x, y = incY(lineSpacing * 2) }
    addField("Motor direction", escParameters.motor_direction)
    addField("LV BEC voltage", escParameters.lv_bec_voltage)
    addField("HV BEC voltage", escParameters.hv_bec_voltage)
    addField("Cell cutoff", escParameters.cell_cutoff)

    labels[#labels + 1] = { t = "Governor", x = x, y = incY(lineSpacing * 2) }
    addField("Mode", escParameters.governor, 125)
    addField("P-gain", escParameters.gov_p)
    addField("I-gain", escParameters.gov_i)
    addField("Pole pairs", escParameters.pole_pairs)

    labels[#labels + 1] = { t = "Advanced", x = x, y = incY(lineSpacing * 2) }
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

    rf2.onPageReady(page)
end

return {
    read = function(self)
        if not self.isReady then rf2.onPageReady(self) end
        rf2.useApi("mspEscXdfly").read(receivedEscParameters, self)
    end,
    write = function(self)
        rf2.useApi("mspEscXdfly").write(escParameters)
        rf2.settingsSaved(false, false)
    end,
    title       = "XDFly Setup",
    labels      = labels,
    fields      = fields,
}
