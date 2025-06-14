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
local mspEscYge = "mspEscYge"
local escParameters = rf2.useApi(mspEscYge).getDefaults()

local function updateRatio(field, page)
    local main = page.fields[17]
    local pinion = page.fields[18]
    local ratio = pinion.data.value ~= 0 and main.data.value / pinion.data.value or 1
    -- update gear ratio label text
    page.labels[9].t = string.format("%.2f:1", ratio)
end

labels[1] = { t = "ESC not ready, waiting...", x = x,       y = incY(lineSpacing) }
labels[2] = { t = "---",                    x = x + indent, y = incY(lineSpacing), bold = false }
labels[3] = { t = "---",                    x = x + indent, y = incY(lineSpacing), bold = false }

fields[1] = { t = "ESC Mode",               x = x,          y = incY(lineSpacing * 2), sp = x + sp, w = 125, data = escParameters.esc_mode }
fields[2] = { t = "Direction",              x = x,          y = incY(lineSpacing), sp = x + sp, data = escParameters.direction }
fields[3] = { t = "BEC",                    x = x,          y = incY(lineSpacing), sp = x + sp, data = escParameters.bec_voltage }

labels[4] = { t = "Protection",             x = x,          y = incY(lineSpacing * 2) }
fields[4] = { t = "Cutoff Handling",        x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 125, data = escParameters.cutoff_handling }
fields[5] = { t = "Cutoff Cell Voltage",    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.cutoff_cell_voltage }
fields[6] = { t = "Current Limit (A)",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.current_limit }

-- Advanced
labels[5] = { t = "Advanced",               x = x,          y = incY(lineSpacing) }
fields[7] = { t = "Min Start Power",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.min_start_power }
fields[8] = { t = "Max Start Power",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.max_start_power }
fields[9] = { t = "Startup Response",       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.startup_response }
fields[10] = { t = "Throttle Response",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.throttle_response }
fields[11] = { t = "Motor Timing",          x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 125, data = escParameters.motor_timing }
fields[12] = { t = "Active Freewheel",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.active_freewheel }
fields[13] = { t = "F3C Autorotation",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.f3c_autorotation }

-- Other
labels[6] = { t = "Governor",               x = x,          y = incY(lineSpacing) }
fields[14] = { t = "P-Gain",                x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.p_gain }
fields[15] = { t = "I-Gain",                x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.i_gain }

labels[7] = { t = "RPM Settings",           x = x,          y = incY(lineSpacing) }
fields[16] = { t = "Motor Pole Pairs",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.motor_pole_pairs }
fields[17] = { t = "Main Teeth",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.main_teeth, change = updateRatio }
fields[18] = { t = "Pinion Teeth",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.pinion_teeth, change = updateRatio }
labels[8] =  { t = "Main : Pinion",         x = x + indent, y = incY(lineSpacing), bold = false }
labels[9] =  { t = "--:--",                 x = x + sp,     y = y, bold = false }

labels[10] = { t = "Throttle Calibration",  x = x,          y = incY(lineSpacing) }
fields[19] = { t = "Stick Zero (us)",       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.stick_zero }
fields[20] = { t = "Stick Range (us)",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.stick_range }

local function receivedEscParameters(page, data)
    if data.esc_signature ~= 165 then -- YGE signature
        page.labels[1].t = "Invalid ESC detected"
    else
        page.labels[1].t = data.escTypeName
        page.labels[2].t = "S/N: " .. data.serial_number
        page.labels[3].t = "FW: " .. data.firmware_version / 100000
    end

    -- The read-only flag is set when the ESC is connected to an RX pin instead of a TX pin in half-duplex mode. Only supported by YGE.
    page.readOnly = bit32.band(data.command, 0x40) == 0x40
    updateRatio(nil, page)
    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi(mspEscYge).read(receivedEscParameters, self, escParameters)
    end,
    write = function(self)
        rf2.useApi(mspEscYge).write(escParameters)
        rf2.settingsSaved(false, false)
    end,
    title       = "YGE ESC",
    labels      = labels,
    fields      = fields,
    readOnly    = true
}
