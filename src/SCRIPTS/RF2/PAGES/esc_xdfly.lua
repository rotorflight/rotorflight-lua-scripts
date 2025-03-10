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

labels[#labels + 1] = { t = "Basic",               x = x,          y = inc.y(lineSpacing * 2) }
fields[#fields + 1] = { t = "LV BEC voltage",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.lv_bec_voltage }
fields[#fields + 1] = { t = "HV BEC voltage",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.hv_bec_voltage }
fields[#fields + 1] = { t = "Motor direction",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.motor_direction }
fields[#fields + 1] = { t = "LED Colour",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.led_color }
fields[#fields + 1] = { t = "Smart Fan",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.smart_fan }

labels[#labels + 1] = { t = "Advanced",            x = x,          y = inc.y(lineSpacing * 2) }
fields[#fields + 1] = { t = "Timing",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.timing }
fields[#fields + 1] = { t = "Startup Power",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.startup_power }
fields[#fields + 1] = { t = "Acceleration",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.acceleration }
fields[#fields + 1] = { t = "Brake Type",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.brake_type }
fields[#fields + 1] = { t = "Brake Force",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.brake_force }
fields[#fields + 1] = { t = "SR Function",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.sr_function }
fields[#fields + 1] = { t = "Capacity Correctn",   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.capacity_correction }
fields[#fields + 1] = { t = "Auto Restart Time",   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.auto_restart_time }
fields[#fields + 1] = { t = "Cell Cutoff",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.cell_cutoff }

labels[#labels + 1] = { t = "Governor",            x = x,          y = inc.y(lineSpacing * 2) }
fields[#fields + 1] = { t = "Mode",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.governor }
fields[#fields + 1] = { t = "Gov-P",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.gov_p }
fields[#fields + 1] = { t = "Gov-I",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.gov_i }
fields[#fields + 1] = { t = "Pole pairs",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = escParameters.motor_poles }

local function receivedEscParameters(page)
    page.labels[1].t = escParameters.modelName
    page.labels[2].t = escParameters.firmwareVersion
    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        mspEsc.read(escParameters, receivedEscParameters, self)
    end,
    write = function(self)
        mspEsc.write(escParameters)
        rf2.settingsSaved()
    end,
    title       = "XDFly Setup",
    reboot      = false,
    eepromWrite = true,
    labels      = labels,
    fields      = fields,
}
