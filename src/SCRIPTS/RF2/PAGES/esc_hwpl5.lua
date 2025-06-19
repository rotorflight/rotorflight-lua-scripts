local template = assert(rf2.loadScript(rf2.radio.template))()
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
local mspEscHwPl5 = "mspEscHwPl5"
local escParameters = rf2.useApi(mspEscHwPl5).getDefaults()

labels[1] = { t = "ESC not ready, waiting...", x = x,   y = incY(lineSpacing) }
labels[2] = { t = "---",                x = x + indent, y = incY(lineSpacing), bold = false }
labels[3] = { t = "---",                x = x + indent, y = incY(lineSpacing), bold = false }

fields[1] = { t = "Flight Mode",        x = x,          y = incY(lineSpacing * 2), sp = x + sp, w = 125, data = escParameters.flight_mode }
fields[2] = { t = "Rotation",           x = x,          y = incY(lineSpacing), sp = x + sp,     data = escParameters.rotation }

labels[4] = { t = "Voltage",            x = x,          y = incY(lineSpacing * 2) }
fields[3] = { t = "BEC Voltage",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.bec_voltage }
fields[4] = { t = "Lipo Cell Count",    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.lipo_cell_count }
fields[5] = { t = "Volt Cutoff Type",   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.cutoff_type }
fields[6] = { t = "Cuttoff Voltage",    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.cutoff_voltage }

labels[5] = { t = "Governor",           x = x,          y = incY(lineSpacing) }
fields[7] = { t = "P-Gain",             x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.gov_p_gain }
fields[8] = { t = "I-Gain",             x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.gov_i_gain }

labels[6] = { t = "Soft Start",         x = x,          y = incY(lineSpacing) }
fields[9] = { t = "Startup Time",       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.startup_time }
fields[10] = { t = "Restart Time",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.restart_time }
fields[11] = { t = "Auto Restart",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.auto_restart }

labels[7] = { t = "Motor",              x = x,          y = incY(lineSpacing) }
fields[12] = { t = "Timing",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.timing }
fields[13] = { t = "Startup Power",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.startup_power }
fields[14] = { t = "Active Freewheel",  x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.active_freewheel }
fields[15] = { t = "Brake Type",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.brake_type }
fields[16] = { t = "Brake Force %",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.brake_force }

local function receivedEscParameters(page, data)
    if data.esc_signature.value ~= 253 then -- Hobbywing Platinum V5 signature
        page.labels[1].t = "Invalid ESC detected"
    else
        page.labels[1].t = data.esc_type.value
        page.labels[2].t = "HW: " .. data.hardware_version.value
        page.labels[3].t = "FW:" .. data.firmware_version.value
    end

    page.readOnly = false     -- enable 'Save Page'
    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi(mspEscHwPl5).read(receivedEscParameters, self, escParameters)
    end,
    write = function(self)
        rf2.useApi(mspEscHwPl5).write(escParameters)
        rf2.settingsSaved(false, false)
    end,
    title       = "Platinum V5 Setup",
    labels      = labels,
    fields      = fields,
    readOnly    = true
}
