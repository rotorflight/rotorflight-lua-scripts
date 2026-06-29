local template = rf2.executeScript(rf2.radio.template)
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local mspEscHwPl5 = "mspEscHwPl5"
local escParameters = rf2.useApi(mspEscHwPl5).getDefaults()

local sections = {
    {
        gap = lineSpacing * 2,
        fields = {
            { t = "Flight Mode", dataKey = "flight_mode", indent = false, w = 125 },
            { t = "Rotation", dataKey = "rotation", indent = false },
        }
    },
    {
        title = "Voltage",
        gap = lineSpacing * 2,
        fields = {
            { t = "BEC Voltage", dataKey = "bec_voltage" },
            { t = "Lipo Cell Count", dataKey = "lipo_cell_count" },
            { t = "Volt Cutoff Type", dataKey = "cutoff_type" },
            { t = "Cuttoff Voltage", dataKey = "cutoff_voltage" },
        }
    },
    {
        title = "Governor",
        fields = {
            { t = "P-Gain", dataKey = "gov_p_gain" },
            { t = "I-Gain", dataKey = "gov_i_gain" },
        }
    },
    {
        title = "Soft Start",
        fields = {
            { t = "Startup Time", dataKey = "startup_time" },
            { t = "Restart Time", dataKey = "restart_time" },
            { t = "Auto Restart", dataKey = "auto_restart" },
        }
    },
    {
        title = "Motor",
        fields = {
            { t = "Timing", dataKey = "timing" },
            { t = "Startup Power", dataKey = "startup_power" },
            { t = "Active Freewheel", dataKey = "active_freewheel" },
            { t = "Response Time", dataKey = "response_time" },
        }
    },
    {
        title = "Brake",
        fields = {
            { t = "Brake Type", dataKey = "brake_type" },
            { t = "Brake Force %", dataKey = "brake_force" },
        }
    },
}

local function buildForm(data)
    data = data or escParameters
    local y = yMinLim - lineSpacing
    local function incY(val) y = y + val return y end
    local labels = {}
    local fields = {}
    local supported = data._supported
    local filter = type(supported) == "table" and next(supported) ~= nil

    local function isSupported(dataKey)
        return not filter or supported[dataKey] == true
    end

    local function sectionHasFields(section)
        for i = 1, #section.fields do
            if isSupported(section.fields[i].dataKey) then return true end
        end
        return false
    end

    local function addField(def)
        if not isSupported(def.dataKey) then return end
        local field = {
            t = def.t,
            x = x + (def.indent == false and 0 or indent),
            y = incY(lineSpacing),
            sp = x + sp,
            data = data[def.dataKey],
            dataKey = def.dataKey
        }
        if def.w then field.w = def.w end
        fields[#fields + 1] = field
    end

    local function addSection(section)
        if not sectionHasFields(section) then return end
        local gap = section.gap or lineSpacing
        if section.title then
            labels[#labels + 1] = { t = section.title, x = x, y = incY(gap) }
        else
            y = y + gap - lineSpacing
        end
        for i = 1, #section.fields do
            addField(section.fields[i])
        end
    end

    labels[1] = { t = "ESC not ready, waiting...", x = x, y = incY(lineSpacing) }
    labels[2] = { t = "---", x = x + indent, y = incY(lineSpacing), bold = false }
    labels[3] = { t = "---", x = x + indent, y = incY(lineSpacing), bold = false }

    for i = 1, #sections do
        addSection(sections[i])
    end

    return labels, fields
end

local labels, fields = buildForm(escParameters)

local function receivedEscParameters(page, data)
    page.labels, page.fields = buildForm(data)

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
