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
    addField("Min startup power", escParameters.startup_power_min)
    addField("Max startup power", escParameters.startup_power_max)
    addField("Temp protection", escParameters.temperature_protection)
    addField("Motor timing", escParameters.commutation_timing)
    addField("Demag compensation", escParameters.demag_compensation)
    addField("RPM power prot", escParameters.rpm_power_slope)
    addField("Beep strength", escParameters.beep_strength)
    addField("Beacon strength", escParameters.beacon_strength)
    addField("Beacon delay", escParameters.beacon_delay, 150)
    addField("Brake on stop", escParameters.brake_on_stop)
    addField("Max breaking strength", escParameters.breaking_strength)
    addField("ESC power rating", escParameters.power_rating)
    addField("Force EDT arm", escParameters.force_edt_arm)
    addField("Motor direction", escParameters.motor_direction, 150)
    return labels, fields
end

return buildForm(...)