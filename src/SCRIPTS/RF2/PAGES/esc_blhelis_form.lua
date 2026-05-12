local template = rf2.executeScript(rf2.radio.template)
local indent = template.indent
local lineSpacing = template.lineSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = template.margin
local y = yMinLim - lineSpacing
template = nil

local labels = {}
local fields = {}

local function incY(val) y = y + val return y end

local function addField(text, data, w)
    if not data.hidden then
        fields[#fields + 1] = { t = text, x = x, y = incY(lineSpacing), sp = x + sp, w = w, data = data }
    end
end

local function buildForm(escParameters, escCount, selectedEsc, endEscEditing)
    y = yMinLim - lineSpacing

    if not escParameters then
        labels[1] = { t = "ESC not ready, waiting...", x = x, y = incY(lineSpacing) }
        fields[1] = { t = nil, x = 0, y = 0, data = nil, readOnly = true } -- dummy field since ui.lua expects at least one field
        return labels, fields
    end

    labels[1] = {
        t = escParameters.firmwareVersion,
        x = x,
        y = incY(lineSpacing)
    }

    fields[1] = {
        t = "ESC",
        x = x + indent,
        y = incY(lineSpacing),
        sp = x + sp,
        data = { value = selectedEsc, min = 0, max = escCount - 1, table = { [0] = "1", "2", "3", "4" } },
        postEdit = endEscEditing
    }

    labels[#labels + 1] = { t = "Basic", x = x, y = incY(lineSpacing) }
    addField("Programming by TX", escParameters.programming_by_tx)
    addField("Startup power", escParameters.startup_power)
    addField("Temp protection", escParameters.temperature_protection)
    addField("Low RPM protection", escParameters.low_rpm_power_protection)
    addField("Brake on stop", escParameters.brake_on_stop)
    addField("Demag compensation", escParameters.demag_compensation)
    addField("Motor timing", escParameters.commutation_timing)
    addField("Beep strength", escParameters.beep_strength)
    addField("Beacon strength", escParameters.beacon_strength)
    addField("Beacon delay", escParameters.beacon_delay, 150)
    addField("Motor direction", escParameters.motor_direction, 150)

    labels[#labels + 1] = { t = "Throttle Range", x = x, y = incY(lineSpacing * 1.5) }
    addField("PPM Min", escParameters.ppm_min_throttle)
    addField("PPM Max", escParameters.ppm_max_throttle)
    addField("PPM Center", escParameters.ppm_center_throttle)

    return labels, fields
end

return buildForm(...)