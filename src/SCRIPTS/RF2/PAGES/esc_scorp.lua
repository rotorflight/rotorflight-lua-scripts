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
local mspEscScorp = "mspEscScorp"
local escParameters = rf2.useApi(mspEscScorp).getDefaults()

local function rebootEsc(field, page)
    escParameters.command = 0x80
    rf2.useApi(mspEscScorp).write(escParameters)
    rf2.reloadPage()
end

labels[1] = { t = "ESC not ready, waiting...", x = x,          y = incY(lineSpacing) }
labels[2] = { t = "  Please power cycle",      x = x + indent, y = incY(lineSpacing), bold = false }
labels[3] = { t = "     your ESC now.",        x = x + indent, y = incY(lineSpacing), bold = false }

--- Basic
fields[1] = { t = "Flight Mode",           x = x,              y = incY(lineSpacing * 2), sp = x + sp, w = 150, data = escParameters.flight_mode }
fields[2] = { t = "Rotation",              x = x,              y = incY(lineSpacing), sp = x + sp,     data = escParameters.rotation }
fields[3] = { t = "Telemetry Protocol",    x = x ,             y = incY(lineSpacing), sp = x + sp,     w = 150, data = escParameters.telemetry_protocol }
fields[4] = { t = "Startup Sound",         x = x,              y = incY(lineSpacing), sp = x + sp,     data = escParameters.startup_sound }
fields[5] = { t = "BEC Voltage",           x = x,              y = incY(lineSpacing), sp = x + sp,     data = escParameters.bec_voltage }

labels[4] = { t = "Governor",              x = x,              y = incY(lineSpacing * 2) }
fields[6] = { t = "P-Gain",                x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.p_gain }
fields[7] = { t = "I-Gain",                x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.i_gain }

-- Advanced
labels[5] = { t = "Soft Start",            x = x,              y = incY(lineSpacing) }
fields[8] = { t = "Start Time",            x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.start_time }
fields[9] = { t = "Runup Time",            x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.runup_time }
fields[10] = { t = "Bailout",              x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.bailout }

-- dont appear to be populated
--fields[#fields + 1] = { t = "Stick Zero (us)",        x = x + indent, y = incY(lineSpacing * 2), sp = x + sp, data = escParameters.stick_zero }
--fields[#fields + 1] = { t = "Stick Max (us)",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = escParameters.stick_max }

-- Protection
labels[6] = { t = "Protection",            x = x,              y = incY(lineSpacing) }
fields[11] = { t = "Protection Delay",     x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.protection_delay }
fields[12] = { t = "Cutoff Handling",      x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.cutoff_handling }
fields[13] = { t = "Max Temp (C)",         x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.max_temp }
fields[14] = { t = "Max Current (A)",      x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.max_current }
fields[15] = { t = "Min Voltage (V)",      x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.min_voltage }
fields[16] = { t = "Max Used (Ah)",        x = x + indent,     y = incY(lineSpacing), sp = x + sp,     data = escParameters.max_ah_used }
fields[17] = { t = "[Reboot ESC]",         x = x + indent * 3, y = incY(lineSpacing * 1.3), preEdit = rebootEsc }

local function receivedEscParameters(page, data)
    if data.esc_signature ~= 83 then -- Scorpion signature
        page.labels[1].t = "Invalid ESC detected"
    else
        page.labels[1].t = data.esc_type_name
        page.labels[2].t = string.format("S/N: %08X", data.serial_number)
        page.labels[3].t = "FW: v" .. data.firmware_version

        -- The 'ability to reboot' flag is only available on Scorpion ESCs.
        local canReboot = bit32.band(data.command, 0x80) == 0x80
        if not canReboot then
            page.fields[17].readOnly = true
        end
        data.command = 0 -- prevent reboot when saving
        page.readOnly = false -- enable saving
    end

    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi(mspEscScorp).read(receivedEscParameters, self, escParameters)
    end,
    write = function(self)
        rf2.useApi(mspEscScorp).write(escParameters)
        rf2.settingsSaved(false, false)
    end,
    title       = "Scorpion Setup",
    labels      = labels,
    fields      = fields,
    readOnly    = true
}
