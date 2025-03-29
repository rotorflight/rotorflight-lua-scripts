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
local mspEscFlyrotor = "mspEscFlyrotor"
local escParameters = rf2.useApi(mspEscFlyrotor).getDefaults()

labels[#labels + 1] = { t = "ESC not ready, waiting...", x = x,          y = incY(lineSpacing) }
labels[#labels + 1] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }
labels[#labels + 1] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }
labels[#labels + 1] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }

-- Basic
labels[#labels + 1] = { t = "Basic",                     x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "ESC Mode",                  x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.esc_mode }
fields[#fields + 1] = { t = "Cell Count [S]",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.cell_count }
fields[#fields + 1] = { t = "BEC Voltage",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.bec_voltage }
fields[#fields + 1] = { t = "Motor direction",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.motor_direction }
fields[#fields + 1] = { t = "Soft start",                x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.soft_start }
fields[#fields + 1] = { t = "Fan control",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.fan_control }

-- Advanced
labels[#labels + 1] = { t = "Advanced",                  x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Low voltage",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.low_voltage }
fields[#fields + 1] = { t = "Temperature",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.temperature }
fields[#fields + 1] = { t = "Timing angle",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.timing }
fields[#fields + 1] = { t = "Starting torque",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.starting_torque }
fields[#fields + 1] = { t = "Response speed",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.response_speed }
fields[#fields + 1] = { t = "Buzzer volume",             x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.buzzer_volume }
fields[#fields + 1] = { t = "Current gain",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.current_gain }

-- Esc Governor
labels[#labels + 1] = { t = "Esc Governor",              x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Gov P-Gain",                x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.p_gain }
fields[#fields + 1] = { t = "Gov I-Gain",                x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.i_gain }
fields[#fields + 1] = { t = "Gov D-Gain",                x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.d_gain }
fields[#fields + 1] = { t = "Motor ERPM Max",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.max_motor_erpm }

-- Other
labels[#labels + 1] = { t = "Other",                     x = x, y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Throttle Protocol",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.throttle_protocol }
fields[#fields + 1] = { t = "Tele Protocol",             x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.telemetry_protocol }
fields[#fields + 1] = { t = "LED color",                 x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.led_color }
fields[#fields + 1] = { t = "Motor temp sensor",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.motor_temp_sensor }
fields[#fields + 1] = { t = "Motor temperture",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.motor_temp }
fields[#fields + 1] = { t = "Capacity Cut-off",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.capacity_cutoff }


local function receivedEscParameters(page, data)
    if data.esc_signature ~= 115 then -- Flyrotor signature
        page.labels[1].t = "Invalid ESC detected"
    else
        page.labels[1].t = string.format("FLYROTOR %dA", data.amperage)
        page.labels[2].t = string.format("S/N: %08X%08X", data.serial_number1, data.serial_number2)
        page.labels[3].t = string.format("HW: 1.%d - IAP: %d.%d.%d", data.hw_version, data.iap_major, data.iap_minor, data.iap_patch)
        page.labels[4].t = string.format("FW: %d.%d.%d", data.fw_major, data.fw_minor, data.fw_patch)
        page.readOnly = bit32.band(data.command, 0x40) == 0x40
    end

    page.isReady = true
    rf2.lcdNeedsInvalidate = true
end

return {
    read = function(self)
        rf2.useApi(mspEscFlyrotor).read(receivedEscParameters, self, escParameters)
    end,
    write = function(self)
        rf2.useApi(mspEscFlyrotor).write(escParameters)
        rf2.settingsSaved()
    end,
    eepromWrite = false,
    reboot      = false,
    title       = "FLYROTOR Setup",
    labels      = labels,
    fields      = fields,
    readOnly    = true
}
