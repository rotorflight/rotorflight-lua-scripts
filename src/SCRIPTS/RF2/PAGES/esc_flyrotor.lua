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
local mspEscFlyrotor = "mspEscFlyrotor"
local escParameters = rf2.useApi(mspEscFlyrotor).getDefaults()

labels[#labels + 1] = { t = "ESC not ready, waiting...", x = x,          y = incY(lineSpacing) }
labels[#labels + 1] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }
labels[#labels + 1] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }
labels[#labels + 1] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }
labels[#labels + 1] = { t = "---",                       x = x + indent, y = incY(lineSpacing), bold = false }

-- General
labels[#labels + 1] = { t = "General Parameters",        x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "ESC Mode",                  x = x + indent, y = incY(lineSpacing), sp = x + sp, w = 125, data = escParameters.esc_mode }
fields[#fields + 1] = { t = "LiPo Cell Count [S]",       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.cell_count }
fields[#fields + 1] = { t = "Low Voltage Limit",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.low_voltage }
fields[#fields + 1] = { t = "Temperature Limit",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.temperature }
fields[#fields + 1] = { t = "SBEC Voltage",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.bec_voltage }
fields[#fields + 1] = { t = "Electrical Angle",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.timing }
fields[#fields + 1] = { t = "Motor Direction",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.motor_direction }
fields[#fields + 1] = { t = "Starting Power",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.starting_torque }
fields[#fields + 1] = { t = "Response Speed",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.response_speed }
fields[#fields + 1] = { t = "Beeper Volume",             x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.buzzer_volume }
fields[#fields + 1] = { t = "Current Gain",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.current_gain }
fields[#fields + 1] = { t = "Cooling Fan Mode",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.fan_control }

-- Advanced
labels[#labels + 1] = { t = "Advanced Parameters",       x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Soft Start Time",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.soft_start }
fields[#fields + 1] = { t = "Auto Bailout Time",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.auto_restart_time }
fields[#fields + 1] = { t = "Auto Bailout Accel",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.restart_acc }
fields[#fields + 1] = { t = "Governor P",                x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.p_gain }
fields[#fields + 1] = { t = "Governor I",                x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.i_gain }
fields[#fields + 1] = { t = "Drive Frequency [KHz]",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.drive_freq }
fields[#fields + 1] = { t = "Maximun Motor ERPM",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.max_motor_erpm }

-- Other
labels[#labels + 1] = { t = "Other Parameters",          x = x, y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Throttle Protocol",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.throttle_protocol }
fields[#fields + 1] = { t = "Telemetry Protocol",             x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.telemetry_protocol }
fields[#fields + 1] = { t = "LED Color",                 x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.led_color }
fields[#fields + 1] = { t = "Motor Temperture Sensor",   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.motor_temp_sensor }
fields[#fields + 1] = { t = "Motor Temperture Limit",    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.motor_temp }
fields[#fields + 1] = { t = "Capacity Limit [mAh]",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.capacity_cutoff }

local function receivedEscParameters(page, data)
    if data.esc_signature ~= 115 then -- Flyrotor signature
        page.labels[1].t = "Invalid ESC detected"
    else
        page.labels[1].t = string.format("FLYROTOR %dA%s", data.amperage, data.type == 1 and " F3C" or "")
        page.labels[2].t = string.format("S/N: %08X%08X", data.serial_number1, data.serial_number2)
        page.labels[3].t = string.format("HW: 1.%d - IAP: %d.%d.%d", data.hw_version, data.iap_major, data.iap_minor, data.iap_patch)
        page.labels[4].t = string.format("FW: %d.%d.%d", data.fw_major, data.fw_minor, data.fw_patch)
        page.labels[5].t = string.format("THR: %d-%dus", data.thr_min, data.thr_max)
        page.readOnly = bit32.band(data.command, 0x40) == 0x40
    end

    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi(mspEscFlyrotor).read(receivedEscParameters, self, escParameters)
    end,
    write = function(self)
        rf2.useApi(mspEscFlyrotor).write(escParameters)
        rf2.settingsSaved(false, false)
    end,
    title       = "FLYROTOR Setup",
    labels      = labels,
    fields      = fields,
    readOnly    = true
}
